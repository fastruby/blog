require 'sitemap_generator'

Jekyll::Hooks.register :site, :post_write do |site|
  if site.config["update_sitemap"]
    opts = {
      create_index: false,
      default_host: 'https://fastruby.io/blog',
      compress: false,
      public_path: '/tmp',
      sitemaps_path: '',
      sitemaps_host: site.config['fog_url']
    }

    SitemapGenerator::Sitemap.create opts do
      puts "Generating sitemap for the blog. The file will be uploaded to #{site.config['fog_url']}"

      files = Dir['public/blog/**/*.html']
      puts "Files: #{files.size}"

      files.each do |page|
        file = File.new(page).path.gsub('_site/','')
        puts "Adicionando: #{file}"
        add file, changefreq: 'weekly'
      end
    end
  end

  puts "Running tests..."
  system "bundle exec rspec spec/blog_spec.rb"
  puts "All done!"
end
