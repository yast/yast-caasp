require "cfa/base_model"
require "cfa/augeas_parser"
require "cfa/matcher"

module Y2Caasp
  module CFA
    class SystemdTimesyncd < ::CFA::BaseModel
      PARSER = ::CFA::AugeasParser.new("systemd.lns")

      PATH = "/etc/systemd/timesyncd.conf".freeze

      def initialize(file_handler: nil)
        super(PARSER, PATH, file_handler: file_handler)
      end

      def ntp_servers=(servers = "")
        data["Time"] ||= ::CFA::AugeasTree.new
        tree = data["Time"]

        ntp_servers = ::CFA::AugeasTree.new

        values = ntp_servers.collection("value")
        servers.split(" ").each {|s| values.add(s) }

        generic_set("NTP", ntp_servers, tree)
      end
    end
  end
end

