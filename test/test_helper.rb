require "minitest/autorun"
require "minitest/spec"
require "minitest/reporters"
require "vcr"
require "docker_volume_nfs"

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr"
  config.hook_into :excon # Excon is loaded by docker-api.
end

DockerVolumeNfs.configure(
  node_address: "unix:///var/run/docker.sock",
  ssh_address: "192.168.173.10",
  ssh_key: "~/.ssh/id_rsa",
  nfs_host: "192.168.173.10",
  nfs_remote_path: "/tmp"
)

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
