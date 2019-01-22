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
require "cfa/chrony_conf"
require "y2caasp/cfa/mirror_conf"

module Y2SystemRoleHandlers
  # Implement finish handler for the "dashboard" role
  class DashboardRoleFinish
    include Yast::Logger

    # Path to the activation script
    ACTIVATION_SCRIPT_PATH = "/usr/share/caasp-container-manifests/activate.sh".freeze

    def run
      run_activation_script
      setup_ntp
      update_registry_conf
    end

  protected

    # Run the activation script
    def run_activation_script
      log.info "Running the activation script"
      Yast::Execute.on_target(ACTIVATION_SCRIPT_PATH)
    end

    # Configure the NTP server
    #
    # @see update_ntp_conf
    def setup_ntp
      return unless role["ntp_servers"]
      log.info "Updating the NTP daemon configuration with servers: #{role["ntp_servers"]}"
      update_chrony_conf
      enable_service
    end

    # Update the chrony.conf file
    #
    # Set the server specified in the role configuration ({ntp_servers})
    def update_chrony_conf
      return unless role["ntp_servers"]
      chrony_conf = CFA::ChronyConf.new
      chrony_conf.load
      chrony_conf.clear_pools
      role["ntp_servers"].each do |server|
        chrony_conf.add_pool(server)
      end
      chrony_conf.save
    end

    def update_registry_conf
      return unless role["registry_setup"]
      mirror_conf = ::Y2Caasp::CFA::MirrorConf.new
      mirror_conf.mirror_url = role["registry_mirror"]
      if role["registry_certificate"]
        mirror_conf.mirror_certificate = role["registry_certificate"].to_pem
        fingerprint = role["registry_fingerprint"]
        mirror_conf.mirror_fingerprint = fingerprint if fingerprint
      end
      mirror_conf.save
    end

    # Add the ntpd service to the list of services to enable
    def enable_service
      enabled = ::Installation::Services.enabled
      enabled << "chronyd" unless enabled.include?("chronyd")
    end

    # Dashboard role
    #
    # @return [::Installation::SystemRole,nil] Dashboard role or nil if not defined.
    def role
      ::Installation::SystemRole.find("dashboard_role")
    end
  end
end
