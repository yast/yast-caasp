require "digest/sha1"
require "openssl"
require "net/http"

require "yast"
require "cwm/widget"
require "y2caasp/widgets/container_registry_fingerprint"
require "y2caasp/widgets/container_registry_mirror"
require "y2caasp/widgets/container_registry_insecure"
require "y2caasp/widgets/container_registry_verify"
require "installation/system_role"

module Y2Caasp
  # Aggregate dialog for mirror configuration. It allows the user to specify the
  # mirror URL, as well as verify the certificate, should the mirror be served
  # over https
  class AdminRoleMirrorSubDialog
    include Yast::UIShortcuts
    include Yast::I18n
    attr_reader :checkbox, :mirror, :fingerprint, :fingerprint_verify

    def initialize
      @certificate = nil
      @checkbox = Y2Caasp::Widgets::InsecureCheckBox.new
      @mirror = Y2Caasp::Widgets::ContainerRegistryMirror.new
      @fingerprint = Y2Caasp::Widgets::ContainerRegistryFingerprint.new
      @fingerprint_verify = Y2Caasp::Widgets::VerificationButton.new
      @checkbox.observe(method(:handle_insecure_checkbox))
      @fingerprint_verify.observe(method(:handle_certificate_verification))
      textdomain "caasp"
    end

    def contents
      VBox(
        @mirror,
        Left(@checkbox),
        @fingerprint,
        Right(@fingerprint_verify)
      )
    end

    def handle_insecure_checkbox(sender)
      if sender.checked?
        @fingerprint.disable
        @fingerprint_verify.disable
        @mirror.value = @mirror.value.sub("https://", "http://")
      else
        @fingerprint.enable
        @fingerprint_verify.enable
        @mirror.value = @mirror.value.sub("http://", "https://")
      end
    end

    def handle_certificate_verification(_sender)
      secure = @checkbox.unchecked?
      return unless role && secure
      # There is no focus lost event on which to download the certificate, so it
      # might not be available here yet and must be downloaded explicitly
      @mirror.download_certificate if role["registry_certificate"].nil?

      if role["registry_certificate"].verify_sha1_fingerprint(@fingerprint)
        Yast::Popup.Notify(
          # TRANSLATORS: error message for invalid administration node location
          _("The fingerprint matches the downloaded certificate.")
        )
      else
        Yast::Popup.Error(
          # TRANSLATORS: error message for invalid administration node location
          _("The fingerprint does not match the downloaded certificate.")
        )
      end
    end

  private

    # All other widgets have this
    def role
      ::Installation::SystemRole.current_role
    end
  end
end
