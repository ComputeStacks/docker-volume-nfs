module DockerVolumeNfs
  # @!attribute hostname
  #   @return [String]
  # @!attribute user
  #   @return [String]
  # @!attribute port
  #   @return [Integer]
  class SshClient

    attr_accessor :hostname,
                  :user,
                  :port

    # @param [String] hostname
    # @param [String] user
    # @param [Integer] port
    def initialize(hostname, user, port)
      self.hostname = hostname
      self.user = user
      self.port = port
    end

    ##
    # Run a given command via SSH
    #
    # @return [String]
    def remote_exec(cmd)
      rsp = ''
      Timeout.timeout(300) do
        ssh = ssh_client
        ssh.exec!(cmd) do |_, _, line|
          rsp += line
        end
        ssh.close
      end
      rsp
    rescue Timeout::Error
      raise SSHError, 'SSH Timeout'
    end

    private

    # @return [Connection::Session]
    def ssh_client
      raise SSHError, 'Missing SSH Key' if DockerVolumeNfs.config[:ssh_key].nil?
      Net::SSH.start(
        hostname,
        user,
        keys: [ DockerVolumeNfs.config[:ssh_key] ],
        user_known_hosts_file: '/dev/null',
        auth_methods: ['publickey'],
        port: port
      )
    rescue Net::SSH::AuthenticationFailed
      raise SSHError, 'SSH Authentication Failed'
    rescue => e
      raise SSHError, "Fatal error: #{e.message}"
    end

  end
end