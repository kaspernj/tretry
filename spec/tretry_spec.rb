require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Tretry" do
  it "should be able to run blocks" do
    try = 0
    res = Tretry.try(:tries => 5) do
      try += 1
      raise "Test #{try}" if try < 5
      "kasper"
    end
    
    raise "Expected error to be false but it wasnt: '#{res[:error]}'." if res[:error] != false
    raise "Expected result to be 'kasper' but it wasnt: '#{res[:result]}'." if res[:result] != "kasper"
  end
  
  it "should be able to do waits between tries" do
    try = 0
    time_start = Time.now.to_f
    res = Tretry.try(:tries => 5, :wait => 0.1) do
      try += 1
      raise "Test #{try}" if try < 5
      "kasper"
    end
    
    time_end = Time.now.to_f
    time_elap = time_end - time_start
    
    raise "Expected time to be more than 0.4 sec but it wasnt: '#{time_elap}'." if time_elap < 0.4
  end
  
  it "should be able to do timeouts with tries" do
    try = 0
    res = Tretry.try(:tries => 5, :timeout => 0.1) do
      try += 1
      sleep 0.5 if try < 5
      "kasper"
    end
    
    raise "Expected error to be false but it wasnt: '#{res[:error]}'." if res[:error] != false
    raise "Expected result to be 'kasper' but it wasnt: '#{res[:result]}'." if res[:result] != "kasper"
    raise "Expected number of errors to be 4 but it wasnt: '#{res[:tries].length}'." if res[:tries].length != 4
    
    res[:tries].each do |err|
      raise "Expected error to be 'Timeout::Error' but it wasnt: '#{err[:error].class.name}'." if !err[:error].is_a?(Timeout::Error)
    end
  end
end
