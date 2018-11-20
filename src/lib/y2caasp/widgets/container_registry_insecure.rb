require "cwm/widget"
require "installation/system_role"

module Y2Caasp
  module Widgets
    # Render a checkbox that allows the user to enter an insecure registry.
    class InsecureCheckBox < CWM::CheckBox
      def initialize
        @observers = []
        textdomain "caasp"
        super()
      end

      def label
        _("Use an insecure registry (http)?")
      end

      def store
        return unless role
        role["registry_insecure"] = checked?
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
