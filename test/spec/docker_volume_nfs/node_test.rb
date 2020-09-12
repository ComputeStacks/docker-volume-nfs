require 'test_helper'

describe DockerVolumeNfs::Node do

  it 'can connect to docker' do
    VCR.use_cassette('node.online') do
      assert DockerVolumeNfs::Node.new(TestMocks::Node.new).online?
    end
  end

end