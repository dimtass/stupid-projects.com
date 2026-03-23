# stupid-projects.com

Source for [stupid-projects.com](https://www.stupid-projects.com) — a Jekyll blog using the [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) theme (v7.x), hosted on GitHub Pages.

---

## Prerequisites (one-time setup)

Install Ruby via Homebrew, then install project dependencies:

```bash
brew install ruby
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

cd ~/git/dimtass/stupid-projects.com
bundle install
```

---

## Writing a new post

1. Create a file in `_posts/` named `YYYY-MM-DD-your-post-slug.md`
2. Add front matter at the top:

```yaml
---
title: Your Post Title
date: 2024-01-15T10:00:00+00:00
author: dimtass
layout: post
categories: ["Embedded"]
tags: ["STM32", "SBC"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
```

**Available categories:** Embedded, DevOps, Web, ChatGPT, Benchmarks

3. Write the post body in Markdown below the front matter.

---

## Adding images

Place image files in the `images/` directory, then reference them in the post:

```markdown
![Alt text]({{page.img_src}}/your-image.jpg){: width="{{page.img_width}}" {{page.img_extras}}}
```

---

## Useful Markdown snippets

**Embed YouTube video:**
```html
<iframe width="420" height="315" src="https://www.youtube.com/embed/VIDEO_ID" frameborder="0" allowfullscreen></iframe>
```

**Link to another post:**
```markdown
[link text]({% post_url 2020-12-09-benchmarking-the-nanopi-r4s %})
```

**Code block with syntax highlighting:**
````markdown
```c
int main() { return 0; }
```
````

---

## Testing locally

Run a local server with live reload:

```bash
bundle exec jekyll serve --livereload
```

Open [http://localhost:4000](http://localhost:4000) in your browser. The site rebuilds automatically on every file save. Stop with `Ctrl+C`.

To also preview posts in `_drafts/`:

```bash
bundle exec jekyll serve --livereload --drafts
```

---

## Deploying to GitHub Pages

Once happy with your changes locally:

```bash
git add _posts/YYYY-MM-DD-your-post-slug.md images/your-image.jpg
git commit -m "Add post: Your Post Title"
git push origin main
```

Pushing to `main` automatically triggers the GitHub Actions build. Monitor progress at:
**https://github.com/dimtass/stupid-projects.com/actions**

The site is live at [https://www.stupid-projects.com](https://www.stupid-projects.com) within ~2 minutes of the build completing.

---

## Editing an existing post

1. Open the file in `_posts/`
2. Make your changes
3. Test locally with `bundle exec jekyll serve --livereload`
4. Commit and push:

```bash
git add _posts/YYYY-MM-DD-post-slug.md
git commit -m "Update post: Post Title"
git push origin main
```

---

## Troubleshooting

**`bundle install` fails:**
```bash
gem install bundler
bundle install
```

**Post not appearing locally:** Check that:
- Filename starts with a valid date: `YYYY-MM-DD-`
- Front matter has `layout: post`
- The date in front matter is not in the future

**Images not loading:** Make sure the image is in `images/` and committed to git.

**GitHub Actions build failing:** Check the error log at https://github.com/dimtass/stupid-projects.com/actions

**Dependency errors after pulling:**
```bash
bundle update
```

---

## Maintainer

Dimitris Tassopoulos <dimtass@gmail.com>
