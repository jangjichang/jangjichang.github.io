#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

# 설정
POSTS_DIR = '_posts'
TAG_PAGES_DIR = '_tag_pages'
TEMPLATE = <<-EOF
---
layout: tag
title: "Posts tagged with %{tag}"
tag_name: "%{tag}"
---
EOF

# _tag_pages 디렉토리 생성
FileUtils.mkdir_p(TAG_PAGES_DIR)

# 기존 태그 페이지 삭제
FileUtils.rm_rf(Dir.glob("#{TAG_PAGES_DIR}/*"))

# 모든 태그를 저장할 집합
all_tags = Set.new

# _posts 디렉토리의 모든 마크다운 파일 처리
Dir.glob("#{POSTS_DIR}/*.[mM][dD]").each do |post|
  # 파일의 front matter 읽기
  content = File.read(post)
  if content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
    front_matter = YAML.load($1)
    
    # 태그가 있는 경우 처리
    if front_matter && front_matter['tags']
      # 문자열이나 숫자인 경우 배열로 변환
      tags = case front_matter['tags']
             when String, Numeric
               [front_matter['tags'].to_s]
             when Array
               front_matter['tags'].map(&:to_s)
             else
               []
             end
      
      # 각 태그를 집합에 추가
      tags.each { |tag| all_tags.add(tag.to_s) }
    end
  end
end

# 각 태그에 대해 페이지 생성
all_tags.each do |tag|
  # 태그 파일명 생성 (소문자, 공백은 하이픈으로 변환)
  filename = "#{TAG_PAGES_DIR}/#{tag.downcase.gsub(/\s+/, '-')}.md"
  
  # 태그 값을 문자열로 처리
  content = TEMPLATE % { tag: tag.to_s }
  
  # 파일 작성
  File.write(filename, content)
  puts "Generated tag page for: #{tag}"
end

puts "\nTag page generation completed!"
puts "Total number of tags: #{all_tags.size}"
puts "Tag pages have been generated in: #{TAG_PAGES_DIR}/"