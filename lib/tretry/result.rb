class Tretry::Result
  attr_reader :error, :fails, :result

  def initialize(error:, fails:, result:)
    @error = error
    @fails = fails
    @result = result
  end

  def [](key)
    case key
    when :error
      error
    when :fails
      fails
    when :result
      result
    else
      raise "Unknown key: #{key}"
    end
  end
end
