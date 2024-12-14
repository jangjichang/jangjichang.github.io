#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

# 설정
POSTS_DIR = '_posts'
CATEGORIES_DIR = 'categories'
TEMPLATE = <<-EOF
---
layout: category
title: "%{category} Category"
category_name: "%{category}"
---
EOF

# categories 디렉토리가 없다면 생성
FileUtils.mkdir_p(CATEGORIES_DIR)

# 모든 카테고리를 저장할 집합
all_categories = Set.new

# _posts 디렉토리의 모든 마크다운 파일 처리
Dir.glob("#{POSTS_DIR}/*.[mM][dD]").each do |post|
  content = File.read(post)
  if content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
    front_matter = YAML.load($1)

    # 카테고리가 있는 경우 처리
    if front_matter && front_matter['categories']
      categories = case front_matter['categories']
                  when String, Numeric
                    [front_matter['categories'].to_s]
                  when Array
                    front_matter['categories'].map(&:to_s)
                  else
                    []
                  end
      categories.each { |category| all_categories.add(category.to_s) }
    elsif front_matter && front_matter['category']
      all_categories.add(front_matter['category'].to_s)
    end
  end
end

# 각 카테고리에 대해 페이지 생성
all_categories.each do |category|
  # 카테고리 디렉토리 생성
  category_dir = "#{CATEGORIES_DIR}/#{category.downcase.gsub(/\s+/, '-')}"
  FileUtils.mkdir_p(category_dir)

  # index.html 파일 생성
  filename = "#{category_dir}/index.html"

  content = TEMPLATE % { category: category.to_s }

  File.write(filename, content)
  puts "Generated category page for: #{category}"
end

puts "\nCategory page generation completed!"
puts "Total number of categories: #{all_categories.size}"
puts "Category pages have been generated in: #{CATEGORIES_DIR}/"