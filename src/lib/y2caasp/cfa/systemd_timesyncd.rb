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
        tree = data["Time"]
        if !tree
          tree = ::CFA::AugeasTree.new
          data["Time"] = tree
        end

        ntp_servers = ::CFA::AugeasTree.new
        servers.split(" ").each {|s| ntp_servers.add("value[]", s) }

        generic_set("NTP", ntp_servers, tree)
      end
    end
  end
end

