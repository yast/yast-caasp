#! /usr/bin/env rspec

require_relative "../../../test_helper.rb"
require_relative "role_dialog_examples"
require "cwm/rspec"

require "y2caasp/clients/kubeadm_role_dialog.rb"

Yast.import "CWM"
Yast.import "Lan"
Yast.import "Wizard"

describe Y2Caasp::KubeadmRoleDialog do
  describe "#run" do
    let(:ntp_servers) { [] }

    before do
      allow(Yast::Wizard).to receive(:CreateDialog)
      allow(Yast::Wizard).to receive(:CloseDialog)
      allow(Yast::CWM).to receive(:show).and_return(:next)
      allow(Yast::Lan).to receive(:dhcp_ntp_servers).and_return([])
      allow(Yast::ProductFeatures).to receive(:GetBooleanFeature)
    end

    include_examples "CWM::Dialog"
    include_examples "NTP from DHCP"

    context "no NTP server set in DHCP and default NTP is enabled in control.xml" do
      let(:default_servers) do
        [
          Y2Network::NtpServer.new("0.suse.pool.ntp.org"),
          Y2Network::NtpServer.new("1.suse.pool.ntp.org")
        ]
      end

      before do
        allow(Yast::ProductFeatures).to receive(:GetBooleanFeature)
          .with("globals", "default_ntp_setup").and_return(true)
        allow(Y2Network::NtpServer).to receive(:default_servers).and_return(default_servers)
      end

      it "proposes to use a random server from the default pool" do
        expect(Y2Caasp::Widgets::NtpServer).to receive(:new).and_wrap_original do |original, arg|
          expect(default_servers.map(&:hostname)).to include(arg.first)
          original.call(arg)
        end
        subject.run
      end
    end
  end
end
