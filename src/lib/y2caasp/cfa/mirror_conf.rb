require "yast"
require "yaml"

module Y2Caasp
  module CFA
    # This class stores the mirror configuration in a yaml file for use in
    # Velum. This file is required, as Velum needs to copy these mirrors into
    # the database, so they can be distributed throughout the cluster. This file
    # is also used as the input to a service that will generate a `daemon.json`
    # file from it.
    #
    # A configuration file example can be found here:
    # https://github.com/kubic-project/kubic-init/blob/master/config/kubic-init.yaml
    class MirrorConf
      attr_reader :mirror_url, :mirror_certificate, :mirror_fingerprint
      PATH = "/etc/kubic/kubic-init.yaml".freeze
      INSTALL_SYSTEM_PATH = File.join(Yast::Installation.destdir, PATH)

      # This class needs to be initialized with a valid docker config
      # (MirrorConf.data) that contains a configured mirror
      def initialize
        @config = { "apiVersion" => "kubic.suse.com/v1alpha2",
                    "kind"       => "KubicInitConfiguration" }
        if File.exist?(INSTALL_SYSTEM_PATH)
          content = File.read(INSTALL_SYSTEM_PATH)
          @config = YAML.safe_load(content)
        end
      end

      def mirror_url=(mirror_url)
        @mirror_url = mirror_url
        update_data
      end

      def mirror_certificate=(mirror_certificate)
        @mirror_certificate = mirror_certificate
        update_data
      end

      def mirror_fingerprint=(mirror_fingerprint)
        @mirror_fingerprint = mirror_fingerprint
        @mirror_hashalgorithm = "SHA1"
        update_data
      end

      def save
        destination = File.join(INSTALL_SYSTEM_PATH)
        directory = File.dirname(destination)
        ::FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
        File.open(destination, "w") { |f| f.write(@config.to_yaml) }
      end

    private

      # TODO: This should do a deep-merge to not overwrite already existing registries
      def update_data
        tgt_data = {
          "bootstrap" => {
            "registries" => [{
              "prefix"  => "https://registry.suse.com",
              "mirrors" => [
                {
                  "url"           => @mirror_url,
                  "certificate"   => @mirror_certificate,
                  "fingerprint"   => @mirror_fingerprint,
                  "hashalgorithm" => @mirror_hashalgorithm
                }
              ]
            }]
          }
        }
        @config.merge!(tgt_data)
      end
    end
  end
end
