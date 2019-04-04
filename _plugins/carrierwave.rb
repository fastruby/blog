require "carrierwave/storage/abstract"
require 'carrierwave/utilities'
require 'carrierwave/storage/fog'
require 'carrierwave'

module Jekyll
  class CarrierWaveLoader < Generator
    def generate(site)
      CarrierWave.configure do |config|
        config.cache_dir = "tmp/"
        config.fog_provider = 'fog/aws'
        config.storage = :fog
        config.permissions = 0666
        config.fog_credentials = {
          :provider               => site.config['fog_provider'],
          :aws_access_key_id      => site.config['aws_access_key_id'],
          :aws_secret_access_key  => site.config['aws_secret_access_key'],
        }
        config.fog_directory  = site.config['fog_directory']
        config.store_dir  = site.config['fog_store_dir']
      end
    end
  end
end
