module TestMocks
  class ContainerService

    attr_accessor :id,
                  :name

    def initialize
      self.id = 1
      self.name = 'test'
    end

    def deployment
      TestMocks::Deployment.new
    end

    def region
      TestMocks::Region.new
    end

  end
end