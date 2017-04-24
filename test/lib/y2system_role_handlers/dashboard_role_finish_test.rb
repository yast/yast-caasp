#! /usr/bin/env rspec

require_relative "../../test_helper"
require "y2system_role_handlers/dashboard_role_finish"

describe Y2SystemRoleHandlers::DashboardRoleFinish do
  subject(:handler) { described_class.new }

  let(:ntp_server) { "ntp.suse.de" }
  let(:ntp_servers) { [ntp_server] }

  before do
    stub_const("CFA::NtpConf::PATH", FIXTURES_PATH.join("ntp.conf").to_s)
    allow(CFA::NtpConf).to receive(:new).and_return(ntp_conf)
  end

  let(:role) do
    ::Installation::SystemRole.new(id: "dashboard_role").tap do |role|
      role["ntp_servers"] = ntp_servers
    end
  end

  before do
    allow(::Installation::SystemRole).to receive(:find)
      .with("dashboard_role").and_return(role)
    allow(Yast::Execute).to receive(:on_target)
  end

  describe "#run" do
    let(:ntp_conf) { CFA::NtpConf.new }

    before do
      allow(ntp_conf).to receive(:save)
    end

    it "runs the activation script" do
      expect(Yast::Execute).to receive(:on_target).with(/activate.sh/)
      handler.run
    end

    context "when a NTP server is specified" do
      it "adds the server to the configuration" do
        handler.run
        records = ntp_conf.records.select { |r| r.type == "server" }
        expect(records.map(&:value)).to eq([ntp_server])
        expect(records.first.options).to eq(["iburst"])
      end

      it "writes the NTP configuration" do
        expect(ntp_conf).to receive(:save)
        handler.run
      end

      it "sets the ntpd service to be enabled" do
        handler.run
        expect(::Installation::Services.enabled).to include("ntpd")
      end
    end

    context "when no NTP server is specified" do
      let(:ntp_servers) { nil }

      it "does not modify NTP configuration" do
        expect(CFA::NtpConf).to_not receive(:new)
        handler.run
      end
    end
  end
end
