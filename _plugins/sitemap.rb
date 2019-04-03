require 'sitemap_generator'

Jekyll::Hooks.register :site, :post_write do |site|
  opts = {
    create_index: false,
    default_host: 'https://fastruby.io/blog',
    compress: false,
    public_path: '/tmp',
    sitemaps_path: '',
    sitemaps_host: site.config['fog_url']
  }

  files = []
  Dir['_site/**/*.html'].each do |page|
    files << File.new(page)
  end

  SitemapGenerator::Sitemap.create opts do
    puts "Generating sitemap for the blog. The file will be uploaded to #{ENV['FOG_URL']}"
    files.each do |file|
      file = file.path.sub(/^_site/,'')
      puts "Adicionando: #{file}"
      add file, changefreq: 'weekly'
    end
  end

  puts "Running tests..."
  system "bundle exec rspec spec/blog_spec.rb"
  puts "All done!"
end
