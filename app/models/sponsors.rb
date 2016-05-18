class Sponsors
  class << self
    def all
      SponsorsData.values.map { |sponsor| OpenStruct.new(sponsor) }
    end

    def find(identifier)
      OpenStruct.new(SponsorsData[identifier.to_s])
    end
  end
end
