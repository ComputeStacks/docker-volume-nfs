require 'test_helper'

describe DockerVolumeNfs::Volume do

  it 'can manage a volume' do

    vol = DockerVolumeNfs::Volume.new(TestMocks::Volume.new)

    VCR.use_cassette('volume.create') do
      assert vol.create!
    end

    VCR.use_cassette('volume.get') do
      assert vol.provisioned?
    end

    refute_nil vol.usage

    VCR.use_cassette('volume.destroy') do
      assert vol.destroy
    end

  end

end