#! /usr/bin/env rspec

require_relative "../../test_helper"
require "installation/system_role"
require "y2system_role_handlers/worker_role_finish"

describe Y2SystemRoleHandlers::WorkerRoleFinish do
  subject(:handler) { described_class.new }
  let(:role) { instance_double("::Installation::SystemRole") }
  let(:conf) do
    instance_double("Y2Caasp::CFA::MinionMasterConf", load: true, save: true)
  end

  before do
    allow(::Installation::SystemRole).to receive("find")
      .with("worker_role").and_return(role)
    allow(Y2Caasp::CFA::MinionMasterConf).to receive(:new).and_return(conf)
    allow(handler).to receive(:enable_timesync_service)
    allow(handler).to receive(:configure_salt_minion).with("controller")
    allow(handler).to receive(:configure_systemd_timesync).with("controller")
  end

  describe ".run" do
    it "saves the controller node location into the minion master.conf file" do
      expect(role).to receive(:[]).with("controller_node").and_return("controller")
      expect(handler).to receive(:configure_salt_minion).with("controller")

      handler.run
    end

    it "configures systemd timesync ntp server with the controller node location" do
      expect(role).to receive(:[]).with("controller_node").and_return("controller")

      expect(handler).to receive(:configure_systemd_timesync).with("controller")
      handler.run
    end

    it "sets systemd-timesync.service to be enabled during installation" do
      expect(role).to receive(:[]).with("controller_node").and_return("controller")
      expect(handler).to receive(:enable_timesync_service)

      handler.run
    end
  end
end
