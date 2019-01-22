#! /usr/bin/env rspec

require_relative "../../../test_helper.rb"
require_relative "role_dialog_examples"
require "cwm/rspec"
require "openssl"

require "y2caasp/ssl_certificate"
require "y2caasp/clients/admin_role_mirror_dialog.rb"

Yast.import "CWM"
Yast.import "Lan"
Yast.import "Wizard"

describe ::Y2Caasp::AdminRoleMirrorDialog do
  let(:role) do
    Installation::SystemRole.new(
      id: "test_role", order: "100", label: "Test role", description: "Test description"
    )
  end

  let(:certificate) do
    Y2Caasp::SSLCertificate.new(
      OpenSSL::X509::Certificate.new(File.read(File.join(FIXTURES_PATH, "certificate.pem")))
    )
  end

  describe "#run" do
    before do
      allow(Yast::Wizard).to receive(:CreateDialog)
      allow(Yast::Wizard).to receive(:CloseDialog)
      allow(Yast::CWM).to receive(:show).and_return(:next)
    end

    include_examples "CWM::Dialog"

    context "setting up a registry" do
      it "can disallow all input if no mirror is to be setup" do
        expect(subject.checkbox).to receive(:disable)
        expect(subject.mirror).to receive(:disable)
        expect(subject.fingerprint).to receive(:disable)
        expect(subject.fingerprint_verify).to receive(:disable)
        allow(subject.setup_mirror).to receive(:checked?).and_return(false)
        allow(Installation::SystemRole).to receive(:current_role).and_return(role)
        subject.run
        subject.handle_mirror_setup(subject.setup_mirror)
      end

      it "can allow all input if a mirror is to be setup" do
        expect(subject.checkbox).to receive(:enable)
        expect(subject.mirror).to receive(:enable)
        expect(subject.fingerprint).to receive(:enable)
        expect(subject.fingerprint_verify).to receive(:enable)
        allow(subject.setup_mirror).to receive(:checked?).and_return(true)
        allow(Installation::SystemRole).to receive(:current_role).and_return(role)
        subject.run
        subject.handle_mirror_setup(subject.setup_mirror)
      end
    end

    context "using an insecure registry" do
      it "disables some inputs" do
        # It seems that actual interaction with the widgets will not work in tests.
        # Instead the expected events have to be mocked and tested if they are triggered.
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.fingerprint.widget_id),
          :Enabled,
          false
        )
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.fingerprint_verify.widget_id),
          :Enabled,
          false
        )
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.mirror.widget_id),
          :Value,
          "http://"
        )
        allow(subject.checkbox).to receive(:checked?).and_return(true)
        allow(subject.mirror).to receive(:value).and_return("https://")
        subject.run
        subject.handle_insecure_checkbox(subject.checkbox)
      end
    end

    context "using an secure registry" do
      it "enables some inputs" do
        # It seems that actual interaction with the widgets will not work in tests.
        # Instead the expected events have to be mocked and tested if they are triggered.
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.fingerprint.widget_id),
          :Enabled,
          true
        )
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.fingerprint_verify.widget_id),
          :Enabled,
          true
        )
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.mirror.widget_id),
          :Value,
          "https://"
        )
        allow(subject.checkbox).to receive(:checked?).and_return(false)
        allow(subject.mirror).to receive(:value).and_return("https://")
        subject.run
        subject.handle_insecure_checkbox(subject.checkbox)
      end

      it "can verify a valid registry certificate" do
        expect(Yast::Popup).to receive(:Notify)
        allow(Installation::SystemRole).to receive(:current_role).and_return(role)
        allow(subject.checkbox).to receive(:unchecked?).and_return(true)
        allow(subject.mirror).to receive(:value).and_return("https://test.de")
        allow(subject.fingerprint).to receive(:value).and_return(
          "e75342ccce01f9e7ac3be3341a3a97618c373bb0"
        )
        allow(subject).to receive(:download_certificate) do
          role.tap { |r| r["registry_certificate"] = certificate }
        end
        subject.run
        subject.handle_certificate_verification(nil)
      end

      it "can verify an invalid registry certificate" do
        expect(Yast::Popup).to receive(:Error)
        allow(Installation::SystemRole).to receive(:current_role).and_return(role)
        allow(subject.checkbox).to receive(:unchecked?).and_return(true)
        allow(subject.mirror).to receive(:value).and_return("https://test.de")
        allow(subject.fingerprint).to receive(:value).and_return(
          "wrong fingerprint"
        )
        allow(subject).to receive(:download_certificate) do
          role.tap { |r| r["registry_certificate"] = certificate }
        end
        subject.run
        subject.handle_certificate_verification(nil)
      end
    end
  end
end
