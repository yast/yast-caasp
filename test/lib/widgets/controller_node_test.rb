#!/usr/bin/env rspec

require_relative "../../test_helper"
require "y2caasp/widgets/controller_node"

describe Y2Caasp::Widgets::ControllerNode do
  subject(:widget) do
    Y2Caasp::Widgets::ControllerNode.new
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

  describe "#label" do
    it "returns a String" do
      expect(widget.label).to be_a(String)
    end
  end

  describe "#help" do
    it "returns a help text" do
      expect(widget.help).to be_a(String)
    end
  end

  describe "#init" do
    let(:value) { "server1" }

    it "reads initial value from the current role" do
      allow(role).to receive(:[]).with("controller_node")
        .and_return(value)
      expect(widget).to receive(:value=).with(value)
      widget.init
    end
  end

  describe "#store" do
    let(:value) { "server1" }

    before do
      allow(widget).to receive(:value).and_return(value)
    end

    it "sets the role controller_node property" do
      widget.store
      expect(role["controller_node"]).to eq(value)
    end
  end

  describe "#validate" do
    before do
      allow(widget).to receive(:value).and_return(value)
    end

    context "when a valid IP address is provided" do
      let(:value) { "192.168.122.1" }

      it "returns true" do
        expect(widget.validate).to eq(true)
      end
    end

    context "when a valid hostname is provided" do
      let(:value) { "server.example.com" }

      it "returns true" do
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
