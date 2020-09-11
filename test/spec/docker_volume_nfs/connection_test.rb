require 'test_helper'

describe DockerVolumeNfs::Connection do

  it 'can connect to docker' do
    VCR.use_cassette('connection.online') do
      assert DockerVolumeNfs::Connection.new.online?
    end
  end

  it 'can determine volume usage' do
    refute_empty DockerVolumeNfs::Connection.new.usage
  end

end