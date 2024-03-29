module DockerVolumeNfs
  # @!attribute errors
  #   @return [Array]
  # @!attribute instance
  #   @return [TestMocks::Volume]
  class Volume

    attr_accessor :errors,
                  :instance

    # @param [TestMocks::Volume]
    def initialize(instance)
      self.instance = instance
      self.errors = []
    end

    # @return [Boolean]
    def provisioned?
      result = true
      instance.nodes.each do |node|
        next unless node.online?
        result = docker_client(node).is_a?(Docker::Volume)
        break unless result # halt if failed
      end
      result
    end

    # @return [Boolean]
    def create!
      raise VolumeError, 'Missing Volume' if instance.nil?
      unless storage_server.initialize_storage_backend!(volume_path)
        errors << "Fatal error provisioning NFS backend"
        return false
      end
      instance.nodes.each do |node|
        next unless node.online?
        next unless docker_client(node).nil?
        result = Docker::Volume.create(instance.name, volume_data, DockerVolumeNfs::Node.new(node).client)
        unless result.is_a?(Docker::Volume)
          errors << "Fatal error provisioning volume on node: #{node.label}"
          return false
        end
      end
      errors.empty?
    end

    # @return [Boolean]
    def destroy
      success = true
      instance.nodes.each do |node|
        next unless node.online?
        client = DockerVolumeNfs::Node.new(node).client
        vol_client = docker_client(node)
        next if vol_client.nil?
        success = vol_client.remove({}, client).blank?
        break unless success
      end
      unless success
        errors << "Error removing volume from docker. Volume still exists on remote server."
        return false
      end
      storage_server.purge_volume_path!(volume_path)
    rescue Docker::Error::NotFoundError
      true
    end

    ##
    # Returns the volume usage in KB.
    def usage
      storage_server.usage_for_volume self
    rescue
      nil
    end

    # @return [String]
    def volume_path
      %Q(#{instance.region.nfs_remote_path}/#{instance.name})
    end

    private

    # @return [Hash]
    def volume_data
      {
        'Labels' => {
          'name' => instance.name,
          'deployment_id' => instance.deployment.id.to_s,
          'service_id' => instance.container_service.id.to_s
        },
        'Driver' => 'local',
        'DriverOpts' => {
          'type' => 'nfs',
          'o' => %Q(addr=#{instance.region.nfs_remote_host},rw,nfsvers=4,async),
          'device' => %Q(:#{volume_path})
        }
      }
    end

    # @return [DockerVolumeNfs::StorageBackend]
    def storage_server
      ip_addr = instance.region.nfs_controller_ip.blank? ? instance.region.nfs_remote_host : instance.region.nfs_controller_ip
      DockerVolumeNfs::StorageBackend.new(ip_addr)
    end

    # @return [Docker::Volume]
    def docker_client(node)
      Docker::Volume.get(instance.name, DockerVolumeNfs::Node.new(node).client)
    rescue Docker::Error::NotFoundError
      nil
    end

  end
end