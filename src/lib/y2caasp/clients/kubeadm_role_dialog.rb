require "yast"

# so far the Kubic dialog is the same as in CaaSP,
# just with different title and defaults
require "y2caasp/clients/admin_role_dialog"

module Y2Caasp
  # This library provides a simple dialog for setting
  # the kubeadm role specific settings:
  #   - the NTP server names
  class KubeadmRoleDialog < AdminRoleDialog
    def initialize
      textdomain "caasp"
      super
    end

    #
    # The dialog title
    #
    # @return [String] the title
    #
    def title
      # TRANSLATORS: dialog title
      _("kubeadm node configuration")
    end

  protected

    def ntp_fallback
      # propose random pool server in range 0..3 if not set via DHCP
      "#{rand(4)}.opensuse.pool.ntp.org"
    end
  end
end
