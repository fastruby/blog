require 'dotenv'

module Jekyll
  class EnvironmentVariablesGenerator < Generator
    priority :highest

    # Sets the env variables that we need in the site configuration
    def generate(site)
      Dotenv.load
      site.config['google_analytics'] = ENV['GOOGLE_ANALYTICS_ID']
      site.config['disqus_shortname'] = ENV['DISQUS_SHORTNAME']

      site.config["update_sitemap"] = ENV['UPDATE_SITEMAP'] == "true"

      site.config['fog_provider'] = ENV['FOG_PROVIDER']
      site.config['fog_directory'] = ENV['FOG_DIRECTORY']
      site.config['fog_region'] = ENV['FOG_REGION']
      site.config['fog_url'] = ENV['FOG_URL']
      site.config['fog_store_dir'] = ENV['FOG_STORE_DIR']

      site.config['aws_bucket_url'] = ENV['S3_BUCKET_URL']
      site.config['aws_access_key_id'] = ENV['AWS_ACCESS_KEY_ID']
      site.config['aws_secret_access_key'] = ENV['AWS_SECRET_ACCESS_KEY']
    end
  end
end
