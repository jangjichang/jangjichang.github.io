gen-ca:
	ruby scripts/generate_category_pages.rb

gen-tag:
	ruby scripts/generate_tag_pages.rb

up:
	bundle exec jekyll serve
