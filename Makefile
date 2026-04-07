install:
	docker run --rm -it \
		--platform linux/amd64 \
		--volume="$(PWD):/srv/jekyll:Z" \
		jvconseil/jekyll-docker \
		bundle install

serve:
	docker run --rm -it \
		--platform linux/amd64 \
		--volume="$(PWD):/srv/jekyll:Z" \
		-p 4000:4000 \
		jvconseil/jekyll-docker \
		jekyll serve

build:
	docker run -it --rm \
		--platform linux/amd64 \
		-e JEKYLL_ENV=production \
		--volume="$(PWD):/srv/jekyll:Z" \
		--publish [::1]:4000:4000 \
		jvconseil/jekyll-docker \
		jekyll build