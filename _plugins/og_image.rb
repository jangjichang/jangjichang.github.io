# frozen_string_literal: true

# scripts/generate_og_images.rb가 만든 assets/og/<key>.png를 각 글의 og:image로 연결한다.
# 썸네일 파일이 없거나 글에서 image를 직접 지정했다면 그대로 둔다(_config.yml의 기본 이미지가 쓰인다).
module OgImage
  class Generator < Jekyll::Generator
    priority :lowest

    def generate(site)
      site.posts.docs.each do |post|
        key = post.basename_without_ext.sub(/\A\d{4}-\d{2}-\d{2}-/, '').downcase
        relative = "assets/og/#{key}.png"
        next unless File.exist?(site.in_source_dir(relative))

        default = site.frontmatter_defaults.find(post.relative_path, :posts, 'image')
        next unless post.data['image'].nil? || post.data['image'] == default

        post.data['image'] = {
          'path' => "/#{relative}",
          'width' => 1200,
          'height' => 630,
          'alt' => post.data['title']
        }
      end
    end
  end
end
