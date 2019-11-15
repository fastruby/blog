require 'dotenv'

module Jekyll
  class EnvironmentVariablesGenerator < Generator
    priority :highest

    # Sets the env variables that we need in the site configuration
    def generate(site)
      Dotenv.load
      site.config['google_analytics'] = ENV['GOOGLE_ANALYTICS_ID']
      site.config['disqus_shortname'] = ENV['DISQUS_SHORTNAME']
      site.config['convert_kit_form_uid_mobile'] = ENV['CONVERT_KIT_FORM_UID_MOBILE']
      site.config['convert_kit_js_code_mobile'] = ENV['CONVERT_KIT_JS_CODE_MOBILE']
      site.config['convert_kit_page_link_mobile'] = ENV['CONVERT_KIT_PAGE_LINK_MOBILE']
      site.config['convert_kit_form_uid_desktop'] = ENV['CONVERT_KIT_FORM_UID_DESKTOP']
      site.config['convert_kit_js_code_desktop'] = ENV['CONVERT_KIT_JS_CODE_DESKTOP']
    end
  end
end
