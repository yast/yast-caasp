#! /usr/bin/env rspec

require_relative "../../../test_helper.rb"
require_relative "role_dialog_examples"

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

    include_examples "displays the dialog"
    include_examples "NTP from DHCP"
  end
end
