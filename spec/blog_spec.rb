require 'rspec'
require 'nokogiri'

# Adapted from https://gist.github.com/thbar/10be2ea924b81f78d24ab800461bfee3
RSpec.describe 'Fast Ruby Blog' do
  describe 'tests' do
    let(:post) { '/rails/upgrades/case-study/upgrading-a-monolith.html' }
    let(:file_path) { "_site/#{post}" }
    let(:url) { "https://fastruby.io/blog#{post}" }

    before do
      unless File.exists?(file_path)
        system("jekyll build")
      end
    end

    it 'generates correct URLs' do
      expect(File.exists?(file_path)).to be_truthy
    end

    it 'generates correct meta data' do
      doc = Nokogiri::HTML(IO.read(file_path))
      data = doc.search('meta[name^="twitter"]').inject({}) do |r, e|
        r[e['name']] = e['content'] ; r
      end
      expect(data['twitter:card']).to eq 'summary'
      expect(data['twitter:site']).to eq '@fastrubyio'
      expect(data['twitter:title']).to eq 'Upgrading a Huge Monolith From Rails 4.0 to Rails 5.1 - Ruby on Rails Upgrades'
      expect(data['twitter:description']).to start_with('We recently collaborated with Power Home Remodeling on a Rails upgrade')
      expect(data['twitter:image:src']).to eq 'https://fastruby.io/blog/assets/images/profile.png'
    end

    it 'generates the sitemap with correct domain name' do
      doc = Nokogiri::XML(IO.read('_site/sitemap.xml'))
      url = doc.xpath('/aws:urlset/aws:url/aws:loc', 'aws' => 'http://www.sitemaps.org/schemas/sitemap/0.9')[0]
      expect(url.text).to eq 'https://fastruby.io/blog'
    end

    it 'generates share button for twitter' do
      doc = Nokogiri::HTML(IO.read(file_path))
      href = doc.search('.icon-twitter').first['href']
      expect(href).to include(url)
    end

    it 'generates the RSS feed' do
      doc = Nokogiri::XML(IO.read('_site/rss.xml'))
      links = doc.xpath('/aws:feed/aws:link', 'aws' => 'http://www.w3.org/2005/Atom')
      expect(links.size).to eq 2
      expect(links[0].to_h).to eq({
        'type' => 'application/atom+xml',
        'href' => 'https://fastruby.io/blog/rss.xml',
        'rel' => 'self'
      })
      expect(links[1].to_h).to eq({
        'type' => 'text/html',
        'href' => 'https://fastruby.io/blog/',
        'rel' => 'alternate'
      }, )
    end
  end
end
