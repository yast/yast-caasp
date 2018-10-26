# encoding: utf-8

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

require "cwm/dialog"
require "y2caasp/widgets/ntp_server"
require "y2caasp/dhcp_ntp_servers"

module Y2Caasp
  # This library provides a simple dialog for setting
  # the admin role specific settings:
  #   - the NTP server names
  class AdminRoleDialog < CWM::Dialog
    include DhcpNtpServers

    def initialize
      textdomain "caasp"
      super
    end

    def title
      _("Admin Node Configuration")
    end

    def contents
      return @content if @content

      @content = HSquash(
        MinWidth(50,
          # preselect the servers from the DHCP response
          Y2Caasp::Widgets::NtpServer.new(dhcp_ntp_servers))
      )
    end
  end
end
