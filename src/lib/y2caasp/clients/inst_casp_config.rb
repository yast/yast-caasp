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

require "uri"
require "users/widgets"
require "ui/widgets"

require "installation/widgets/hiding_place"
require "y2caasp/widgets/ntp_server"
require "installation/services"

module Y2Caasp
  # This library provides a simple dialog for setting
  # - the password for the system administrator (root)
  # This dialog does not write the password to the system,
  # only stores it in UsersSimple module,
  # to be written during inst_finish.
  class InstCaspConfig
    include Yast::Logger
    include Yast::I18n
    include Yast::UIShortcuts

    def run
      Yast.import "UI"
      Yast.import "Mode"
      Yast.import "CWM"
      Yast.import "Wizard"

      textdomain "caasp"

      # FIXME: handle going back

      # We do not need to create a wizard dialog in installation, but it's
      # helpful when testing all manually on a running system
      Yast::Wizard.CreateDialog if separate_wizard_needed?

      log.info("Current role: #{current_role}")

      ret = nil
      loop do
        ret = Yast::CWM.show(
          content,
          # Title for installation overview dialog
          caption:        _("Node Configuration"),
          skip_store_for: [:redraw]
        )

        next if ret == :redraw

        break if ret == :next

        # FIXME: handle going back

        # Currently no other return value is expected, behavior can
        # be unpredictable if something else is received - raise
        # RuntimeError
        raise "Unexpected return value" if ret != :next
      end

      add_casp_services

      Yast::Wizard.CloseDialog if separate_wizard_needed?

      ret
    end

  private

    # Specific services that needs to be enabled on CAaSP see (FATE#321738)
    # It is additional services to the ones defined for role.
    # It is caasp only services and for generic approach systemd-presets should be used.
    # In this case it is not used, due to some problems with cloud services.
    CASP_SERVICES = ["sshd", "cloud-init-local", "cloud-init", "cloud-config",
                     "cloud-final", "issue-generator", "issue-add-ssh-keys"].freeze
    def add_casp_services
      ::Installation::Services.enabled.concat(CASP_SERVICES)
    end

    def quadrant_layout(upper_left:, lower_left:, upper_right:, lower_right:)
      HBox(
        HWeight(
          6,
          VBox(
            VSpacing(2),
            VWeight(5, upper_left),
            VWeight(5, lower_left)
          )
        ),
        HSpacing(3),
        HWeight(
          4,
          VBox(
            VSpacing(2),
            VWeight(5, upper_right),
            VWeight(5, lower_right)
          )
        )
      )
    end

    def content
      return @content if @content

      controller_node = Installation::Widgets::HidingPlace.new(
        Y2Caasp::Widgets::ControllerNode.new
      )

      ntp_server = Installation::Widgets::HidingPlace.new(
        # FIXME: preselect from the DHCP response
        Y2Caasp::Widgets::NtpServer.new([])
      )

      @content = VBox(
        VBox(
          Y2Caasp::Widgets::SystemRole.new(controller_node, ntp_server),
          controller_node,
          ntp_server
        )
      )
    end

    # Returns whether we need/ed to create new UI Wizard
    def separate_wizard_needed?
      Yast::Mode.normal
    end
  end
end
