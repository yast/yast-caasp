#! /usr/bin/env rspec

require_relative "../../test_helper"
require "y2system_role_handlers/dashboard_role_finish"

Yast.import "NtpClient"

describe Y2SystemRoleHandlers::DashboardRoleFinish do
  subject(:handler) { described_class.new }

  let(:ntp_server) { "ntp.suse.de" }
  let(:ntp_servers) { [ntp_server] }

  let(:role) do
    ::Installation::SystemRole.new(id: "dashboard_role").tap do |role|
      role["ntp_servers"] = ntp_servers
    end
  end

  before do
    allow(::Installation::SystemRole).to receive(:find)
      .with("dashboard_role").and_return(role)
    allow(Yast::NtpClient).to receive(:Read)
    allow(Yast::NtpClient).to receive(:Write)
    allow(Yast::Execute).to receive(:on_target)
  end

  describe "#run" do
    it "runs the activation script" do
      expect(Yast::Execute).to receive(:on_target).with(/activate.sh/)
      handler.run
    end

    context "when a NTP server is specified" do
      it "adds the server to the configuration" do
        handler.run
        record = Yast::NtpClient.ntp_records.find { |r| r["address"] == ntp_server }
        expect(record).to_not be_nil
        expect(record).to eq("type" => "server", "address" => ntp_server, "options" => "iburst")
      end

      it "allows clients to sync with the server" do
        handler.run
        expect(Yast::NtpClient.restrict_map.keys.sort).to eq(["-4", "-6"])
        expect(Yast::NtpClient.restrict_map.values.uniq.first)
          .to eq("options" => "default kod nomodify notrap nopeer noquery")
      end

      it "writes the NTP configuration" do
        expect(Yast::NtpClient).to receive(:Write)
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
        expect(Yast::NtpClient).to_not receive(:Write)
        handler.run
      end
    end
  end
end
