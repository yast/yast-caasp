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

require "yast"
require "cwm/widget"
require "installation/system_role"

require "y2caasp/ssl_certificate"

module Y2Caasp
  module Widgets
    # This widget is responsible to validate and store the registry mirror.
    # The host must be a valid IP of FQDN.
    class ContainerRegistryMirror < CWM::InputField
      attr_reader :default_host

      def initialize(default_host = "https://")
        @default_host = default_host
        textdomain "caasp"
      end

      def label
        _("Mirror of the SUSE container registry")
      end

      # It stores the value of the input field if validates
      #
      # @see #validate
      def store
        # this is a role widget so a role must be selected before saving
        raise("No role selected") unless role

        role["registry_mirror"] = value unless empty_url(value)
        download_certificate
      end

      # The input field is initialized with previous stored value
      def init
        self.value = if role && role["registry_mirror"]
          role["registry_mirror"]
        else
          @default_host
        end
      end

      # It returns true if the value is a valid URL, if not it
      # displays a popup error.
      #
      # @return [Boolean] true if valid URL
      def validate
        return true if Yast::URL.Check(value)

        Yast::Popup.Error(
          # TRANSLATORS: error message for invalid administration node location
          _("Not a valid location for the mirror, please enter a valid URL")
        )

        false
      end

      def download_certificate
        return if empty_url(value)
        role["registry_certificate"] = SSLCertificate.download(value)
      end

      def opt
        [:disabled]
      end

    private

      def empty_url(value)
        !(/^https?:\/\/$/ =~ value).nil?
      end

      # All other widgets have this
      def role
        ::Installation::SystemRole.current_role
      end
    end
  end
end
