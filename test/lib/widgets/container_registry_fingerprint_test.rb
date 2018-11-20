#!/usr/bin/env rspec

require_relative "../../test_helper"
require "cwm/rspec"
require "y2caasp/widgets/container_registry_fingerprint"

describe Y2Caasp::Widgets::ContainerRegistryFingerprint do
  subject(:widget) do
    Y2Caasp::Widgets::ContainerRegistryFingerprint.new
  end

  let(:role) do
    Installation::SystemRole.new(
      id: "test_role", order: "100", label: "Test role", description: "Test description"
    )
  end

  before do
    allow(Installation::SystemRole).to receive(:current_role).and_return(role)
  end

  include_examples "CWM::AbstractWidget"

  describe "#init" do
    let(:value) { "A1:B2:C3:D4:E5:F6:A7:B8:C9" }

    it "reads initial value from the current role" do
      allow(role).to receive(:[]).with("registry_fingerprint")
        .and_return(value)
      expect(widget).to receive(:value=).with(value)
      widget.init
    end
  end

  describe "#store" do
    let(:value) { "A1:B2:C3:D4:E5:F6:A7:B8:C9" }

    before do
      allow(widget).to receive(:value).and_return(value)
    end

    it "sets the role registry_fingerprint property" do
      widget.store
      expect(role["registry_fingerprint"]).to eq(value)
    end
  end
end
