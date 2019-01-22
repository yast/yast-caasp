require "digest/sha1"
require "openssl"
require "net/http"

require "yast"
require "cwm/widget"
require "y2caasp/ssl_certificate"
require "y2caasp/widgets/container_registry_fingerprint"
require "y2caasp/widgets/container_registry_mirror"
require "y2caasp/widgets/container_registry_setup_mirror"
require "y2caasp/widgets/container_registry_insecure"
require "y2caasp/widgets/container_registry_verify"
require "installation/system_role"

module Y2Caasp
  # Aggregate dialog for mirror configuration. It allows the user to specify the
  # mirror URL, as well as verify the certificate, should the mirror be served
  # over https
  class AdminRoleMirrorDialog < CWM::Dialog
    include Yast::UIShortcuts
    include Yast::I18n
    attr_reader :checkbox, :mirror, :fingerprint, :fingerprint_verify, :setup_mirror

    def initialize
      @certificate = nil
      @setup_mirror = Y2Caasp::Widgets::SetupMirrorCheckBox.new
      @checkbox = Y2Caasp::Widgets::InsecureCheckBox.new
      @mirror = Y2Caasp::Widgets::ContainerRegistryMirror.new
      @fingerprint = Y2Caasp::Widgets::ContainerRegistryFingerprint.new
      @fingerprint_verify = Y2Caasp::Widgets::VerificationButton.new
      # Setup callbacks that modify related widgets on certain events
      @setup_mirror.observe(method(:handle_mirror_setup))
      @checkbox.observe(method(:handle_insecure_checkbox))
      @fingerprint_verify.observe(method(:handle_certificate_verification))
      # Start with all widgets disabled - the default should be to use the SUSE registry

      textdomain "caasp"
    end

    def contents
      VBox(
        Left(@setup_mirror),
        @mirror,
        Left(@checkbox),
        @fingerprint,
        Right(@fingerprint_verify)
      )
    end

    def run
      ret = super()
      if ret == :next
        ensure_url_prefix
        download_certificate
      end
      ret
    end

    def handle_mirror_setup(sender)
      if sender.checked?
        enable
      else
        disable
      end
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

      download_certificate

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

    # Enable all widgets to setup a mirror
    def enable
      @checkbox.enable
      @mirror.enable
      @fingerprint.enable
      @fingerprint_verify.enable
    end

    # Disable all widgets to setup a mirror
    def disable
      @checkbox.disable
      @mirror.disable
      @fingerprint.disable
      @fingerprint_verify.disable
    end

    # Ensure that the mirror the customer entered, starts with the correct prefix,
    # based on `secure` or `non-secure` selection.
    # This is required as the customer can remove the prefix from the textfield and
    # enter the incorrect one.
    def ensure_url_prefix
      # If no registry is to be setup we don't need to fix the URL
      return unless role && role["registry_setup"]
      secure = role["registry_secure"]
      prefix = secure ? "https://" : "http://"
      url = role["registry_mirror"].gsub(/https?:\/\//, "")
      role["registry_mirror"] = prefix + url
    end

    def download_certificate
      return unless role && !role["registry_insecure"] && role["registry_mirror"]
      role["registry_certificate"] = SSLCertificate.download(role["registry_mirror"])
    end

    # All other widgets have this
    def role
      ::Installation::SystemRole.current_role
    end
  end
end
