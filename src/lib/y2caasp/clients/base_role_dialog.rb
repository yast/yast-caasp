# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2018 SUSE LLC
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

require "ui/widgets"

module Y2Caasp
  # This library provides a base class for a simple dialog
  # The subclasses must override the #caption and #content methods
  class BaseRoleDialog
    include Yast::Logger
    include Yast::I18n
    include Yast::UIShortcuts

    def run
      Yast.import "UI"
      Yast.import "Mode"
      Yast.import "CWM"
      Yast.import "Wizard"
      Yast.import "Lan"
      Yast.import "LanItems"

      textdomain "caasp"

      # We do not need to create a wizard dialog in installation, but it's
      # helpful when testing all manually on a running system
      Yast::Wizard.CreateDialog if separate_wizard_needed?

      ret = nil
      loop do
        ret = Yast::CWM.show(
          content,
          caption:        caption,
          skip_store_for: [:redraw]
        )

        next if ret == :redraw
        break if [:back, :next, :abort].include?(ret)

        # Currently no other return value is expected, behavior can
        # be unpredictable if something else is received - raise
        # RuntimeError
        raise "Unexpected return value" if ret != :next
      end

      Yast::Wizard.CloseDialog if separate_wizard_needed?

      ret
    end

  private

    # Returns whether we need to create a new UI Wizard
    def separate_wizard_needed?
      Yast::Mode.normal
    end

    def dhcp_ntp_servers
      # When proposing NTP servers we need to know
      # 1) list of (dhcp) interfaces
      # 2) network service in use
      # We can either use networking submodule for network service handling and get list of
      # interfaces e.g. using a bash command or initialize whole networking module.
      Yast::Lan.ReadWithCacheNoGUI

      Yast::LanItems.dhcp_ntp_servers.values.reduce(&:concat) || []
    end
  end
end
