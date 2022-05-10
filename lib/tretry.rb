# A library for doing retries in Ruby with timeouts, analysis of errors, waits between tries and more.
class Tretry
  autoload :Result, "#{__dir__}/tretry/result"

  attr_reader :fails
  attr_accessor :error, :errors, :exit, :fails, :interrupt, :return_error, :timeout, :tries, :wait

  #===Runs a block of code a given amount of times until it succeeds.
  #===Examples
  #  res = Tretry.try(:tries => 3) do
  #     #something that often fails
  #  end
  #
  #  puts "Tries: '#{res[:tries]}'."
  #  puts "Result: '#{res[:result}'."
  def self.try(**args, &block)
    Tretry.new(**args).try(&block)
  end

  def initialize(errors: nil, exit: true, interrupt: true, return_error: nil, timeout: nil, tries: 3, wait: nil)
    self.errors = errors
    self.exit = exit
    self.fails = []
    self.interrupt = interrupt
    @before_retry = []
    self.return_error = return_error
    self.timeout = timeout
    self.tries = tries
    self.wait = wait

    puts "TRIES: #{tries}"
  end

  def before_retry(&block)
    @before_retry << block
  end

  def try(&block)
    raise "No block given." unless block
    @block = block

    tries.times do |count|
      @count = count

      unless first_try?
        # Sleep for a given amount of time if the 'wait'-argument is given.
        sleep(wait) if wait

        call_before_retry(error: error)
        self.error = nil
      end

      begin
        # If a timeout-argument has been given, then run the code through the timeout.
        if timeout
          try_with_timeout
        else
          # Else call block normally.
          @res = @block.call
          @dobreak = true
        end
      rescue Exception => e
        puts "ERROR: #{e.message}"
        handle_error(e)
      end

      if @doraise
        if return_error
          fails << {error: error}

          return Tretry::Result.new(
            fails: fails,
            error: true
          )
        else
          raise error
        end
      elsif error
        fails << {error: error}
      end

      break if @dobreak
    end

    Tretry::Result.new(
      fails: fails,
      result: @res,
      error: false
    )
  end

private

  def try_with_timeout
    require "timeout"
    Timeout.timeout(timeout) do
      @res = @block.call
      @dobreak = true
    end
  rescue Timeout::Error => e
    handle_error(e)
  end

  def handle_error(e)
    if e.class == Interrupt
      raise e if interrupt
    elsif e.class == SystemExit
      raise e if self.exit
    elsif last_try? || errors && !errors.include?(e.class)
      @doraise = e
    elsif errors&.include?(e.class)
      # Given error was in the :errors-array - do nothing. Maybe later it should be logged and returned in a stats-hash or something? - knj
    end

    self.error = e
  end

  def call_before_retry(args)
    @before_retry.each do |before_retry_block|
      before_retry_block.call(args)
    end
  end

  def last_try?
    (@count + 1) >= tries
  end

  def first_try?
    @count == 0
  end
end
