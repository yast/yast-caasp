#!/usr/bin/env rspec

require_relative "../../test_helper"
require "cwm/rspec"
require "y2caasp/widgets/container_registry_mirror"
require "y2caasp/ssl_certificate"

describe Y2Caasp::Widgets::ContainerRegistryMirror do
  subject(:widget) do
    Y2Caasp::Widgets::ContainerRegistryMirror.new
  end

  let(:role) do
    Installation::SystemRole.new(
      id: "test_role", order: "100", label: "Test role", description: "Test description"
    )
  end

  before do
    allow(Installation::SystemRole).to receive(:current_role).and_return(role)
    allow(Yast::Popup).to receive(:Error)
  end

  include_examples "CWM::AbstractWidget"

  describe "#init" do
    let(:value) { "https://registry.suse.com" }

    it "reads initial value from the current role" do
      allow(role).to receive(:[]).with("registry_mirror")
        .and_return(value)
      expect(widget).to receive(:value=).with(value)
      widget.init
    end
  end

  describe "#store" do
    before do
      allow(widget).to receive(:value).and_return(value)
      allow(Y2Caasp::SSLCertificate).to receive(:download)
    end

    context "when a valid registry is passed" do
      let(:value) { "https://registry.suse.de" }

      it "sets the role registry_mirror property" do
        widget.store
        expect(role["registry_mirror"]).to eq(value)
      end
    end

    context "when only a http prefix is passed" do
      let(:value) { "http://" }

      it "sets the role registry_mirror property to nil" do
        widget.store
        expect(role["registry_mirror"]).to eq(nil)
      end
    end

    context "when only a https prefix is passed" do
      let(:value) { "https://" }

      it "sets the role registry_mirror property to nil" do
        widget.store
        expect(role["registry_mirror"]).to eq(nil)
      end
    end
  end

  describe "#validate" do
    before do
      allow(widget).to receive(:value).and_return(value)
    end

    context "when a valid http URL is provided" do
      let(:value) { "http://registry.suse.de" }

      it "returns true" do
        expect(widget.validate).to eq(true)
      end
    end

    context "when a valid https URL is provided" do
      let(:value) { "https://registry.suse.de" }

      it "returns true" do
        expect(widget.validate).to eq(true)
      end
    end

    context "when only a http prefix is provided" do
      let(:value) { "http://" }

      it "returns true" do
        expect(widget.validate).to eq(true)
      end
    end

    context "when only a https prefix is provided" do
      let(:value) { "https://" }

      it "returns false" do
        expect(widget.validate).to eq(true)
      end
    end

    context "when an invalid value is provided" do
      let(:value) { "***" }

      it "returns false" do
        expect(widget.validate).to eq(false)
      end

      it "reports the problem to the user" do
        expect(Yast::Popup).to receive(:Error)
        widget.validate
      end
    end

    context "when only a domain name is provided" do
      let(:value) { "registry.suse.de" }

      it "returns true" do
        expect(widget.validate).to eq(true)
      end
    end

    context "when no value is provided" do
      let(:value) { "" }

      it "returns false" do
        expect(widget.validate).to eq(false)
      end

      it "reports the problem to the user" do
        expect(Yast::Popup).to receive(:Error)
        widget.validate
      end
    end
  end
end
