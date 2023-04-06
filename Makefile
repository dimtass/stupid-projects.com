CURDIR := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

server:
	docker run -it --rm --volume="$(PWD):/srv/jekyll" -p 8080:4000 jekyll/jekyll jekyll serve

build:
	docker run -it --rm -e  JEKYLL_ENV=production --volume="$(PWD):/srv/jekyll" --publish [::1]:4000:4000 jekyll/jekyll jekyll build

publish:
	rsync -aP _site/* root@185.170.114.81:/root/html/