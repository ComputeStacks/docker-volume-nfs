module TestMocks
  # @!attribute id
  #   @return [Integer]
  # @!attribute nfs_remote_path
  #   @return [String]
  # @!attribute nfs_remote_host
  #   @return [String]
  class Region

    attr_accessor :id,
                  :nfs_remote_path,
                  :nfs_remote_host

    def initialize
      self.id = 1
      self.nfs_remote_path = "/tmp"
      self.nfs_remote_host = "192.168.173.10"
    end

    # @return [Array]
    def nodes
      [
        TestMocks::Node.new
      ]
    end

  end
end