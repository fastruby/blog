require 'html-proofer'

task :find_dead_links do
  opts = { only_4xx: true, url_ignore: [/blog/, /#content/] }
  begin
    HTMLProofer.check_directory("./_site", opts).run
  rescue => e
  end
end
