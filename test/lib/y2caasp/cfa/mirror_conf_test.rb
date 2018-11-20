#!/usr/bin/env rspec

require_relative "../../../test_helper"
require "y2caasp/cfa/mirror_conf"
require "cfa/memory_file"

describe Y2Caasp::CFA::MirrorConf do
  subject(:config) { Y2Caasp::CFA::MirrorConf.new }

  let(:content) { File.read(File.join(FIXTURES_PATH, "mirror-conf.yaml")) }
  let(:file) { Tempfile.new }

  before do
    file.write(content)
    file.rewind
  end

  after do
    file.close
  end

  describe "#mirror_url=" do
    it "sets the mirror url" do
      stub_const("::Y2Caasp::CFA::MirrorConf::INSTALL_SYSTEM_PATH", file)
      expect { config.mirror_url = "https://registry.suse.de" }.to change { config.mirror_url }
        .to("https://registry.suse.de")
      config.save
      expect(file.read.lines).to include(/.*- url: https:\/\/registry.suse.de/)
    end
  end

  describe "#mirror_certificate=" do
    it "sets the mirror certificate" do
      stub_const("::Y2Caasp::CFA::MirrorConf::INSTALL_SYSTEM_PATH", file)
      expect { config.mirror_certificate = "test" }.to change { config.mirror_certificate }
        .to("test")
      config.save
      expect(file.read.lines).to include(/.*certificate: test/)
    end
  end

  describe "#mirror_fingerprint=" do
    it "sets the mirror fingerprint" do
      stub_const("::Y2Caasp::CFA::MirrorConf::INSTALL_SYSTEM_PATH", file)
      expect { config.mirror_fingerprint = "test" }.to change { config.mirror_fingerprint }
        .to("test")
      config.save
      content = file.read
      expect(content.lines).to include(/.*fingerprint: test/)
      expect(content.lines).to include(/.*hashalgorithm: SHA1/)
    end
  end
end
