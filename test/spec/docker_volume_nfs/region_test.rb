require 'test_helper'

describe DockerVolumeNfs::Region do

  it 'can load usage' do
    VCR.use_cassette('region.usage') do
      refute DockerVolumeNfs::Region.new(TestMocks::Region.new).usage.empty?
    end
  end

end