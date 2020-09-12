module DockerVolumeNfs
  # @!attribute instance
  #   @return [TestMocks::Region]
  class Region

    attr_accessor :instance # ComputeStacks Region Object

    # @param [TestMocks::Region] region
    def initialize(region)
      raise Error, 'Missing region' if region.nil?
      self.instance = region
    end

    # @return [Array]
    def usage
      data = host_client.remote_exec %Q(sudo bash -c 'du --block-size 1024 -s #{instance.nfs_remote_path}/*')
      data.gsub("#{instance.nfs_remote_path}/","").split("\n").map {|i| i.split("\t")}.map {|i,k| {size: i.strip, id: k.strip} }
    rescue
      []
    end

    private

    # @return [DockerVolumeNfs::SshClient]
    def host_client
      DockerVolumeNfs::SshClient.new(
        instance.nfs_remote_host,
        DockerVolumeNfs.config[:region_ssh_user],
        DockerVolumeNfs.config[:region_ssh_port].to_i
      )
    end

  end
end