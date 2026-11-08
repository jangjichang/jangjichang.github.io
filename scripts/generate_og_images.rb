#!/usr/bin/env ruby
# frozen_string_literal: true

# 글마다 제목이 들어간 공유 썸네일(1200x630)을 assets/og/<key>.png로 만든다.
# HTML 카드를 headless Chrome으로 캡처하며, _plugins/og_image.rb가 이 파일을 og:image로 연결한다.
#
#   ruby scripts/generate_og_images.rb          # 바뀐 글만 다시 만든다
#   FORCE=1 ruby scripts/generate_og_images.rb  # 전부 다시 만든다
#   CHROME_PATH=/path/to/chrome ...             # Chrome 위치를 직접 지정한다

require 'yaml'
require 'date'
require 'cgi'
require 'digest'
require 'fileutils'
require 'net/http'
require 'uri'

POSTS_DIR = '_posts'
OUT_DIR = 'assets/og'
CACHE_DIR = '.og-cache' # 점으로 시작하는 폴더는 Jekyll이 무시한다
FONT_URL = 'https://cdn.jsdelivr.net/npm/pretendard@1.3.9/dist/web/variable/woff2/PretendardVariable.woff2'
FONT_FILE = File.join(CACHE_DIR, 'PretendardVariable.woff2')
WIDTH = 1200
HEIGHT = 630

