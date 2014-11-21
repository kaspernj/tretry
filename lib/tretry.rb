#A library for doing retries in Ruby with timeouts, analysis of errors, waits between tries and more.
class Tretry
  #Valid keys that can be given as argument for the method 'try'.
  VALID_KEYS = [:tries, :timeout, :wait, :interrupt, :exit, :errors, :return_error]

  #===Runs a block of code a given amount of times until it succeeds.
  #===Examples
  #  res = Tretry.try(:tries => 3) do
  #     #something that often fails
  #  end
  #
  #  puts "Tries: '#{res[:tries]}'."
  #  puts "Result: '#{res[:result}'."
  def self.try(args = {}, &block)
    Tretry.new(args, &block).try
  end

  def initialize(args, &block)
    @args = args
    @args[:tries] ||= 3
    @block = block
    @tries = []

    validate_arguments
  end

  def try
    @args[:tries].to_i.downto(1) do |count|
      @error = nil

      begin
        if @args[:timeout]
          try_with_timeout(count)
        else
          # Else call block normally.
          @res = @block.call
          @dobreak = true
          break
        end
      rescue Exception => e
        handle_error(e, count)
      end

      if @doraise
        if @args[:return_error]
          @tries << {error: @error}
          return {
            tries: @tries,
            error: true
          }
        else
          raise @error
        end
      elsif @error
        @tries << {error: @error}
      end

      break if @dobreak
    end

    return {
      tries: @tries,
      result: @res,
      error: false
    }
  end

private

  def validate_arguments
    #Validate given arguments and set various variables.
    raise "No block was given." unless @block
    raise "Expected argument to be a hash." unless @args.is_a?(Hash)

    @args.each do |key, val|
      raise "Invalid key: '#{key}'." unless VALID_KEYS.include?(key)
    end
  end

  def try_with_timeout(count)
    #If a timeout-argument has been given, then run the code through the timeout.
    begin
      require "timeout"
      Timeout.timeout(@args[:timeout]) do
        @res = @block.call
        @dobreak = true
        break
      end
    rescue Timeout::Error => e
      @doraise = e if count <= 1
      @error = e
      sleep(@args[:wait]) if @args[:wait] && !@doraise
    end
  end

  def handle_error(e, count)
    if e.class == Interrupt
      raise e if !@args.key?(:interrupt) || @args[:interrupt]
    elsif e.class == SystemExit
      raise e if !@args.key?(:exit) || @args[:exit]
    elsif count <= 1 || (@args.key?(:errors) && @args[:errors].index(e.class) == nil)
      @doraise = e
    elsif @args.key?(:errors) && @args[:errors].index(e.class) != nil
      #given error was in the :errors-array - do nothing. Maybe later it should be logged and returned in a stats-hash or something? - knj
    end

    @error = e

    #Sleep for a given amount of time if the 'wait'-argument is given.
    sleep(@args[:wait]) if @args[:wait] && !@doraise
  end
end