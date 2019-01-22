module Jekyll
  class Post
    # override post method in order to return categories names as slug
    # instead of strings
    #
    # An url for a post with category "category with space" will be in
    # slugified form : /category-with-space
    # instead of url encoded form : /category%20with%20space
    #
    # @see utils.slugify
    def url_placeholders
      {
        :year        => date.strftime("%Y"),
        :month       => date.strftime("%m"),
        :day         => date.strftime("%d"),
        :title       => slug,
        :i_day       => date.strftime("%-d"),
        :i_month     => date.strftime("%-m"),
        :categories  => (categories || []).map { |c| Utils.slugify(c) }.join('/'),
        :short_month => date.strftime("%b"),
        :short_year  => date.strftime("%y"),
        :y_day       => date.strftime("%j"),
        :output_ext  => output_ext
      }
    end
  end
end