TEMPLATE = <<~HTML
  <!doctype html>
  <html lang="ko">
  <head>
  <meta charset="utf-8">
  <style>
    @font-face { font-family: "Pretendard"; src: url("PretendardVariable.woff2") format("woff2"); font-weight: 45 920; font-display: block; }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { width: #{WIDTH}px; height: #{HEIGHT}px; overflow: hidden; background: #f4f4f2; }
    body { font-family: "Pretendard"; -webkit-font-smoothing: antialiased; }
    .frame {
      position: absolute; inset: 28px; display: flex; flex-direction: column;
      padding: 40px 60px 36px; background: #050505; border: 1px solid #1d1d1d; color: #f4f4f2;
    }
    .bar { display: flex; justify-content: space-between; align-items: center; color: #858585; font-size: 17px; font-weight: 500; letter-spacing: .22em; }
    .top { padding-bottom: 22px; border-bottom: 1px solid #303030; }
    .top .category { color: #f4f4f2; }
    .bottom { padding-top: 22px; border-top: 1px solid #303030; }
    .wordmark { color: #f4f4f2; font-size: 26px; font-weight: 500; letter-spacing: .02em; }
    .main { flex: 1; min-height: 0; display: flex; flex-direction: column; justify-content: center; padding: 0 20px; text-align: center; }
    h1 {
      font-size: 84px; font-weight: 650; letter-spacing: -.045em; line-height: 1.2;
      word-break: keep-all; overflow-wrap: anywhere; text-wrap: balance;
    }
    .sub {
      display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden;
      margin-top: 26px; color: #aaa; font-size: 28px; font-weight: 400; letter-spacing: -.01em; line-height: 1.5;
      word-break: keep-all; text-wrap: balance;
    }
  </style>
  </head>
  <body>
    <div class="frame">
      <div class="bar top"><span class="category">%<category>s</span><span>%<date>s</span></div>
      <div class="main">
        <h1>%<title>s</h1>
        %<subtitle>s
      </div>
      <div class="bar bottom"><span class="wordmark">JI.CHANG</span><span>JANGJICHANG.GITHUB.IO</span></div>
    </div>
    <script>
      // 제목이 세 줄을 넘거나 카드 밖으로 넘치면 글자 크기를 줄인다.
      function fit() {
        var main = document.querySelector('.main');
        var h1 = document.querySelector('h1');
        var size = 84;
        h1.style.fontSize = size + 'px';
        while (size > 44 && (h1.offsetHeight > size * 1.2 * 3 + 1 || main.scrollHeight > main.clientHeight)) {
          size -= 2;
          h1.style.fontSize = size + 'px';
        }
      }
      fit();
      document.fonts.ready.then(fit);
    </script>
  </body>
  </html>
HTML

def post_key(path)
  File.basename(path, '.*').sub(/\A\d{4}-\d{2}-\d{2}-/, '').downcase
end

def front_matter(path)
  raw = File.read(path)[/\A---\s*\n(.*?)\n---\s*$/m, 1]
  raw ? (YAML.safe_load(raw, permitted_classes: [Date, Time]) || {}) : {}
end

def category_titles
  data = YAML.safe_load(File.read('_data/categories.yml')) || {}
  (data['sections'] || []).to_h { |s| [s['slug'], s['title']] }
rescue Errno::ENOENT
  {}
end

def find_chrome
  candidates = [
    ENV['CHROME_PATH'],
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Chromium.app/Contents/MacOS/Chromium'
  ]
  candidates += %w[google-chrome google-chrome-stable chromium chromium-browser].map do |name|
    ENV['PATH'].split(File::PATH_SEPARATOR).map { |dir| File.join(dir, name) }.find { |p| File.executable?(p) }
  end
  candidates.compact.find { |p| File.executable?(p) } or abort('Chrome을 찾지 못했습니다. CHROME_PATH로 위치를 지정하세요.')
end

def ensure_font
  return if File.size?(FONT_FILE)

  puts "Downloading font: #{FONT_URL}"
  res = Net::HTTP.get_response(URI(FONT_URL))
  abort("폰트 다운로드 실패: HTTP #{res.code}") unless res.is_a?(Net::HTTPSuccess)
  File.binwrite(FONT_FILE, res.body)
end

def render(chrome, html_path, png_path)
  args = [
    chrome, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--no-first-run',
    '--force-device-scale-factor=1', "--window-size=#{WIDTH},#{HEIGHT}",
    '--virtual-time-budget=5000', "--screenshot=#{File.expand_path(png_path)}",
    "file://#{File.expand_path(html_path)}"
  ]
  args.insert(1, '--no-sandbox') if ENV['CI']
  system(*args, out: File::NULL, err: File::NULL) && File.size?(png_path)
end

FileUtils.mkdir_p([OUT_DIR, CACHE_DIR])
ensure_font
chrome = find_chrome
categories = category_titles
template_digest = Digest::SHA256.hexdigest(TEMPLATE)

posts = Dir.glob("#{POSTS_DIR}/*.{md,markdown,html}").sort
keys = posts.map { |p| post_key(p) }

# 지워진 글의 썸네일 정리
Dir.glob("#{OUT_DIR}/*.png").each do |png|
  FileUtils.rm_f(png) unless keys.include?(File.basename(png, '.png'))
end

made = skipped = failed = 0
posts.each do |path|
  fm = front_matter(path)
  next if fm['image'] # 글에서 직접 지정한 썸네일이 있으면 만들지 않는다
  next if fm['published'] == false

  key = post_key(path)
  date = File.basename(path)[/\A(\d{4})-(\d{2})-(\d{2})/] ? "#{$1}.#{$2}.#{$3}" : ''
  category = categories[fm['category']] || fm['category'].to_s.upcase
  subtitle = fm['subtitle'].to_s.strip
  html = format(
    TEMPLATE,
    category: CGI.escapeHTML(category),
    date: date,
    title: CGI.escapeHTML(fm['title'].to_s),
    subtitle: subtitle.empty? ? '' : %(<p class="sub">#{CGI.escapeHTML(subtitle)}</p>)
  )

  png_path = File.join(OUT_DIR, "#{key}.png")
  digest_path = File.join(CACHE_DIR, "#{key}.sha256")
  digest = Digest::SHA256.hexdigest(html + template_digest)
  if !ENV['FORCE'] && File.size?(png_path) && File.exist?(digest_path) && File.read(digest_path) == digest
    skipped += 1
    next
  end

  html_path = File.join(CACHE_DIR, "#{key}.html")
  File.write(html_path, html)
  if render(chrome, html_path, png_path)
    File.write(digest_path, digest)
    made += 1
    puts "  #{png_path}"
  else
    failed += 1
    warn "  실패: #{path}"
  end
end

puts "OG images: #{made} generated, #{skipped} unchanged, #{failed} failed"
exit(failed.zero? ? 0 : 1)
