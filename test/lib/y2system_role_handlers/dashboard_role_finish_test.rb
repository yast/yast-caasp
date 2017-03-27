#! /usr/bin/env rspec

require_relative "../../test_helper"
require "y2system_role_handlers/dashboard_role_finish"

describe Y2SystemRoleHandlers::DashboardRoleFinish do
  subject(:handler) { described_class.new }

  describe "#run" do
    it "runs the activation script" do
      expect(Yast::Execute).to receive(:on_target).with(/activate.sh/)
      handler.run
    end
  end
end
