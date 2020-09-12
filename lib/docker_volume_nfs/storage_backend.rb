module DockerVolumeNfs
  ##
  # Provides access to the NFS Server
  #
  # @!attribute errors
  #   @return [Array]
  # @!attribute ip_address
  #   @return [String]
  # @!attribute ssh_port
  #   @return [Integer]
  class StorageBackend

    attr_accessor :errors,
                  :ip_address,
                  :ssh_port

    # @param [String] ipaddr
    # @param [Integer] ssh_port
    def initialize(ipaddr, ssh_port = 22)
      raise Error, 'Missing IP Address for node' if ipaddr.blank?
      self.ip_address = ipaddr
      self.ssh_port = ssh_port
      self.errors = []
    end

    # @return [Boolean]
    def online?
      !host_client.remote_exec('date').blank?
    end

    # @param [String]
    # @return [Boolean]
    def initialize_storage_backend!(volume_path)
      host_client.remote_exec %Q(mkdir -p #{volume_path})
      true
    rescue => e
      errors << "Fatal error: #{e.message}"
      false
    end

    # @param [String]
    # @return [Boolean]
    def purge_volume_path!(volume_path)
      host_client.remote_exec %Q(rm -rf #{volume_path})
      true
    rescue => e
      errors << "Fatal error: #{e.message}"
      false
    end

    private

    # @return [DockerVolumeNfs::SshClient]
    def host_client
      DockerVolumeNfs::SshClient.new(ip_address, 'root', ssh_port)
    end

  end
end