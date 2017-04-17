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
require "yast2/execute"
require "installation/system_role"
require "installation/services"

module Y2SystemRoleHandlers
  # Implement finish handler for the "dashboard" role
  class DashboardRoleFinish
    include Yast::Logger

    # Path to the activation script
    ACTIVATION_SCRIPT_PATH = "/usr/share/caasp-container-manifests/activate.sh".freeze

    def run
      run_activation_script
      set_up_ntp
    end

  protected

    # Run the activation script
    def run_activation_script
      log.info "Running the activation script"
      Yast::Execute.on_target(ACTIVATION_SCRIPT_PATH)
    end

    # NTP server common attributes
    NTP_SERVER_ATTRS = { "type" => "server", "options" => "iburst" }.freeze
    # Restrict options
    NTP_RESTRICT_ATTRS = { "options" => "default kod nomodify notrap nopeer noquery" }.freeze
    # Restrict map
    NTP_RESTRICT_MAP = { "-4" => NTP_RESTRICT_ATTRS, "-6" => NTP_RESTRICT_ATTRS }.freeze

    # Configure the NTP server
    #
    # @see update_ntp_conf
    def set_up_ntp
      return unless role["ntp_servers"]
      log.info "Updating the NTP daemon configuration with servers: #{role["ntp_servers"]}"
      update_ntp_conf
      enable_ntpd_service
    end

    # Update the ntp.conf file
    #
    # * Set the server specified in the role configuration ({ntp_servers})
    # * Add restrict rules to allow queries
    def update_ntp_conf
      Yast.import "NtpClient"
      Yast::NtpClient.Read
      Yast::NtpClient.write_only = true
      Yast::NtpClient.restrict_map = NTP_RESTRICT_MAP
      Yast::NtpClient.ntp_records.reject! { |r| r["type"] == "server" }
      role["ntp_servers"].each do |server|
        Yast::NtpClient.ntp_records << NTP_SERVER_ATTRS.merge("address" => server)
      end
      Yast::NtpClient.Write
    end

    # Add the ntpd service to the list of services to enable
    def enable_ntpd_service
      return if ::Installation::Services.enabled.include?("ntpd")
      ::Installation::Services.enabled.concat(["ntpd"])
    end

    # Dashboard role
    #
    # @return [::Installation::SystemRole,nil] Dashboard role or nil if not defined.
    def role
      ::Installation::SystemRole.find("dashboard_role")
    end
  end
end
