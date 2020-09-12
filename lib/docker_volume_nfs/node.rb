module DockerVolumeNfs
  # @!attribute instance
  #   @return [TestMocks::Node]
  class Node

    attr_accessor :instance # ComputeStacks Node

    # @param [TestMocks::Node] instance
    def initialize(instance)
      self.instance = instance
    end

    def usage
      raise Error, 'Not used'
    end

    def online?
      Docker.ping(client) == 'OK'
    end

    ##
    # Provide a Docker Client
    #
    # @return [Docker::Connection]
    def client
      opts = Docker.connection.options
      opts[:connect_timeout] = 15
      opts[:read_timeout] = 75
      opts[:write_timeout] = 75
      Docker::Connection.new(connection_string, opts)
    end

    private

    ##
    # Allow setting the primary_ip to a unix socket
    #
    # @return [String]
    def connection_string
      instance.primary_ip.split('://')[0] == 'unix' ? instance.primary_ip : "tcp://#{instance.primary_ip}:2376"
    end

  end
end
