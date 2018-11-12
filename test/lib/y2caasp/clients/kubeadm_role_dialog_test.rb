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
      allow(Yast::Lan).to receive(:ReadWithCacheNoGUI)
      allow(Yast::LanItems).to receive(:dhcp_ntp_servers).and_return({})
      allow(Yast::ProductFeatures).to receive(:GetBooleanFeature)
    end

    include_examples "CWM::Dialog"
    include_examples "NTP from DHCP"

    context "no NTP server set in DHCP and default NTP is enabled in control.xml" do
      before do
        allow(Yast::ProductFeatures).to receive(:GetBooleanFeature)
          .with("globals", "default_ntp_setup").and_return(true)
        allow(Yast::Product).to receive(:FindBaseProducts)
          .and_return(["name" => "openSUSE-Tumbleweed-Kubic"])
      end

      it "proposes to use a random openSUSE pool server" do
        expect(Y2Caasp::Widgets::NtpServer).to receive(:new) do |s|
          expect(s.first).to match(/\A[0-3]\.opensuse\.pool\.ntp\.org\z/)
        end.and_call_original
        subject.run
      end
    end
  end
end
