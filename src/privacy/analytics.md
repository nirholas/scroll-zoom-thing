---
title: Privacy-first analytics
description: How to wire cookieless and self-hosted analytics into an MkDocs site built with scroll-zoom-thing.
---

# Privacy-first analytics

The template ships without analytics. If you want to know how many people read your docs, this page lists the options that respect reader privacy and shows how to wire each one into `mkdocs.yml`. None of the options below set tracking cookies, fingerprint visitors, or share data with third parties for advertising.

The general pattern is the same for every option: you add a small snippet to `extra_javascript` (or to a custom partial) and rebuild the site. The template does not need to be modified.

## Comparison

| Option | Hosting | Cookies | Free tier | Self-hostable |
|--------|---------|---------|-----------|---------------|
| Cloudflare Web Analytics | Cloudflare | None | Unlimited | No |
| Plausible | Plausible Cloud | None | 30 day trial | Yes |
| Umami | Umami Cloud | None | 10k events/mo | Yes |
| GoatCounter | GoatCounter | None | Non-commercial | Yes |
| Server logs (GoAccess) | Your server | None | n/a | Yes |

All five report aggregate page views, referrers, and country-level geography. None record per-visitor identity.

## Cloudflare Web Analytics

Cloudflare Web Analytics is the simplest option if you already deploy on Cloudflare Pages. It is cookieless, does not require a banner under GDPR, and is free with no event cap.

1. In the Cloudflare dashboard, open **Analytics & Logs** then **Web Analytics**.
2. Add a site, choose "Manual setup", and copy the `<script>` snippet.
3. Save the script body to `src/assets/js/cf-analytics.js`. It looks like:

   ```js
   // src/assets/js/cf-analytics.js
   (function () {
     var s = document.createElement('script');
     s.defer = true;
     s.src = 'https://static.cloudflareinsights.com/beacon.min.js';
     s.setAttribute('data-cf-beacon', '{"token": "YOUR_TOKEN"}');
     document.head.appendChild(s);
   })();
   ```

4. Wire it in `mkdocs.yml`:

   ```yaml
   extra_javascript:
     - assets/js/cf-analytics.js
   ```

If you serve through Cloudflare's proxy, you can enable Web Analytics from the dashboard without any code change. The dashboard option is preferred because it lets Cloudflare strip the beacon for visitors who have Do Not Track enabled.

## Plausible

Plausible is a paid hosted service with an open-source self-hosted edition. It is cookieless and lightweight (~1 KB script).

For Plausible Cloud, add to `mkdocs.yml`:

```yaml
extra_javascript:
  - https://plausible.io/js/script.js
```

Plausible expects a `data-domain` attribute, which `extra_javascript` cannot set directly. Use a small loader instead:

```js
// src/assets/js/plausible.js
(function () {
  var s = document.createElement('script');
  s.defer = true;
  s.dataset.domain = 'docs.example.com';
  s.src = 'https://plausible.io/js/script.js';
  document.head.appendChild(s);
})();
```

```yaml
extra_javascript:
  - assets/js/plausible.js
```

For self-hosted Plausible, swap the script URL for your instance.

## Umami

Umami is open source, self-hostable, and offers a generous free cloud tier. It is cookieless by default and the script is tiny.

```js
// src/assets/js/umami.js
(function () {
  var s = document.createElement('script');
  s.defer = true;
  s.src = 'https://cloud.umami.is/script.js';
  s.dataset.websiteId = 'YOUR_WEBSITE_ID';
  document.head.appendChild(s);
})();
```

```yaml
extra_javascript:
  - assets/js/umami.js
```

If you self-host Umami on Railway or Fly.io, point `s.src` at your instance. Umami's dashboard distinguishes unique visitors using a daily-rotating salted hash, so no cookies are set and no persistent identifiers leave the browser.

## GoatCounter

GoatCounter is a single-developer project that runs on a tiny VM and is free for non-commercial use on the hosted version. It is the lightest option in this list (under 3 KB).

```js
// src/assets/js/goatcounter.js
window.goatcounter = { no_onload: false };
(function () {
  var s = document.createElement('script');
  s.async = true;
  s.dataset.goatcounter = 'https://YOURCODE.goatcounter.com/count';
  s.src = '//gc.zgo.at/count.js';
  document.head.appendChild(s);
})();
```

```yaml
extra_javascript:
  - assets/js/goatcounter.js
```

GoatCounter does not record IP addresses at all and produces a visitor hash that resets every nine hours. It is appropriate for low-to-medium traffic documentation sites.

## Server-side log analytics

If you control the server, you can skip browser-side analytics entirely and run [GoAccess](https://goaccess.io) or [Matomo log analytics](https://matomo.org/log-analytics/) over your access logs. This approach has the strongest privacy guarantee because no script runs in the visitor's browser at all.

A typical workflow:

1. Pipe nginx or Caddy access logs into a log shipper.
2. Run GoAccess nightly to produce an HTML report.
3. Serve the report from a private URL.

This works particularly well on Railway, where the deployed Python `http.server` produces stdout logs you can capture from Railway's log drain.

## Loading conditionally

For all of the JavaScript options above, you can defer loading until after the parallax hero has finished its initial animation. This keeps the largest contentful paint clean of third-party requests:

```js
window.addEventListener('load', function () {
  setTimeout(loadAnalytics, 500);
});
```

If you do this, document the choice in your site's privacy notice so it is auditable.

## What to put in your privacy notice

Whichever option you pick, your site's privacy notice should state: the name of the analytics provider, what data is collected (typically URL, referrer, user-agent, country), how long it is retained, and whether visitors can opt out. None of the options on this page require a cookie banner under GDPR, but a short transparent disclosure is still good practice.

For deployment-specific notes on enabling analytics, see [github-pages.md](../deploy/github-pages.md), [vercel.md](../deploy/vercel.md), and [cloudflare.md](../deploy/cloudflare.md).
