#!/usr/bin/env rspec

require_relative "../../test_helper"
require "cwm/rspec"
require "y2caasp/widgets/container_registry_insecure"

describe Y2Caasp::Widgets::InsecureCheckBox do
  subject(:widget) do
    Y2Caasp::Widgets::InsecureCheckBox.new
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

  describe "#store" do
    it "sets the role registry_insecure property to true if checked" do
      allow(widget).to receive(:checked?).and_return(true)
      widget.store
      expect(role["registry_insecure"]).to eq(true)
    end

    it "sets the role registry_insecure property to false if unchecked" do
      allow(widget).to receive(:checked?).and_return(false)
      widget.store
      expect(role["registry_insecure"]).to eq(false)
    end
  end
end
