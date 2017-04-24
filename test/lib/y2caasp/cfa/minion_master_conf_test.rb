#!/usr/bin/env rspec

require_relative "../../../test_helper"
require "y2caasp/cfa/minion_master_conf"
require "cfa/memory_file"

describe Y2Caasp::CFA::MinionMasterConf do
  subject(:config) { Y2Caasp::CFA::MinionMasterConf.new(file_handler: file) }

  let(:content) { File.read(File.join(FIXTURES_PATH, "cfa", "minion.d", "master.conf")) }
  let(:file) { CFA::MemoryFile.new(content) }

  before do
    config.load
  end

  describe "#master" do
    it "returns master server name" do
      expect(config.master).to eq("salt")
    end
  end

  describe "#master=" do
    it "sets the master server name" do
      expect { config.master = "alt" }.to change { config.master }.to("alt")
      expect { config.master = "salt-master" }.to change { config.master }.to("'salt-master'")
      config.save
      expect(file.content.lines).to include("master: 'salt-master'\n")
    end
  end
end
