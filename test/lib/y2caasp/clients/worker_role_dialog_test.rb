#! /usr/bin/env rspec

require_relative "../../../test_helper.rb"
require_relative "role_dialog_examples"
require "cwm/rspec"

require "y2caasp/clients/worker_role_dialog.rb"

Yast.import "CWM"
Yast.import "Lan"
Yast.import "Wizard"

describe ::Y2Caasp::WorkerRoleDialog do
  describe "#run" do
    before do
      allow(Yast::Wizard).to receive(:CreateDialog)
      allow(Yast::Wizard).to receive(:CloseDialog)
      allow(Yast::CWM).to receive(:show).and_return(:next)
      allow(Yast::Lan).to receive(:dhcp_ntp_servers).and_return([])
    end

    include_examples "CWM::Dialog"
    include_examples "NTP from DHCP"
  end
end
