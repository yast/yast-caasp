#!/usr/bin/env rspec

require_relative "../../test_helper"
require "y2caasp/widgets/system_role"

describe Y2Caasp::Widgets::SystemRole do
  subject(:widget) do
    Y2Caasp::Widgets::SystemRole.new(controller_node_widget, ntp_server_widget)
  end

  let(:controller_node_widget) { double("controller_node_widget") }
  let(:ntp_server_widget) { double("ntp_server_widget") }
  let(:test_role) do
    Installation::SystemRole.new(
      id: "test_role", label: "Test role", description: "Test description"
    )
  end

  before do
    allow(Installation::SystemRole).to receive(:all).and_return([test_role])
  end

  describe "#label" do
    before do
      allow(Yast::ProductControl).to receive(:GetTranslatedText)
        .with("roles_caption").and_return("LABEL")
    end

    it "returns the label defined in the product's control file" do
      expect(widget.label).to eq("LABEL")
    end
  end

  describe "#handle" do
    let(:value) { "" }

    before do
      allow(widget).to receive(:value).and_return(value)
    end

    it "returns nil" do
      allow(ntp_server_widget).to receive(:hide)
      allow(controller_node_widget).to receive(:hide)
      expect(widget.handle).to be_nil
    end

    context "when value is 'worker_role'" do
      let(:value) { "worker_role" }

      it "only shows the controller node widget" do
        expect(ntp_server_widget).to receive(:hide)
        expect(controller_node_widget).to receive(:show)
        widget.handle
      end
    end

    context "when value is 'dashboard_role'" do
      let(:value) { "dashboard_role" }

      it "only shows the NTP server widget" do
        expect(ntp_server_widget).to receive(:show)
        expect(controller_node_widget).to receive(:hide)
        widget.handle
      end
    end

    context "when value is not 'worker_role' nor 'dashboard_role'" do
      let(:value) { "none_role" }

      it "hides all widgets" do
        expect(ntp_server_widget).to receive(:hide)
        expect(controller_node_widget).to receive(:hide)
        widget.handle
      end
    end
  end

  describe "#items" do
    it "return a list of roles ids and labels" do
      expect(widget.items).to eq([[test_role.id, test_role.label]])
    end
  end

  describe "#store" do
    before do
      allow(widget).to receive(:value).and_return(test_role.id)
      allow(test_role).to receive(:overlay_features)
      allow(test_role).to receive(:adapt_services)
    end

    it "selects the current role" do
      expect(Installation::SystemRole).to receive(:select).with(test_role.id)
        .and_call_original
      widget.store
    end

    it "overlays role features" do
      expect(test_role).to receive(:overlay_features)
      widget.store
    end

    it "adapts role services" do
      expect(test_role).to receive(:adapt_services)
      widget.store
    end
  end

  describe "#help" do
    before do
      allow(Yast::ProductControl).to receive(:GetTranslatedText).with("roles_help")
        .and_return("help text")
    end

    it "contains role names" do
      expect(widget.help).to match(/help text.+Test role/m)
    end
  end
end
