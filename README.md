www.stupid-projects.com
----

This is the content of the blog [stupid-projects](https://www.stupid-projects.com)

## Local debug
Run this command in the root directory:
```sh
docker run -it --rm --volume="$PWD:/srv/jekyll" --publish [::1]:4000:4000 jekyll/jekyll jekyll serve
```

If you need to have multiple config files, then you can use this docker command:
```sh
docker run -it --rm --volume="$PWD:/srv/jekyll" --publish [::1]:4000:4000 jekyll/jekyll jekyll serve --config another-config.yml
```

Where `another-config.yml` is the file to use instead of the default `_config.yaml`.

## Production build
To build the production code site you need to run this command:

```sh
docker run -it --rm -e  JEKYLL_ENV=production --volume="$PWD:/srv/jekyll" --publish [::1]:4000:4000 jekyll/jekyll jekyll build
```

Finally you need to sync the content to the server:
```sh
rsync -aP _site/* root@185.170.114.81:/root/html/
```

## Docker service on the server
```sh
docker run -it --rm -d -p 80:80 --name stupid-projects -v /root/html:/usr/share/nginx/html nginx
```

## Shortcuts
Insert youtube video
```
<iframe width="420" height="315" src="https://www.youtube.com/embed/8wwpWP1C0zg" frameborder="0" allowfullscreen></iframe>
```

Insert images
```
![]({{page.img_src}}/img.jpg){: width="{{page.img_width}}" {{page.img_extras}}}


![]({{page.img_src}}/img.png){: width="{{page.img_width}}" {{page.img_extras}}}
```

Insert links
```
[here]({% post_url 2019-01-14-linux-and-the-i2c-and-spi-interfaces-part-2 %})
```

## Google analytics
The google analytics are in `Acquisition -> All traffic -> Referrals` in 
[here](https://analytics.google.com/analytics/web/#/report/trafficsources-referrals/a110508576w164880195p165533838/)

## Maintainer
Dimitris Tassopoulos <dimtass@gmail.com>