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

      expect(res[:error]).to eq false
      expect(res[:result]).to eq "kasper"
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

      expect(time_elap).to be > 0.4
    end

    it "should be able to do timeouts with tries" do
      try = 0
      res = Tretry.try(tries: 5, timeout: 0.1) do
        try += 1
        sleep 0.5 if try < 5
        "kasper"
      end

      expect(res[:error]).to eq false
      expect(res[:result]).to eq "kasper"
      expect(res[:fails].length).to eq 4

      res[:fails].each do |err|
        expect(err[:error]).to be_a Timeout::Error
      end
    end
  end

  it "#before_retry" do
    before_retry_count = 0
    try_count = 0

    try = Tretry.new

    try.before_retry do
      before_retry_count += 1
    end

    try.try do
      try_count += 1
      raise "test" if try_count < 3
    end

    expect(before_retry_count).to eq 2

    try.fails.each do |try_i|
      expect(try_i[:error]).to be_a RuntimeError
    end
  end

  it "should raise an error if fails" do
    expect {
      Tretry.try do
        raise "fail"
      end
    }.to raise_error(RuntimeError)
  end
end
