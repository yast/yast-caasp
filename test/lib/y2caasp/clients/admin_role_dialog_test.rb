#! /usr/bin/env rspec

require_relative "../../../test_helper.rb"
require_relative "role_dialog_examples"
require "cwm/rspec"
require "openssl"

require "y2caasp/ssl_certificate"
require "y2caasp/clients/admin_role_dialog.rb"

Yast.import "CWM"
Yast.import "Lan"
Yast.import "Wizard"

describe ::Y2Caasp::AdminRoleDialog do
  let(:role) do
    Installation::SystemRole.new(
      id: "test_role", order: "100", label: "Test role", description: "Test description"
    )
  end

  describe "#run" do
    let(:ntp_servers) { [] }

    before do
      allow(Yast::Wizard).to receive(:CreateDialog)
      allow(Yast::Wizard).to receive(:CloseDialog)
      allow(Yast::CWM).to receive(:show).and_return(:next)
      allow(Yast::Lan).to receive(:ReadWithCacheNoGUI)
      allow(Yast::LanItems).to receive(:dhcp_ntp_servers).and_return({})
      allow(Yast::ProductFeatures).to receive(:GetBooleanFeature)
    end

    include_examples "CWM::Dialog"
    include_examples "NTP from DHCP"

    # Note: this is a hypothetical test, in real CaaSP the default NTP setup
    # is currently disabled in control.xml
    context "no NTP server set in DHCP and default NTP is enabled in control.xml" do
      before do
        allow(Yast::ProductFeatures).to receive(:GetBooleanFeature)
          .with("globals", "default_ntp_setup").and_return(true)
        allow(Yast::Product).to receive(:FindBaseProducts)
          .and_return(["name" => "CAASP"])
      end

      it "proposes to use a random novell pool server" do
        expect(Y2Caasp::Widgets::NtpServer).to receive(:new).and_wrap_original do |original, arg|
          expect(arg.first).to match(/\A[0-3]\.novell\.pool\.ntp\.org\z/)
          original.call(arg)
        end
        subject.run
      end
    end

    context "using an insecure registry" do
      it "disables some inputs" do
        # It seems that actual interaction with the widgets will not work in tests.
        # Instead the expected events have to be mocked and tested if they are triggered.
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.subdialog.fingerprint.widget_id),
          :Enabled,
          false
        )
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.subdialog.fingerprint_verify.widget_id),
          :Enabled,
          false
        )
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.subdialog.mirror.widget_id),
          :Value,
          "http://"
        )
        allow(subject.subdialog.checkbox).to receive(:checked?).and_return(true)
        allow(subject.subdialog.mirror).to receive(:value).and_return("https://")
        subject.run
        subject.subdialog.handle_insecure_checkbox(subject.subdialog.checkbox)
      end
    end

    context "using an secure registry" do
      it "enables some inputs" do
        # It seems that actual interaction with the widgets will not work in tests.
        # Instead the expected events have to be mocked and tested if they are triggered.
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.subdialog.fingerprint.widget_id),
          :Enabled,
          true
        )
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.subdialog.fingerprint_verify.widget_id),
          :Enabled,
          true
        )
        expect(Yast::UI).to receive(:ChangeWidget).with(
          Id(subject.subdialog.mirror.widget_id),
          :Value,
          "https://"
        )
        allow(subject.subdialog.checkbox).to receive(:checked?).and_return(false)
        allow(subject.subdialog.mirror).to receive(:value).and_return("https://")
        subject.run
        subject.subdialog.handle_insecure_checkbox(subject.subdialog.checkbox)
      end

      it "can verify a valid registry certificate" do
        expect(Yast::Popup).to receive(:Notify)
        allow(Installation::SystemRole).to receive(:current_role).and_return(role)
        allow(subject.subdialog.checkbox).to receive(:unchecked?).and_return(true)
        allow(subject.subdialog.mirror).to receive(:value).and_return("https://test.de")
        allow(subject.subdialog.fingerprint).to receive(:value).and_return(
          "e75342ccce01f9e7ac3be3341a3a97618c373bb0"
        )
        allow(Y2Caasp::SSLCertificate).to receive(:download).and_return(
          Y2Caasp::SSLCertificate.new(
            OpenSSL::X509::Certificate.new(File.read(File.join(FIXTURES_PATH, "certificate.pem")))
          )
        )
        subject.run
        subject.subdialog.handle_certificate_verification(nil)
      end

      it "can verify an invalid registry certificate" do
        expect(Yast::Popup).to receive(:Error)
        allow(Installation::SystemRole).to receive(:current_role).and_return(role)
        allow(subject.subdialog.checkbox).to receive(:unchecked?).and_return(true)
        allow(subject.subdialog.mirror).to receive(:value).and_return("https://test.de")
        allow(subject.subdialog.fingerprint).to receive(:value).and_return(
          "wrong fingerprint"
        )
        allow(Y2Caasp::SSLCertificate).to receive(:download).and_return(
          Y2Caasp::SSLCertificate.new(
            OpenSSL::X509::Certificate.new(File.read(File.join(FIXTURES_PATH, "certificate.pem")))
          )
        )
        subject.run
        subject.subdialog.handle_certificate_verification(nil)
      end

      it "can disallow all input if no mirror is to be setup" do
        expect(subject.subdialog.checkbox).to receive(:disable)
        expect(subject.subdialog.mirror).to receive(:disable)
        expect(subject.subdialog.fingerprint).to receive(:disable)
        expect(subject.subdialog.fingerprint_verify).to receive(:disable)
        allow(subject.subdialog.setup_mirror).to receive(:checked?).and_return(false)
        allow(Installation::SystemRole).to receive(:current_role).and_return(role)
        subject.run
        subject.subdialog.handle_mirror_setup(subject.subdialog.setup_mirror)
      end

      it "can allow all input if a mirror is to be setup" do
        expect(subject.subdialog.checkbox).to receive(:enable)
        expect(subject.subdialog.mirror).to receive(:enable)
        expect(subject.subdialog.fingerprint).to receive(:enable)
        expect(subject.subdialog.fingerprint_verify).to receive(:enable)
        allow(subject.subdialog.setup_mirror).to receive(:checked?).and_return(true)
        allow(Installation::SystemRole).to receive(:current_role).and_return(role)
        subject.run
        subject.subdialog.handle_mirror_setup(subject.subdialog.setup_mirror)
      end
    end
  end
end
