require "cwm/widget"
require "installation/system_role"

module Y2Caasp
  module Widgets
    # Button that will trigger verification of the certificate by firing an event
    # to observers that can collect the required data for that.
    class VerificationButton < CWM::PushButton
      def initialize
        @observers = []
        textdomain "caasp"
        super()
      end

      def label
        _("Verify")
      end

      def handle
        @observers.each { |o| o.call(self) }
        nil
      end

      def observe(observer)
        @observers << observer
      end

      def opt
        [:notify]
      end

    private

      # All other widgets have this
      def role
        ::Installation::SystemRole.current_role
      end
    end
  end
end
