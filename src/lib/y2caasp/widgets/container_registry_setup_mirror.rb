require "cwm/widget"
require "installation/system_role"

module Y2Caasp
  module Widgets
    class SetupMirrorCheckBox < CWM::CheckBox
      def initialize
        @observers = []
        textdomain "caasp"
      end

      def label
        _("Setup a mirror for the SUSE container registry")
      end

      def help
        _("<h3>Setup a mirror of the SUSE container registry</h3>") +
          _("<p>Enter an alternative container registry that provides the " \
            "container images required to run the CaaS Platform.</p>" \
            "<p>If no mirror is entered the containers will be downloaded from the " \
            "<a href='https://registry.suse.com'>SUSE registry</a>. " \
            "This registry must be accessible from your network.</p>")
      end

      def store
        return unless role
        role["registry_setup"] = checked?
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

      def role
        ::Installation::SystemRole.current_role
      end
    end
  end
end
