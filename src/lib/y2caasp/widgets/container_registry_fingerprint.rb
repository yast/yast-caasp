require "cwm/widget"
require "installation/system_role"

module Y2Caasp
  module Widgets
    # Allow user to enter the fingerprint of the mirror's certificate, to verify the
    # correct certificate was retrieved from the configure mirror.
    class ContainerRegistryFingerprint < CWM::InputField
      def initialize
        textdomain "caasp"
        super()
      end

      # The input field is initialized with previous stored value
      def init
        self.value = if role && role["registry_fingerprint"]
          role["registry_fingerprint"]
        else
          ""
        end
      end

      def label
        _("SHA1 fingerprint of HTTPS certificate")
      end

      def help
        _("<p>The fingerprint is used to verify the https-certificate of the registry mirror.</p>")
      end

      def store
        return unless role
        role["registry_fingerprint"] = value
      end

      def opt
        [:disabled]
      end

    private

      # All other widgets have this
      def role
        ::Installation::SystemRole.current_role
      end
    end
  end
end
