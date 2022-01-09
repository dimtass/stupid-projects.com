---
title: Moving from Wordpress to Jekyll
date: 2022-01-09T20:59:29+00:00
author: dimtass
layout: post
categories: ["Web"]
tags: ["site"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro
For the last 5 years this blog was running on a [Vultr](https://www.vultr.com/) VPS and on Wordpress.
At that point in time, I just starting blogging and it was easier for me to run a WP site rather using
other available options. Now, after 5 years, a lot of things have changed and is better and cheaper to
run a static html blog.

In this post I will explain the reason I've chosen to switch to a static web blog and what are the
pros and cons.

## Wordpress
WP is a very powerful and complex framework on which you can build a blog. Although it's quite easy
to build a blog on WP, nowadays doing so it's like using a very powerful computer to just write
documents in Word. WP has thousands of plugins, automates a lot of processes, has many options e.t.c.,
but for a personal blog is just too much.

First it's a complicated tool that can be fragile. It involves databases and a lot of stuff in the
background that are complex and out of reach. If something breaks, then you better have very good
backups or even better a VPS snapshot, because you may not able to recover.

Also, for me it needed quite a few manual steps and a lot of time to set it up.

The biggest advantage is the plugins, though. You need comments, emailer, stats and numerous other
things? Then there's a plugin for it. There's a plugin for almost everything that you may need. Also,
most of them are free or their free edition is enough for a blog needs.

WP is a dynamic content site, which means that every time you load a page then the page is created
on the fly by WP and then it's rendered on the browser. This takes more processing time and also
it may break easier if a single step in this process fails.

## What I needed
For last couple of years and especially for the last year that my professional orientation is in DevSecOps,
I wanted to have automation and provisioning. I wanted to have a pipeline that I can trigger when I want
to update something in the blog and get the expected result in the output.

I also wanted less complicate workflow and ideally avoid dynamic content creation as it's not really
necessary for a blog. Also, dynamic sites are more prone to attacks from outside.

Therefore, static site was the way to go, but what are the alternatives?

## Alternatives
Well, there are many static site generators, but I won't list them all. The ones that were interesting
to me were:

- [Hugo](https://gohugo.io/)
- [Gatsby](https://www.gatsbyjs.com/)
- [Jekyll](https://jekyllrb.com/)
- [VuePress](https://vuepress.vuejs.org/)

Of course, there are many others but after some research I ended up to two candidates: `Hugo` and `Jekyll`.

I liked Hugo, because it's based on Go, which has became my main programming language for the last year (bye, bye C).
After reading the docs and tried a few examples, I've figured out that I didn't like it's complexity. It
seemed somehow unnecessary to me and quite complex for my needs.

Finally, Jekyll looked the ideal framework for me and next I'll explain why.

## Jekyll
Jekyll is a static web site generator which is written in Ruby. Well, I guess this is the only minor thing
for me because I don't know Ruby and also don't want to spend time learn it. This means that Jekyll is actually
a black-box for me and therefore I rely on that it works without issues.

What I also liked about Jekyll, is that it comes with various themes, it's mature and it's used as a standard
on the [github pages](https://pages.github.com/). It also comes with a [docker image](https://hub.docker.com/r/jekyll/jekyll/)
that you can use to develop you site; hence no need to install anything on your workstation.

To write posts in Jekyll, you can use Markdown, which for me is a huge advantage as I use md all the time.

The theme I currently use is [chirpy dark](https://chirpy.cotes.info/).

## How-to
To setup your static blog using Jekyll and [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) you can use
the [starter](https://github.com/cotes2020/chirpy-starter/generate) generator from the chirpy github repo. By
clicking this link, you'll get a prompt to create a new repo and this repo will automatically filled with the
contents of the static website.

There is an excellent video tutorial for Jekyll [here](https://www.youtube.com/playlist?list=PLLAZ4kZ9dFpOPV5C5Ay0pHaa0RJFhcmcB)
that you can use to learn how to use it and there's also a a very thorough documentation [here](https://jekyllrb.com/docs/).

When you have your repo done then you can start write blog posts or pages using the docker image like this:
```sh
cd /path/to/github-repo
docker run -it --rm --volume="$PWD:/srv/jekyll" --publish [::1]:4000:4000 jekyll/jekyll jekyll serve
```

The above command will start a webserver at [http://localhost:4000](http://localhost:4000) and there you can view
your site content. When you do a change and save the file, then the server detects the change and reloads the
web browser.

> Note: the above command will start the server for debugging only!

After you finish with all the changes you want then you can just build the site using this command:
```sh
docker run -it --rm -e  JEKYLL_ENV=production --volume="$PWD:/srv/jekyll" --publish [::1]:4000:4000 jekyll/jekyll jekyll build
```

This will output the site content in the `_site/` folder of the repo and then you can ssh copy the content to your server.

On the server side I'm using `docker` and `docker-compose` to run an `nginx` and `certbot` instance. The nginx is the
web server and the certbot image provides the auto-refreshed [letsencrypt](https://letsencrypt.org/) certificates for
the `https`.

This is how my `docker-compose.yml` file looks like:
```yml
version: '3'
services:
  nginx:
    image: nginx:1.21.5-alpine
    ports:
      - "80:80"
      - "443:443"
    restart: always
    volumes:
      - ./data/nginx:/etc/nginx/conf.d:ro
      - ./data/certbot/www:/var/www/certbot:ro
      - ./data/certbot/conf:/etc/letsencrypt:ro
      - /root/html:/etc/nginx/html:ro
    command: "/bin/sh -c 'while :; do sleep 6h & wait $${!}; nginx -s reload; done & nginx -g \"daemon off;\"'"
  certbot:
    image: certbot/certbot:latest
    volumes:
      - ./data/certbot/www:/var/www/certbot:rw
      - ./data/certbot/conf:/etc/letsencrypt:rw
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
```

But there are also additional configurations and steps that need to be done in order for this to work properly. Maybe in
one of the future posts I'll explain how to do this properly, though there are a couple of guides in the internet already.

Finally, the nice thing about Jekyll is that all the site content now is in a private github repo which is much easier to
maintain, backup, update and revert compared to Wordpress. Also pipelines are possible using actions, but for now that's
not in my scope.

## Conclusion
What I really miss so far is the comments sections, which currently is not yet available. I think comments are very important
for interaction with other engineers and in the future I'll add a comments section again and I will try to restore the comments
from Wordpress, if possible.

Excuse me, if your comments are lost, but I needed to switch from WP to Jekyll, as I believe it's a much better option.

So, welcome to the new blog and I hope you enjoy it as I also hope I add more interesting posts in the future. I've done
many things in the last year and I would like to write posts about the things that I've learned.

Have fun!