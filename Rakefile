require "yast/rake"

# to manually submit to CaaSP 4.0 run
# YAST_SUBMIT=casp40 rake osc:sr

Yast::Tasks.configuration do |conf|
  # lets ignore license check for now
  conf.skip_license_check << /.*/
end

task "test:unit" => "test:unit:env"

task "test:unit:env" do
  # run tests in English locale (to avoid problems with translations)
  ENV["LC_ALL"] = "en_US.UTF-8"
end
