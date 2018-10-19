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
require "installation/system_role"
require "installation/services"
require "cfa/chrony_conf"

module Y2SystemRoleHandlers
  # Implement finish handler for the "kubeadm" role
  class KubeadmRoleFinish
    include Yast::Logger

    def run
      setup_ntp
    end

  protected

    # Configure the NTP server
    #
    # @see update_ntp_conf
    def setup_ntp
      return unless role && role["ntp_servers"]
      log.info "Updating the NTP daemon configuration with servers: #{role["ntp_servers"]}"
      update_chrony_conf
      enable_service
    end

    # Update the chrony.conf file
    #
    # Set the server specified in the role configuration ({ntp_servers})
    def update_chrony_conf
      chrony_conf = CFA::ChronyConf.new
      chrony_conf.load
      chrony_conf.clear_pools
      role["ntp_servers"].each do |server|
        chrony_conf.add_pool(server)
      end
      chrony_conf.save
    end

    # Add the ntpd service to the list of services to enable
    def enable_service
      enabled = ::Installation::Services.enabled
      enabled << "chronyd" unless enabled.include?("chronyd")
    end

    # Dashboard role
    #
    # @return [::Installation::SystemRole,nil] The current role or nil if not selected.
    def role
      ::Installation::SystemRole.current_role
    end
  end
end
