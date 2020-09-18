module TestMocks
  # @!attribute id
  #   @return [Integer]
  # @!attribute primary_ip
  #   @return [String]
  class Node

    attr_accessor :id,
                  :primary_ip

    def initialize
      self.id = 1
      self.primary_ip = '192.168.173.10'
      # self.primary_ip = "unix:///var/run/docker.sock"
    end

    # @return [TestMocks::Region]
    def region
      TestMocks::Region.new
    end

    # @!attribute [Boolean]
    def online?
      true
    end

  end
end