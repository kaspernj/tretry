require "spec_helper"

class TestError < RuntimeError; end
class AnotherTestError < RuntimeError; end

describe Tretry do
  context "#try" do
    it "runs blocks" do
      try = 0
      res = Tretry.try(tries: 5) do
        try += 1
        raise "Test #{try}" if try < 5
        "kasper"
      end

      expect(res[:error]).to eq false
      expect(res[:result]).to eq "kasper"
      expect(try).to eq 5
    end

    it "waits between tries" do
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

    it "does timeouts with tries" do
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

    it "catches given errors" do
      try_count = 0

      response = Tretry.try(errors: [TestError]) do
        try_count += 1

        raise TestError, "Test" if try_count <= 2

        54
      end

      expect(try_count).to eq 3
      expect(response.result).to eq 54
    end

    it "only catches given errors" do
      try_count = 0

      expect do
        Tretry.try(errors: [TestError]) do
          try_count += 1

          raise AnotherTestError, "Test"
        end
      end.to raise_error(AnotherTestError, "Test")

      expect(try_count).to eq 1
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

  it "raises an error if fails" do
    expect {
      Tretry.try do
        raise "fail"
      end
    }.to raise_error(RuntimeError)
  end
end
