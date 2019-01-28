require "titleize"

module Jekyll
  module TitleizeFilter
    def titleize(input)
      input.titleize
    end
  end
end

Liquid::Template.register_filter(Jekyll::TitleizeFilter)
