namespace :post do
  desc "Create a new blog post"
  task :create do
    print "Your blog post title: "
    blog_post_title = STDIN.gets.chomp.gsub(" ", "-")

    if blog_post_title.empty?
      puts "Can't create a blog post with an empty title..."
      next
    end

    formatted_blog_post_title = "#{Time.now.strftime("%Y-%m-%d")}-#{blog_post_title}.markdown"
    blog_post_path = File.join("./_posts", formatted_blog_post_title)

    if blog_post_exist?(blog_post_path)
      puts "#{blog_post_path} already exists..."
      print "are you sure you want to override it? [y/n] "

      overwrite_blog_post = STDIN.gets.chomp.capitalize
      next if overwrite_blog_post != "Y"
    end

    begin
      File.open(blog_post_path, "w") do |f|
        f.puts header({
          title: blog_post_title,
          author: author,
          date: Time.now.strftime("%Y-%m-%d %H:%M:%S")
        })
      end
    rescue Exception => e
      puts "Blog post could not be created: #{e.message}"
      exit(1)
    end

    puts "Blog post created: #{blog_post_path}"
  end

  def header(options)
    %Q(---
layout: post
title: #{options[:title]}
date: #{options[:date]}
categories:
author: #{options[:author]}
---)
  end

  def blog_post_exist?(file_name)
    File.file?(file_name)
  end

  def author
    `git config user.name`
  end

end
