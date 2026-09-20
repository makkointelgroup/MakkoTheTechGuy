# Makko The Tech Guy — Funnel Deploy Guide

This is the one-page VSL funnel for **makkoguy.com** (the root domain — different from
`trial.makkoguy.com`, the separate No Lost AI content + trial-signup site). It's built
the same way: plain HTML/CSS, no build step, deploys to Netlify.

**This funnel does not have a form on it anymore.** Every "Start My 14-Day Trial"
button sends people to the nolostai site, where the actual GHL signup form lives.
Right now those buttons point to the live Netlify preview URL
(`https://sparkly-cocada-0d3494.netlify.app/`) — once `trial.makkoguy.com` is
connected (see the nolostai-site's own DEPLOY.md), swap all 5 of those links over to
`https://trial.makkoguy.com/` with a find-and-replace.

## What's in this folder

- `index.html` — the whole funnel: hero + your YouTube video, credibility section,
  how-it-works, pricing, guarantee, FAQ, final CTA — no signup form, just links out
  to the trial site
- `css/funnel.css` — the dark/cyan "Makko" look, pulled from your YouTube banner and logo
- `netlify.toml`, `robots.txt`, `sitemap.xml`, `404.html` — same setup pattern as the trial site

## Repo structure: this lives inside the `makkothetechguy` monorepo

Both sites — this funnel and the nolostai/trial site — live as sibling folders inside
one GitHub repository named **makkothetechguy**, matching your local folder layout:

```
makkothetechguy/               <- the git repo root (your "Makko The Tech Guy" folder)
├── makko-funnel-site/         <- this folder, deploys to makkoguy.com
└── nolostai-site/             <- deploys to trial.makkoguy.com
```

You link **both** Netlify sites to this **one** repo, and tell each Netlify site to
only build from its own subfolder using Netlify's "Base directory" setting:

1. **Push the whole `makkothetechguy` folder to GitHub once** (see the top-level
   instructions your session used to set this up — `git init` at the
   `makkothetechguy` root, add both subfolders, commit, push to a new repo named
   `makkothetechguy`)
2. **In Netlify, create two separate sites from the same repo:**
   - Site 1: import `makkothetechguy`, set **Base directory** to `makko-funnel-site`,
     **Publish directory** to `makko-funnel-site` (or just `.` relative to the base
     directory) — this becomes makkoguy.com
   - Site 2: import `makkothetechguy` again as a *second* site, set **Base
     directory** to `nolostai-site` — this becomes trial.makkoguy.com
3. Now a single `git push` to the repo can redeploy either or both sites, and each
   only rebuilds when its own subfolder changes.

## Step: Point the ROOT domain (makkoguy.com) at the funnel site

You can't point a bare/apex domain (`makkoguy.com` with nothing in front of it) at a
CNAME the way you can with a subdomain like `trial.makkoguy.com`. Two ways to handle it:

**Option A — Netlify DNS (easiest):** In Netlify, go to Site settings → Domain
management → Add a domain → enter `makkoguy.com`. Netlify will offer to manage your
DNS entirely — if you go this route, you'd point makkoguy.com's nameservers at
Netlify instead of GoHighLevel. Cleanest setup, but DNS management moves out of GHL.

**Option B — Keep DNS in GoHighLevel (recommended, since your SMS and CRM already
live there):** In GHL's DNS settings for makkoguy.com, add an **A record** pointing
the root domain (`@`) at Netlify's load balancer IP (Netlify shows you the current
value in their domain settings — use whatever they display, it can change). Also add
a **CNAME** for `www` pointing to your Netlify site (e.g. `your-site-name.netlify.app`)
so `www.makkoguy.com` works too. Netlify auto-issues SSL once the records propagate.

Either way — every push to GitHub auto-redeploys the live site.

## About the video

The YouTube video (`youtube.com/embed/Qsrzay7EnfM`) is already embedded in the hero
section, responsive at any screen size. If you swap the VSL later, just replace the
video ID in the `iframe src` in `index.html`.

## Design notes

This page pulls its look directly from your YouTube banner and the Makko
Intelligence / "Mentally Chill" logo — dark background, electric cyan glow, bold
condensed headlines (Anton), the crown as a small recurring accent. It's built
deliberately different from the trial.makkoguy.com site: that one needs to read as
trustworthy and corporate to a stranger HVAC owner searching Google or asking an AI
answer engine; this one is meant to read as *you* — the guy who actually builds this
stuff — and its whole job is to get someone to click through to the trial site.
