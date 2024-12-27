cat:
	ruby scripts/generate_category_pages.rb

tag:
	ruby scripts/generate_tag_pages.rb

up:
	bundle exec jekyll serve

new:
	@if [ -z "$(title)" ]; then \
	  echo "Error: Please provide a title. (ex: make new-post title=\"My New Post\")"; \
	  exit 1; \
	fi; \
	TITLE_SLUG=`echo "$(title)" | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]'`; \
	POST_DATE=`date +%Y-%m-%d`; \
	FILE_NAME="$${POST_DATE}-$${TITLE_SLUG}.md"; \
	echo "Creating file: _posts/$${FILE_NAME}"; \
	cp post_template.md "_posts/$${FILE_NAME}"; \
	echo "Done!"
