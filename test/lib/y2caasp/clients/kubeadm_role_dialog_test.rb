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
    end

    include_examples "CWM::Dialog"
    include_examples "NTP from DHCP"

    context "when no NTP server is detected via DHCP" do
      it "proposes to use a random openSUSE pool server" do
        expect(Y2Caasp::Widgets::NtpServer).to receive(:new) do |s|
          expect(s.first).to match(/\A[0-3]\.opensuse\.pool\.ntp\.org\z/)
        end.and_call_original
        subject.run
      end
    end

  end
end
