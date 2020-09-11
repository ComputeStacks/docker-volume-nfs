module DockerVolumeNfs
  class Volume < Connection

    attr_accessor :id,
                  :labels,
                  :errors


    def initialize(id, labels = {})
      raise VolumeError, 'Missing Volume ID' if id.blank?
      self.id = id
      self.labels = labels
      self.errors = []
    end

    # @return [Boolean]
    def provisioned?
      Docker::Volume.get(id, client).is_a? Docker::Volume
    rescue Docker::Error::NotFoundError
      false
    end

    # @return [Boolean]
    def create!
      raise VolumeError, 'Missing Labels' if labels.empty?
      return true if provisioned?
      unless init_nfs_server!
        errors << "Fatal error provisioning path on storage server" if errors.empty?
        return false
      end
      vol_data = {
        'Labels' => labels,
        'Driver' => 'local',
        'DriverOpts' => {
          'type' => 'nfs',
          'o' => %Q(addr=#{DockerVolumeNfs.config[:nfs_host]},rw,nfsvers=4,async),
          'device' => %Q(:#{volume_path})
        }
      }
      result = Docker::Volume.create(id, vol_data, client)
      return true if result.is_a?(Docker::Volume)
      errors << result.inspect
      false
    end

    # @return [Boolean]
    def destroy!
      obj = Docker::Volume.get(id, client)
      if obj.remove({}, client).blank?
        trash_nfs_path!
      else
        errors << "Error removing volume from docker. Volume still exists on remote server."
        false
      end
    rescue Docker::Error::NotFoundError
      true
    end

    def volume_path
      raise Error, 'Missing NFS Remote Path' if DockerVolumeNfs.config[:nfs_remote_path].count('/').zero?
      %Q(#{DockerVolumeNfs.config[:nfs_remote_path]}/#{id})
    end

    private

    ##
    # Ensure our directory exists on the NFS server
    #
    # @return [Boolean]
    def init_nfs_server!
      remote_exec %Q(mkdir -p #{volume_path})
      true
    rescue => e
      errors << "Fatal error: #{e.message}"
      false
    end

    ##
    # Remove remote directory
    #
    # @return [Boolean]
    def trash_nfs_path!
      remote_exec %Q(rm -rf #{volume_path})
      true
    rescue => e
      errors << "Fatal error: #{e.message}"
      false
    end

  end
end