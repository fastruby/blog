require 'dotenv'

module Jekyll
  class EnvironmentVariablesGenerator < Generator
    priority :highest
    
    # Sets the env variables that we need in the site configuration
    def generate(site)
      Dotenv.load
      site.config['google_analytics'] = ENV['GOOGLE_ANALYTICS_ID']
      site.config['disqus_shortname'] = ENV['DISQUS_SHORTNAME']
    end
  end
end
