require "openssl"
require "digest/sha1"

module Y2Caasp
  # Small wrapper around openssl::X509::Certificate to allow verifying the SHA1
  # fingerprint.
  class SSLCertificate
    attr_reader :certificate

    # @param certificate [OpenSSL::X509::Certificate] pem text of a certificate
    def initialize(certificate)
      @certificate = certificate
    end

    # Verify that the certificate's fingerprint matches the passed fingerprint
    #
    # @param fingerprint [String] the SHA1 fingerprint of the certificate
    def verify_sha1_fingerprint(fingerprint)
      certificate_checksum = Digest::SHA1.hexdigest(@certificate.to_der)
      normalize_fingerprint(fingerprint) == certificate_checksum
    end

    def to_pem
      @certificate.nil? ? "" : @certificate.to_pem
    end

    def to_der
      @certificate.nil? ? "" : @certificate.to_der
    end

    class << self
      def download(url)
        ctx = OpenSSL::SSL::SSLContext.new
        sock = TCPSocket.new(url.gsub(/^https?:\/\//, ""), 443)
        ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
        begin
          ssl.connect
          return SSLCertificate.new(ssl.peer_cert)
        rescue OpenSSL::SSL::SSLError
          # If we can't download the certificate we just pretend to have an
          # empty one. This could also use a special null-object subclass of
          # SSLCertificate
          return SSLCertificate.new(nil)
        end
      end
    end

  private

    def normalize_fingerprint(fingerprint)
      fingerprint.value.downcase.delete(":")
    end
  end
end
