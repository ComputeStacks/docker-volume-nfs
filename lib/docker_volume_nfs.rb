require "active_support"
require "active_support/core_ext/object/blank"
require 'docker'
require 'net/ssh'

require 'docker_volume_nfs/errors'
require 'docker_volume_nfs/node'
require 'docker_volume_nfs/region'
require 'docker_volume_nfs/ssh_client'
require 'docker_volume_nfs/storage_backend'
require "docker_volume_nfs/version"
require 'docker_volume_nfs/volume'

module DockerVolumeNfs

  ##
  # Define settings for the user to provide
  #
  # The order of the fields is determined by their position in the list.
  #
  # Fields:
  #
  # name: must be lower case, no numbers, spaces, or special characters (except _).
  # label: The name of the field shown in the UI
  # description: Displayed under the field to help the user
  # field_type:
  #   * string | Short text field
  #   * text | Textarea
  #   * password | Will store result encrypted and use a password field on the UI
  #   * checkbox | Will display a checkbox and store it as a boolean value
  #   * dropdown | Presents a list of values
  #
  @settings = [
    {
      name: 'ssh_key',
      label: 'SSH Key',
      description: 'Path to SSH Key on server',
      field_type: 'string',
      default: '~/.ssh/id_rsa'
    },
    {
      name: 'region_ssh_user',
      label: 'SSH Username',
      description: 'SSH Username for connecting to the NFS Server',
      field_type: 'string',
      default: 'root'
    },
    {
      name: 'region_ssh_port',
      label: 'SSH Port',
      description: 'SSH Port for connecting to the NFS Server',
      field_type: 'string',
      default: '22'
    }
  ]

  @config = @settings.map { |i| { i[:name].to_sym => i[:default] } }.reduce Hash.new, :merge

  class << self
    ##
    # Is this clustered storage?
    #
    # If true, we will assume all nodes have access to this storage driver.
    # This also means that the Region class will need to define the usage.
    #
    # If false, we assume each node is separate and usage will be calculated per-node.
    # This means that users will be billed for their usage per-node, not per-region.
    #
    def clustered_storage?
      true
    end

    def configure(opts = {})
      opts.each {|k,v| @config[k.to_sym] = v if @config.keys.include? k.to_sym}
    end

    def config
      @config
    end

    def settings
      @settings
    end
  end

end
