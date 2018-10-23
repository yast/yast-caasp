#! /usr/bin/env rspec

require_relative "../../../test_helper.rb"

require "y2caasp/clients/worker_role_dialog.rb"

Yast.import "CWM"
Yast.import "Lan"
Yast.import "Mode"
Yast.import "Wizard"

describe ::Y2Caasp::WorkerRoleDialog do
  describe "#run" do
    let(:ntp_servers) { [] }

    before do
      allow(Yast::Wizard).to receive(:CreateDialog)
      allow(Yast::Wizard).to receive(:CloseDialog)
      allow(Yast::CWM).to receive(:show).and_return(:next)
      allow(Yast::Lan).to receive(:ReadWithCacheNoGUI)
      allow(Yast::LanItems).to receive(:dhcp_ntp_servers).and_return({})
    end

    it "creates wizard dialog in normal mode" do
      allow(Yast::Mode).to receive(:normal).and_return(true)

      expect(Yast::Wizard).to receive(:CreateDialog)

      subject.run
    end

    it "closed wizard dialog in normal mode" do
      allow(Yast::Mode).to receive(:normal).and_return(true)

      expect(Yast::Wizard).to receive(:CloseDialog)

      subject.run
    end

    it "shows CWM widgets" do
      allow(Yast::Mode).to receive(:normal).and_return(true)

      expect(Yast::CWM).to receive(:show).and_return(:next)

      subject.run
    end

    context "when some NTP server is detected via SLP" do
      let(:ntp_servers) { ["ntp.example.com"] }

      it "proposes to use it by default" do
        expect(Yast::LanItems).to receive(:dhcp_ntp_servers).and_return("eth0" => ntp_servers)
        expect(Y2Caasp::Widgets::NtpServer).to receive(:new)
          .with(ntp_servers).and_call_original
        subject.run
      end
    end

  end
end
