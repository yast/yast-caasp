#! /usr/bin/env rspec

require_relative "../../test_helper"
require "y2system_role_handlers/dashboard_role_finish"

describe Y2SystemRoleHandlers::DashboardRoleFinish do
  subject(:handler) { described_class.new }

  let(:ntp_server) { "ntp.suse.de" }
  let(:ntp_servers) { [ntp_server] }
  let(:registry_host) { "registry.suse.de" }
  let(:registry_namespace) { "sles12/test" }

  before do
    stub_const("CFA::ChronyConf::PATH", FIXTURES_PATH.join("chrony.conf").to_s)
    allow(CFA::ChronyConf).to receive(:new).and_return(ntp_conf)
    stub_const("::Y2Caasp::CFA::RegistryConf::PATH", FIXTURES_PATH.join("registry-conf.yaml").to_s)
    allow(::Y2Caasp::CFA::RegistryConf).to receive(:new).and_return(registry_conf)
  end

  let(:role) do
    ::Installation::SystemRole.new(id: "dashboard_role", order: "100").tap do |role|
      role["ntp_servers"] = ntp_servers
      role["registry_host"] = registry_host
      role["registry_namespace"] = registry_namespace
    end
  end

  before do
    allow(::Installation::SystemRole).to receive(:find)
      .with("dashboard_role").and_return(role)
    allow(Yast::Execute).to receive(:on_target)
  end

  describe "#run" do
    let(:ntp_conf) { CFA::ChronyConf.new }
    let(:registry_conf) { ::Y2Caasp::CFA::RegistryConf.new }

    before do
      allow(ntp_conf).to receive(:save)
      allow(registry_conf).to receive(:save)
    end

    it "runs the activation script" do
      expect(Yast::Execute).to receive(:on_target).with(/activate.sh/)
      handler.run
    end

    context "when a NTP server is specified" do
      it "adds the server to the configuration" do
        handler.run
        records = ntp_conf.pools
        expect(records.keys).to eq([ntp_server])
        expect(records.values).to eq([{ "iburst" => nil }])
      end

      it "writes the NTP configuration" do
        expect(ntp_conf).to receive(:save)
        handler.run
      end

      it "sets the chronyd service to be enabled" do
        handler.run
        expect(::Installation::Services.enabled).to include("chronyd")
      end
    end

    context "when no NTP server is specified" do
      let(:ntp_servers) { nil }

      it "does not modify NTP configuration" do
        expect(CFA::ChronyConf).to_not receive(:new)
        handler.run
      end
    end

    context "when a registry host and namespace is specified" do
      it "saves the host and namespace to the configuration" do
        expect(registry_conf).to receive(:load)
        expect(registry_conf).to receive(:save)
        handler.run
      end
    end

    context "when neither namespace nor host is specified" do
      let(:registry_host) { nil }
      let(:registry_namespace) { nil }

      it "it leaves the configuration untouched" do
        expect(registry_conf).not_to receive(:load)
        expect(registry_conf).not_to receive(:save)
        handler.run
      end
    end
  end
end
