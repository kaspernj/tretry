require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Tretry" do
  context "#try" do
    it "should be able to run blocks" do
      try = 0
      res = Tretry.try(tries: 5) do
        try += 1
        raise "Test #{try}" if try < 5
        "kasper"
      end

      res[:error].should eq false
      res[:result].should eq "kasper"
    end

    it "should be able to do waits between tries" do
      try = 0
      time_start = Time.now.to_f
      res = Tretry.try(tries: 5, wait: 0.1) do
        try += 1
        raise "Test #{try}" if try < 5
        "kasper"
      end

      time_end = Time.now.to_f
      time_elap = time_end - time_start
      time_elap.should > 0.4
    end

    it "should be able to do timeouts with tries" do
      try = 0
      res = Tretry.try(tries: 5, timeout: 0.1) do
        try += 1
        sleep 0.5 if try < 5
        "kasper"
      end

      res[:error].should eq false
      res[:result].should eq "kasper"
      res[:tries].length.should eq 4

      res[:tries].each do |err|
        err[:error].is_a?(Timeout::Error).should eq true
      end
    end
  end
end
