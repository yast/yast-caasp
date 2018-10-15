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

require "ui/widgets"

require "y2caasp/widgets/ntp_server"
require "installation/services"

module Y2Caasp
  # This library provides a simple dialog for setting
  # - the password for the system administrator (root)
  # This dialog does not write the password to the system,
  # only stores it in UsersSimple module,
  # to be written during inst_finish.
  class AdminRoleDialog
    include Yast::Logger
    include Yast::I18n
    include Yast::UIShortcuts

    def run
      Yast.import "UI"
      Yast.import "Mode"
      Yast.import "CWM"
      Yast.import "Wizard"

      textdomain "caasp"

      # We do not need to create a wizard dialog in installation, but it's
      # helpful when testing all manually on a running system
      Yast::Wizard.CreateDialog if separate_wizard_needed?

      ret = nil
      loop do
        ret = Yast::CWM.show(
          content,
          # Title for admin node configuration
          caption:        _("Admin Node Configuration"),
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

    def content
      return @content if @content

      @content = HSquash(
        MinWidth(50,
          # FIXME: preselect from the DHCP response
          Y2Caasp::Widgets::NtpServer.new)
      )
    end

    # Returns whether we need/ed to create new UI Wizard
    def separate_wizard_needed?
      Yast::Mode.normal
    end
  end
end
