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
    #Validate given arguments and set various variables.
    raise "No block was given." if !block
    raise "Expected argument to be a hash." if !args.is_a?(Hash)
    
    args.each do |key, val|
      raise "Invalid key: '#{key}'." if !VALID_KEYS.include?(key)
    end
    
    args[:tries] = 3 if !args[:tries]
    tries = []
    error = nil
    res = nil
    
    args[:tries].to_i.downto(1) do |count|
      error = nil
      dobreak = false
      
      begin
        if args[:timeout]
          #If a timeout-argument has been given, then run the code through the timeout.
          begin
            require "timeout"
            Timeout.timeout(args[:timeout]) do
              res = block.call
              dobreak = true
              break
            end
          rescue Timeout::Error => e
            doraise = e if count <= 1
            error = e
            sleep(args[:wait]) if args[:wait] and !doraise
          end
        else
          #Else call block normally.
          res = block.call
          dobreak = true
          break
        end
      rescue Exception => e
        if e.class == Interrupt
          raise e if !args.key?(:interrupt) or args[:interrupt]
        elsif e.class == SystemExit
          raise e if !args.key?(:exit) or args[:exit]
        elsif count <= 1 or (args.key?(:errors) and args[:errors].index(e.class) == nil)
          doraise = e
        elsif args.key?(:errors) and args[:errors].index(e.class) != nil
          #given error was in the :errors-array - do nothing. Maybe later it should be logged and returned in a stats-hash or something? - knj
        end
        
        error = e
        
        #Sleep for a given amount of time if the 'wait'-argument is given.
        sleep(args[:wait]) if args[:wait] and !doraise
      end
      
      if doraise
        if args[:return_error]
          tries << {:error => error}
          return {
            :tries => tries,
            :error => true
          }
        else
          raise e
        end
      elsif error
        tries << {:error => error}
      end
      
      break if dobreak
    end
    
    return {
      :tries => tries,
      :result => res,
      :error => false
    }
  end
end