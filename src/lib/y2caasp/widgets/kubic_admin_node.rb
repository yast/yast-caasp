# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2019 SUSE LLC
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
require "installation/system_role"

Yast.import "IP"
Yast.import "Hostname"

module Y2Caasp
  module Widgets
    # This widget is responsible of validate and store the introduced location
    # which must be a valid IP or FQDN.
    # bsc#1032057: old name: Controller Node, new name: Administration Node.
    class KubicAdminNode < CWM::InputField
      def initialize
        textdomain "caasp"
      end

      def label
        _("Kubic Admin Node")
      end

      def help
        # TRANSLATORS: a help text for the kubic admin node input field
        _("<h3>The Kubic Admin Node</h3>") +
          # TRANSLATORS: a help text for the kubic admin node input field
          _("<p>Enter the host name or the IP address of the kubic admin node " \
              "to which this machine will be connected to.</p>")
      end

      # It stores the value of the input field if validates
      #
      # @see #validate
      def store
        # this is a role widget so a role must be selected before saving
        raise("No role selected") unless role
        role["kubic_admin_node"] = value
      end

      # The input field is initialized with previous stored value
      def init
        self.value = role["kubic_admin_node"] if role
      end

      # It returns true if the value is a valid IP or a valid FQDN, if not it
      # displays a popup error.
      #
      # @return [Boolean] true if valid IP or FQDN
      def validate
        return true if Yast::IP.Check(value) || Yast::Hostname.CheckFQ(value)

        Yast::Popup.Error(
          # TRANSLATORS: error message for invalid administration node location
          _("Not valid location for the kubic admin node, " \
          "please enter a valid IP or Hostname")
        )

        false
      end

    private

      def role
        ::Installation::SystemRole.current_role
      end
    end
  end
end
