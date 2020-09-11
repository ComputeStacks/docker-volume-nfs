require "active_support"
require "active_support/core_ext/object/blank"
require 'docker'
require 'net/ssh'

require 'docker_volume_nfs/connection'
require 'docker_volume_nfs/errors'
require "docker_volume_nfs/version"
require 'docker_volume_nfs/volume'

module DockerVolumeNfs

  @config = {
    node_address: nil, # tcp://127.0.0.1:3306
    ssh_address: nil, # 127.0.0.1 -- How this plugin will connect to the nfs server.
    ssh_key: nil, # /path/to/ssh/key
    ssh_port: 22,
    ssh_user: 'root',
    nfs_host: '', # Host used to connect from node to nfs server
    nfs_remote_path: ''
  }

  ##
  # Does this use the native Docker::Volume to create the volume?
  #
  # If true, ComputeStacks will use the docker volume API to build
  # this volume.
  #
  def native_docker_volume?
    true
  end

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @config.keys.include? k.to_sym}
  end

  def self.config
    @config
  end

end
