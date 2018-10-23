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

require "yast"
require "cwm/widget"
require "installation/services"
require "installation/system_role"
require "y2caasp/widgets/ntp_server"

Yast.import "ProductControl"
Yast.import "ProductFeatures"
Yast.import "IP"
Yast.import "Hostname"

module Y2Caasp
  module Widgets
    # This widget is responsible of validate and store the introduced location
    # which must be a valid IP or FQDN.
    # bsc#1032057: old name: Controller Node, new name: Administration Node.
    class ControllerNode < CWM::InputField
      def initialize
        textdomain "caasp"
      end

      def label
        _("Administration Node")
      end

      # It stores the value of the input field if validates
      #
      # @see #validate
      def store
        role["controller_node"] = value if role
      end

      # The input field is initialized with previous stored value
      def init
        self.value = role ? role["controller_node"] : ""
      end

      # It returns true if the value is a valid IP or a valid FQDN, if not it
      # displays a popup error.
      #
      # @return [Boolean] true if valid IP or FQDN
      def validate
        return true if Yast::IP.Check(value) || Yast::Hostname.CheckFQ(value)

        Yast::Popup.Error(
          # TRANSLATORS: error message for invalid administration node location
          _("Not valid location for the administration node, " \
          "please enter a valid IP or Hostname")
        )

        false
      end

      def help
        # TRANSLATORS: a help text for the admin node input field
        _("<h3>Administration Node</h3>") +
          # TRANSLATORS: a help text for the admin node input field
          _("<p>Enter the host name or the IP address of the administration node " \
            "to which this node will be connected to.</p>")
      end

    private

      def role
        ::Installation::SystemRole.current
      end
    end

    # Widget to select and set specific system role options
    class SystemRole < CWM::ComboBox
      ROLE_WIDGETS = {
        "worker_role"    => [:controller_node],
        "dashboard_role" => [:ntp_server]
      }.freeze

      attr_reader :widgets_map

      def initialize(controller_node_widget, ntp_server_widget)
        textdomain "caasp"
        @widgets_map = {
          controller_node: controller_node_widget,
          ntp_server:      ntp_server_widget
        }
      end

      def label
        Yast::ProductControl.GetTranslatedText("roles_caption")
      end

      def opt
        [:hstretch, :notify]
      end

      def init
        self.value = ::Installation::SystemRole.current || default
        handle
      end

      def handle
        to_show = ROLE_WIDGETS.fetch(value, [])
        to_hide = widgets_map.keys - to_show
        to_hide.each { |w| widgets_map[w].hide }
        to_show.each { |w| widgets_map[w].show }
        nil
      end

      def items
        ::Installation::SystemRole.all.map do |role|
          [role.id, role.label]
        end
      end

      def help
        Yast::ProductControl.GetTranslatedText("roles_help") + "\n\n" + roles_help_text
      end

      def store
        log.info "Applying system role '#{value}'"
        role = ::Installation::SystemRole.select(value)

        Yast::ProductFeatures.ClearOverlay
        role.overlay_features
        role.adapt_services
      end

    private

      def roles_help_text
        ::Installation::SystemRole.all.map do |role|
          role.label + "\n\n" + role.description
        end.join("\n\n\n")
      end

      def default
        ::Installation::SystemRole.ids.first
      end
    end
  end
end
