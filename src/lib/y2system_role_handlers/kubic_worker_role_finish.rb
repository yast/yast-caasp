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
require "y2caasp/cfa/minion_master_conf"

# The kubic_*_finish.rb content is identical, it's only used
# by different system roles. So if you change here something,
# all other files have to be changed, too.

module Y2SystemRoleHandlers
  # Implement finish handler for the "kubic worker" role
  class KubicWorkerRoleFinish
    include Yast::Logger

    def run
      role = ::Installation::SystemRole.current_role

      if !role
        log.warn("Current role not found, not saving the config")
        return
      end

      master = role["kubic_admin_node"]
      log.info("The kubic admin node for this worker role is: #{master}")

      configure_salt_minion(master)
      enable_salt_minion_service
    end

  private

    # Configure Salt minion
    def configure_salt_minion(master)
      master_conf = ::Y2Caasp::CFA::MinionMasterConf.new

      begin
        master_conf.load
      rescue Errno::ENOENT
        log.info("The minion master.conf file does not exist, it will be created")
      end

      # FIXME: the cobblersettings lense does not support dashes in the url
      # without single quotes, we need to use a custom lense for salt conf.
      # As Salt can use also 'url' just use in case of dashed.
      master_conf.master = master
      master_conf.save
    end

    def enable_salt_minion_service
      ::Installation::Services.enabled << "salt-minion"
    end
  end
end
