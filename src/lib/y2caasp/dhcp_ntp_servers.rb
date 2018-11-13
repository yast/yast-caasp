# ------------------------------------------------------------------------------
# Copyright (c) 2017 SUSE LLC
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact SUSE.
#
# To contact SUSE about this file by physical or electronic mail, you may find
# current contact information at www.suse.com.
# ------------------------------------------------------------------------------

require "yast"

module Y2Caasp
  # This module provides a functionality for reading the NTP servers
  # from the DHCP response
  module DhcpNtpServers
    #
    # List of NTP servers from DHCP
    #
    # @return [Array<String>] List of servers (IP or host names), empty if not provided
    #
    def dhcp_ntp_servers
      Yast.import "Lan"
      Yast.import "LanItems"

      # When proposing NTP servers we need to know
      # 1) list of (dhcp) interfaces
      # 2) network service in use
      # We can either use networking submodule for network service handling and get list of
      # interfaces e.g. using a bash command or initialize whole networking module.
      Yast::Lan.ReadWithCacheNoGUI

      Yast::LanItems.dhcp_ntp_servers.values.flatten.uniq
    end
  end
end
