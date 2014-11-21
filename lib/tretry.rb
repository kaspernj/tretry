#A library for doing retries in Ruby with timeouts, analysis of errors, waits between tries and more.
class Tretry
  attr_reader :fails
  attr_accessor :timeout, :tries, :wait

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
    Tretry.new(args).try(&block)
  end

  def initialize(args = {})
    @args = args
    @fails = []
    @before_retry = []

    parse_arguments
  end

  def before_retry(&block)
    @before_retry << block
  end

  def try(&block)
    raise "No block given." unless block
    @block = block

    @tries.times do |count|
      @count = count

      unless first_try?
        # Sleep for a given amount of time if the 'wait'-argument is given.
        sleep(@wait) if @wait

        call_before_retry(error: @error)
        @error = nil
      end

      begin
        # If a timeout-argument has been given, then run the code through the timeout.
        if @timeout
          try_with_timeout
        else
          # Else call block normally.
          @res = @block.call
          @dobreak = true
        end
      rescue Exception => e
        handle_error(e)
      end

      if @doraise
        if @args[:return_error]
          @fails << {error: @error}
          return {
            fails: @fails,
            error: true
          }
        else
          raise @error
        end
      elsif @error
        @fails << {error: @error}
      end

      break if @dobreak
    end

    return {
      fails: @fails,
      result: @res,
      error: false
    }
  end

private

  def parse_arguments
    #Validate given arguments and set various variables.
    raise "Expected argument to be a hash." unless @args.is_a?(Hash)

    @args.each do |key, val|
      raise "Invalid key: '#{key}'." unless VALID_KEYS.include?(key)
    end

    @args[:tries] ||= 3
    @tries = @args[:tries].to_i
    @wait = @args[:wait] ? @args[:wait] : nil
    @timeout = @args[:timeout] ? @args[:timeout].to_f : nil
  end

  def try_with_timeout
    begin
      require "timeout"
      Timeout.timeout(@timeout) do
        @res = @block.call
        @dobreak = true
      end
    rescue Timeout::Error => e
      handle_error(e)
    end
  end

  def handle_error(e)
    if e.class == Interrupt
      raise e if !@args.key?(:interrupt) || @args[:interrupt]
    elsif e.class == SystemExit
      raise e if !@args.key?(:exit) || @args[:exit]
    elsif last_try? || (@args.key?(:errors) && !@args[:errors].include?(e.class))
      @doraise = e
    elsif @args.key?(:errors) && @args[:errors].index(e.class) != nil
      #given error was in the :errors-array - do nothing. Maybe later it should be logged and returned in a stats-hash or something? - knj
    end

    @error = e
  end

  def call_before_retry(args)
    @before_retry.each do |before_retry_block|
      before_retry_block.call(args)
    end
  end

  def last_try?
    (@count + 1) >= @tries
  end

  def first_try?
    @count == 0
  end
end
