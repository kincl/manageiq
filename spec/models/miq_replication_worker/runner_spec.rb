require "spec_helper"

describe MiqReplicationWorker::Runner do
  before do
    allow_any_instance_of(MiqReplicationWorker::Runner).to receive(:worker_initialization)
    @worker = MiqReplicationWorker::Runner.new
  end

  context "testing rubyrep_alive?" do
    before do
      allow(Process).to receive(:waitpid2)
      allow(@worker).to receive(:child_process_recently_active?).and_return(true)
      @worker.instance_variable_set(:@pid, 123)
    end

    it "should be alive if process is alive" do
      allow(MiqProcess).to receive(:state).and_return(:sleeping)
      expect(@worker.rubyrep_alive?).to be_truthy
    end

    it "should not be alive if process is zombie" do
      allow(MiqProcess).to receive(:state).and_return(:zombie)
      expect(@worker.rubyrep_alive?).to be_falsey
    end
  end

  context "testing child process heartbeat" do
    it "should be alive if heartbeat within threshold" do
      @worker.stub(:child_process_last_heartbeat => 1.second.ago.utc)
      expect(@worker.child_process_recently_active?).to be_truthy
    end

    it "should not be alive if heartbeat beyond threshold" do
      @worker.stub(:child_process_last_heartbeat => 6.minutes.ago.utc)
      expect(@worker.child_process_recently_active?).to be_falsey
    end
  end
end
