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

require "cfa/base_model"
require "cfa/augeas_parser"
require "cfa/matcher"

module Y2Caasp
  module CFA
    # Represents systemd timesyncd config file.
    class SystemdTimesyncd < ::CFA::BaseModel

      # Configuration parser
      PARSER = ::CFA::AugeasParser.new("systemd.lns")
      # Patch to configuration file
      PATH = "/etc/systemd/timesyncd.conf".freeze

      # Constructor
      def initialize(file_handler: nil)
        super(PARSER, PATH, file_handler: file_handler)
      end

      # Sets the NTP variable in [Time] section with the given servers
      #
      # @params [Array<String>] ntp servers to be used by timesyncd
      # @return [Boolean] returns true if added/modified
      def ntp_servers=(servers)
        tree = data["Time"] ||= ::CFA::AugeasTree.new
        ntp_servers = ::CFA::AugeasTree.new

        values = ntp_servers.collection("value")
        servers.each {|s| values.add(s) }

        generic_set("NTP", ntp_servers, tree)
      end
    end
  end
end

