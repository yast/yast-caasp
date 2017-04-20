#! /usr/bin/env rspec

require_relative "../../../test_helper"
require "y2caasp/cfa/systemd_timesyncd"
require "cfa/memory_file"


def timesyncd_disk_content
  File.read(path)
end

describe Y2Caasp::CFA::SystemdTimesyncd do
  subject(:timesyncd) { Y2Caasp::CFA::SystemdTimesyncd.new(file_handler: file) }

  let(:content) { File.read(File.join(FIXTURES_PATH, "cfa", "timesyncd")) }
  let(:file) { CFA::MemoryFile.new(content) }


  describe "#ntp_servers=" do
    it "sets the given ntp servers in the 'NTP' variable under 'Time' section " do
      timesyncd.load
      timesyncd.ntp_servers = "master"
      timesyncd.save

      expect(file.content).to include(
        "[Time]\n"     \
        "NTP=master\n" \
        "#FallbackNTP=ntp1.opensuse.org ntp2.opensuse.org\n"
      )
    end
  end
end
