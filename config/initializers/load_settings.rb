require 'ostruct'

settings = YAML.load_file(Rails.root.join('config', 'settings.yml'))[Rails.env]
AppSettings = OpenStruct.new(settings) unless defined?(AppSettings)

::SponsorsData = YAML.load_file(Rails.root.join('config', 'sponsors.yml'))
