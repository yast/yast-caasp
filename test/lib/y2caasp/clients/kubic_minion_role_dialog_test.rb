# Copyright (c) [2020] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require_relative "../../../test_helper.rb"
require_relative "role_dialog_examples"
require "cwm/rspec"

require "y2caasp/clients/kubic_minion_role_dialog"

Yast.import "CWM"
Yast.import "Lan"
Yast.import "Wizard"

describe ::Y2Caasp::KubicMinionRoleDialog do
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

    # Note: this is a hypothetical test, in real CaaSP the default NTP setup
    # is currently disabled in control.xml
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
          expect(arg.size).to eq(1)
          expect(arg.first).to match(/suse.pool.ntp.org/)
          original.call(arg)
        end
        subject.run
      end
    end
  end
end
