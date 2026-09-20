# No Lost AI — Deploy Guide

This is a plain static website (just HTML/CSS files, no build step, no database).
That means it's fast, cheap to host, and works with Netlify's free tier.

## What's in this folder

- `index.html` — the homepage (hero, how it works, pricing, trial signup section)
- `articles/` — 10 SEO/AEO content pages + an articles index page
- `css/style.css` — all the styling for every page
- `netlify.toml` — tells Netlify how to deploy this site
- `robots.txt` / `sitemap.xml` — tells Google and AI crawlers what pages exist
- `404.html` — shown if someone hits a broken link

## Step 1: Push this folder to GitHub

1. Create a new **private** repository on GitHub (e.g. `nolostai-site`)
2. From this folder, run:
   ```
   git init
   git add .
   git commit -m "Initial No Lost AI site"
   git branch -M main
   git remote add origin https://github.com/<your-username>/nolostai-site.git
   git push -u origin main
   ```

## Step 2: Connect Netlify

1. Go to [app.netlify.com](https://app.netlify.com) and log in
2. Click **Add new site → Import an existing project**
3. Choose **GitHub** and select the `nolostai-site` repo
4. Build settings: leave **Build command** blank, set **Publish directory** to `.` (this is already set in `netlify.toml`, so Netlify should pick it up automatically)
5. Click **Deploy site** — Netlify gives you a live `*.netlify.app` URL immediately

## Step 3: Point trial.makkoguy.com at it

This site is set to deploy on the subdomain **trial.makkoguy.com** (every canonical URL, the sitemap, and the schema markup in this project are already built around that domain — no need to touch those).

Since makkoguy.com is registered through GoHighLevel, here's how to connect the subdomain:

1. In Netlify: **Site settings → Domain management → Add a domain**, enter `trial.makkoguy.com`
2. Netlify will hand you a CNAME record to add (something like `trial → your-site-name.netlify.app`)
3. In GoHighLevel, go to your domain's DNS settings for makkoguy.com and add that CNAME record for the `trial` subdomain
4. DNS usually propagates within a few minutes to a few hours — Netlify's domain panel will show a green checkmark once it's live and auto-issue an SSL certificate

Every time you push a change to GitHub, Netlify automatically redeploys — that's the "handshake" that keeps the live site in sync with your code.

## Step 4: The GoHighLevel form is already wired in

The trial signup section on the homepage (`index.html`) already has your real GHL form
embedded (form ID `iRXRZUD6Q5uqCU1ZI76T`) — no placeholder swap needed. Every submission
lands directly in your GHL contacts/pipeline automatically. If you ever need to swap in
a *different* GHL form later, find the `<div class="ff-form-wrapper">` block in
`index.html` and replace the iframe's `src` with the new form's embed URL.

## Notes on the content

- The 10 articles in `articles/` are written to directly answer real questions HVAC owners search for (and increasingly ask ChatGPT/Google AI Overviews), with FAQ schema markup baked into each page so AI engines can read and cite them.
- Every article ends with a call-to-action pointing back to the homepage's `#trial` section — that's your conversion funnel.
- The business specifics (pricing, positioning, "no new phone number" setup via Conditional Call Forwarding) come directly from the No Lost AI Business Plan, so the site matches what you're actually selling.
- This site is the destination the makkoguy.com VSL funnel links out to — its "Start My 14-Day Trial" buttons point here once trial.makkoguy.com is live.
