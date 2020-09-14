require 'test_helper'

describe DockerVolumeNfs::Region do

  it 'can load usage' do
    VCR.use_cassette('region.usage') do
      refute DockerVolumeNfs::Region.new(TestMocks::Region.new).usage.empty?
    end
  end

  it 'can list available volumes' do
    r = TestMocks::Region.new
    # Temp setting to docker volume path to ensure we get a real list of volumes.
    r.nfs_remote_path = '/var/lib/docker/volumes'
    assert_kind_of Array, DockerVolumeNfs::Region.new(r).list_all_volumes
  end

end