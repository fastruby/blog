require 'sitemap_generator'

Jekyll::Hooks.register :site, :post_write do |site|
  unless site.config["watch"]
    puts "Generating sitemap.xml.gz"

    files = []
    Dir['_site/**/*.html'].each do |page|
      files << File.new(page)
    end

    SitemapGenerator::Sitemap.default_host = site.config['url'] + "/blog"
    public_path = Dir.pwd.end_with?("blog") ? "_site" : "public/blog"
    SitemapGenerator::Sitemap.public_path = public_path
    SitemapGenerator::Sitemap.create compress: false do
      files.each do |file|
        add file.path.sub(/^_site/,''), changefreq: 'weekly'
      end
    end

    puts "Generated sitemap.xml.gz"
  end

  puts "All done!"
end
