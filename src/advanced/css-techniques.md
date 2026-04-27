# Advanced CSS Parallax Techniques

This guide covers advanced usage of the CSS 3D parallax system in [nirholas/scroll-zoom-thing](https://github.com/nirholas/scroll-zoom-thing). It assumes you have the basic hero working and want to go further: adding content sections below the hero, tuning responsive behavior, handling browser quirks, and extending the system with video layers, gradient overlays, and user preference controls.

---

## Multiple Parallax Groups: Content Sections Below the Hero

The parallax container — the element with `perspective: 2.5rem` and `overflow: hidden auto` — is designed to contain multiple "groups," each of which can have its own set of parallax layers or simply be a standard content section that scrolls in after the hero.

A minimal multi-group structure looks like this:

```html
<div class="parallax-container">
  <!-- Group 1: parallax hero -->
  <div class="parallax-group parallax-group--hero"
       data-md-color-scheme="slate"
       data-md-color-primary="indigo">
    <div class="parallax-layer" style="--md-parallax-depth: 8">
      <img src="assets/parallax/layer-far.avif" alt="" aria-hidden="true" />
    </div>
    <div class="parallax-layer" style="--md-parallax-depth: 5">
      <img src="assets/parallax/layer-mid.avif" alt="" aria-hidden="true" />
    </div>
    <div class="parallax-layer" style="--md-parallax-depth: 2">
      <img src="assets/parallax/layer-near.avif" alt="" aria-hidden="true" />
    </div>
    <div class="parallax-layer" style="--md-parallax-depth: 1">
      <img src="assets/parallax/layer-front.avif" alt="" aria-hidden="true" />
    </div>
    <div class="parallax-layer parallax-layer--base">
      <!-- Hero text content here -->
    </div>
  </div>

  <!-- Group 2: content section that scrolls in normally -->
  <div class="parallax-group parallax-group--content"
       data-md-color-scheme="default"
       data-md-color-primary="teal">
    <div class="parallax-layer parallax-layer--base">
      <section class="md-content">
        <!-- Your MkDocs content renders here -->
      </section>
    </div>
  </div>
</div>
```

The CSS for the container and groups:

```css
.parallax-container {
  height: 100vh;
  overflow: hidden auto;
  perspective: 2.5rem;
  perspective-origin: 50% 0%;
  overscroll-behavior-y: none;
  scroll-behavior: smooth;
}

.parallax-group {
  position: relative;
  transform-style: preserve-3d;
}

.parallax-group--hero {
  height: 100vh;
}

.parallax-group--content {
  /* Content group sits at z=0, scrolls at normal speed */
  position: relative;
  z-index: 1;
  background: var(--md-default-bg-color);
  /* Enough min-height to contain your content */
  min-height: 100vh;
}

.parallax-layer {
  position: absolute;
  inset: 0;
  transform-style: preserve-3d;
}

.parallax-layer--base {
  transform: translateZ(0);
  position: relative;
}
```

The `translateZ(0)` on the base layer means it scrolls at the normal rate. Layers with negative `translateZ` values (supplied via `--md-parallax-depth`) scroll more slowly. The content group below the hero uses only a base layer, so it scrolls at full speed — giving the illusion that the hero "peels away" as you enter the content section.

---

## How `data-md-color-scheme` Transitions Work Between Groups

MkDocs Material reads the `data-md-color-scheme` attribute on the `<body>` element (or, in custom overrides, on the document root) and applies the corresponding color palette via CSS custom properties. In the multi-group parallax setup, each group carries its own `data-md-color-scheme` attribute, and a small Intersection Observer transfers the active value to the `<html>` element as sections scroll into view.

```javascript
// home.html override — paste inside a <script> tag
(function () {
  const groups = document.querySelectorAll('[data-md-color-scheme]');
  const root = document.documentElement;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting && entry.intersectionRatio >= 0.5) {
          const scheme = entry.target.dataset.mdColorScheme;
          const primary = entry.target.dataset.mdColorPrimary;
          if (scheme) root.setAttribute('data-md-color-scheme', scheme);
          if (primary) root.setAttribute('data-md-color-primary', primary);
        }
      });
    },
    { threshold: 0.5 }
  );

  groups.forEach((g) => observer.observe(g));
})();
```

This produces a smooth color scheme transition as the user scrolls from the dark parallax hero into a light content section. The transition itself is handled by Material's existing CSS variable system — all color tokens are defined on `[data-md-color-scheme="default"]` and `[data-md-color-scheme="slate"]` selectors, and the browser smoothly interpolates between them if you add:

```css
:root {
  transition:
    --md-default-bg-color 0.3s ease,
    --md-default-fg-color 0.3s ease,
    --md-primary-fg-color 0.3s ease;
}
```

Note: CSS custom property transitions are not natively interpolated in all browsers (Safari excluded properties from the CSS `transition` spec until recently). For Safari compatibility, transition the background color on a wrapper element instead:

```css
.parallax-group--content {
  transition: background-color 0.3s ease;
}
```

---

## The `data-md-color-primary` Attribute on Groups

Each parallax group can carry a `data-md-color-primary` attribute that sets the accent color for that section. MkDocs Material maps color names to CSS custom properties:

```html
<div class="parallax-group" data-md-color-primary="deep-orange">
```

Valid values are Material Design color names: `red`, `pink`, `purple`, `deep-purple`, `indigo`, `blue`, `light-blue`, `cyan`, `teal`, `green`, `light-green`, `lime`, `yellow`, `amber`, `orange`, `deep-orange`, `brown`, `grey`, `blue-grey`. You can also specify `custom` and then define `--md-primary-fg-color` yourself in the group's scoped CSS.

For fully custom per-section accent colors without using Material's color system:

```css
.parallax-group--features {
  --md-primary-fg-color: #c084fc;      /* purple-400 */
  --md-primary-fg-color--light: #e9d5ff;
  --md-primary-fg-color--dark: #7c3aed;
  --md-accent-fg-color: #a78bfa;
}
```

---

## Responsive Depth Scaling with `clamp()`

On very small screens, a `perspective: 2.5rem` is too aggressive — the parallax motion becomes jumpy and disorienting. Use `clamp()` to scale the perspective value with the viewport:

```css
.parallax-container {
  --md-parallax-perspective: clamp(1.5rem, 4vw, 2.5rem);
  perspective: var(--md-parallax-perspective);
}
```

This scales the perspective from `1.5rem` on narrow mobile screens to `2.5rem` on wide desktops, with `4vw` as the linear interpolation. The `clamp()` function is universally supported in modern browsers and requires no JavaScript.

You can also scale the depth values per layer if you want more fine-grained control:

```css
.parallax-layer[style*="--md-parallax-depth: 8"] {
  transform: translateZ(calc(var(--md-parallax-depth, 1) * -1rem * var(--depth-scale, 1)));
}

@media (max-width: 768px) {
  .parallax-container {
    --depth-scale: 0.6;
  }
}
```

---

## Viewport-Adaptive Hero Height: Media Queries Explained and Extended

The base hero height is `100vh`. On mobile devices, `100vh` includes the browser chrome (address bar), which causes layout shifts as the chrome hides on scroll. The fix is to use `100dvh` (dynamic viewport height) where supported, with a `100vh` fallback:

```css
.parallax-group--hero {
  height: 100vh;        /* fallback */
  height: 100dvh;       /* modern browsers */
}
```

For ultrawide displays (21:9 and wider, typically `min-aspect-ratio: 21/9`), a full-viewport hero becomes very tall relative to its width. Consider capping the height:

```css
@media (min-aspect-ratio: 21/9) {
  .parallax-group--hero {
    height: 100vh;
    max-height: 720px;
  }

  .parallax-container {
    /* Slightly reduce perspective depth to compensate for shorter hero */
    --md-parallax-perspective: 2rem;
  }
}
```

For portrait orientation on mobile (where a full-viewport hero might be 900px tall on a 390px wide phone):

```css
@media (max-width: 480px) and (orientation: portrait) {
  .parallax-group--hero {
    height: 75dvh;
  }
}
```

---

## Custom CSS Variables for Per-Layer Effects

The base system uses `--md-parallax-depth` and `--md-image-position` as the two primary layer controls. You can extend this pattern by adding your own variables for per-layer opacity, saturation, and blur effects.

### Adding opacity, saturation, and blur variables

Define the variables with defaults on the container so they cascade:

```css
.parallax-container {
  --layer-opacity: 1;
  --layer-saturation: 100%;
  --layer-blur: 0px;
}

.parallax-layer img,
.parallax-layer video {
  opacity: var(--layer-opacity);
  filter:
    saturate(var(--layer-saturation))
    blur(var(--layer-blur));
  transition:
    opacity 0.4s ease,
    filter 0.4s ease;
}
```

Then apply per-layer overrides using inline styles or data attributes:

```html
<!-- Far layer: slightly desaturated for atmospheric effect -->
<div class="parallax-layer"
     style="--md-parallax-depth: 8; --layer-saturation: 70%; --layer-opacity: 0.85;">
  <img src="layer-far.avif" alt="" aria-hidden="true" />
</div>

<!-- Mid layer: subtle blur for depth of field simulation -->
<div class="parallax-layer"
     style="--md-parallax-depth: 5; --layer-blur: 0.5px;">
  <img src="layer-mid.avif" alt="" aria-hidden="true" />
</div>
```

The blur on the far layer creates a simulated depth-of-field effect that reinforces the sense of distance. Keep blur values very small (0.3px–1px) — anything larger looks like a rendering error rather than an artistic choice.

---

## The Scroll Indicator Arrow and Bounce Animation

The scroll indicator arrow at the bottom of the hero uses a simple `@keyframes bounce` animation. The implementation:

```css
.parallax-scroll-indicator {
  position: absolute;
  bottom: 3.2rem;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  color: rgba(255, 255, 255, 0.5);
  font-size: 0.7rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  pointer-events: none;
  z-index: 10;
}

.parallax-scroll-arrow {
  width: 24px;
  height: 24px;
  animation: bounce 2.4s cubic-bezier(0.445, 0.05, 0.55, 0.95) infinite;
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
    opacity: 0.5;
  }
  50% {
    transform: translateY(8px);
    opacity: 1;
  }
}
```

The `cubic-bezier(0.445, 0.05, 0.55, 0.95)` is an ease-in-out-sine curve, which gives the bounce a natural deceleration at both ends rather than a mechanical linear bounce. To hide the indicator after the user has scrolled:

```javascript
const indicator = document.querySelector('.parallax-scroll-indicator');
const container = document.querySelector('.parallax-container');

container.addEventListener('scroll', function handler() {
  if (container.scrollTop > 50) {
    indicator.style.opacity = '0';
    indicator.style.pointerEvents = 'none';
    container.removeEventListener('scroll', handler);
  }
}, { passive: true });
```

---

## Blend Layer Customization

The blend layer is a `translateZ(0)` absolute-positioned element that sits above the image layers but below the hero text content. Its purpose is to apply a gradient that helps text remain readable over the varying image layers underneath.

**Default gradient:**

```css
.parallax-layer--blend {
  background: linear-gradient(
    to bottom,
    rgba(0, 0, 0, 0.15) 0%,
    rgba(0, 0, 0, 0.0) 40%,
    rgba(0, 0, 0, 0.5) 100%
  );
  transform: translateZ(0);
  position: absolute;
  inset: 0;
  z-index: 5;
  pointer-events: none;
}
```

**Changing the gradient color** — for a warm amber tint across the bottom:

```css
.parallax-layer--blend {
  background: linear-gradient(
    to bottom,
    rgba(0, 0, 0, 0.2) 0%,
    transparent 35%,
    rgba(120, 60, 0, 0.45) 100%
  );
}
```

**Adding a vignette** (darkens all four corners, useful for cinematic framing):

```css
.parallax-layer--vignette {
  background: radial-gradient(
    ellipse at center,
    transparent 55%,
    rgba(0, 0, 0, 0.6) 100%
  );
  transform: translateZ(0);
  position: absolute;
  inset: 0;
  z-index: 6;
  pointer-events: none;
}
```

Stack the blend and vignette as separate layers in the HTML — each is cheap (no image to decode) and gives you independent control.

---

## Hero Text Positioning

The hero text content lives in the base layer (`translateZ(0)`) and is positioned using:

```css
.parallax-hero-text {
  position: absolute;
  bottom: 3.2rem;
  left: 0;
  right: 0;
  padding: 0 var(--md-content-padding, 2rem);
  z-index: 10;
}
```

`bottom: 3.2rem` places the text above the scroll indicator arrow and clear of the bottom safe area on iOS devices. The value `3.2rem` is derived from: `1rem` (arrow height) + `0.5rem` (gap) + `1.2rem` (text line-height buffer) + `0.5rem` (safe area margin).

On mobile, the text stack needs adjustment because the viewport is narrower and the hero is shorter:

```css
@media (max-width: 768px) {
  .parallax-hero-text {
    bottom: 2rem;
    text-align: center;
  }

  .parallax-hero-text h1 {
    font-size: clamp(1.8rem, 7vw, 3rem);
  }
}
```

The `position: absolute` on the text container is intentional — it keeps the text pinned to the bottom of the hero regardless of the hero's height, which varies across breakpoints and `dvh` vs `vh` discrepancies.

---

## Adding a Video Layer

A video can replace any image layer by using a `<video>` element with the appropriate attributes. Video layers work best for the far or mid planes, where the motion is slowest and the video resolution demands are lowest.

```html
<div class="parallax-layer" style="--md-parallax-depth: 8; --md-image-position: center">
  <video
    class="parallax-layer-video"
    autoplay
    muted
    loop
    playsinline
    preload="metadata"
    aria-hidden="true"
  >
    <source src="assets/parallax/sky-timelapse.av1.webm" type="video/webm; codecs=av01" />
    <source src="assets/parallax/sky-timelapse.hevc.mp4" type="video/mp4; codecs=hvc1" />
    <source src="assets/parallax/sky-timelapse.mp4" type="video/mp4" />
  </video>
</div>
```

```css
.parallax-layer-video {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: var(--md-image-position, center);
  /* Prevent interaction interference */
  pointer-events: none;
}
```

**Required video attributes:**
- `autoplay` — starts without user interaction.
- `muted` — required by browsers as a condition of autoplaying.
- `loop` — plays continuously.
- `playsinline` — prevents iOS Safari from going fullscreen on play.
- `preload="metadata"` — loads enough to display the first frame before play.

**Performance note:** Video layers add significant network and GPU cost. Keep video files under 2MB, use AV1-encoded WebM as the primary source (best compression), and provide an AVIF still image as a fallback for browsers where the video fails to load:

```html
<video autoplay muted loop playsinline preload="metadata" aria-hidden="true"
       poster="assets/parallax/layer-far.avif">
  <source src="assets/parallax/sky.webm" type="video/webm; codecs=av01" />
  <source src="assets/parallax/sky.mp4" type="video/mp4" />
</video>
```

---

## Adding a Gradient Overlay Layer

Instead of an image, any layer can be a pure CSS gradient. This is useful for creating a color wash over the layers below, or for adding a color zone that reinforces the scene's mood.

```html
<div class="parallax-layer parallax-layer--gradient"
     style="--md-parallax-depth: 3"
     aria-hidden="true">
</div>
```

```css
.parallax-layer--gradient {
  background: linear-gradient(
    135deg,
    rgba(255, 160, 0, 0.12) 0%,
    transparent 50%,
    rgba(60, 80, 200, 0.08) 100%
  );
}
```

Gradient layers are essentially free in terms of rendering cost (no texture, no image decode) and can add significant visual polish. They respond to the same depth system as image layers, so a gradient at `--md-parallax-depth: 3` will parallax at the correct speed relative to the image layers around it.

---

## Parallax Without MkDocs: Porting to Plain HTML

If you want to use this parallax system outside of MkDocs, you need to replace or remove the Material-specific classes and variables.

**Material-specific classes to remove or replace:**

| Material class/attribute | Plain HTML equivalent |
|---|---|
| `data-md-color-scheme` | Add/remove a CSS class on `<html>` |
| `data-md-color-primary` | Set a CSS custom property directly |
| `md-content` | Any `<main>` or `<article>` wrapper |
| `md-typeset` | Add your own typography base styles |
| `--md-content-padding` | Replace with your own padding variable |

**Minimal plain HTML structure:**

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { height: 100%; overflow: hidden; }

    .parallax-container {
      height: 100vh;
      overflow: hidden auto;
      perspective: 2.5rem;
      perspective-origin: 50% 0%;
      overscroll-behavior-y: none;
    }

    .parallax-group {
      position: relative;
      transform-style: preserve-3d;
      height: 100vh;
    }

    .parallax-layer {
      position: absolute;
      inset: 0;
    }

    .parallax-layer img {
      position: absolute;
      inset: 0;
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    /* Depth calculation: translateZ pushes the layer back,
       scale() compensates so it still fills the viewport */
    .parallax-layer[data-depth="8"] {
      transform: translateZ(-8rem) scale(4.2);
    }
    .parallax-layer[data-depth="5"] {
      transform: translateZ(-5rem) scale(3);
    }
    .parallax-layer[data-depth="2"] {
      transform: translateZ(-2rem) scale(1.8);
    }
    .parallax-layer[data-depth="1"] {
      transform: translateZ(-1rem) scale(1.4);
    }
    .parallax-layer[data-depth="0"] {
      transform: translateZ(0);
      position: relative;
    }
  </style>
</head>
<body>
  <div class="parallax-container">
    <div class="parallax-group">
      <div class="parallax-layer" data-depth="8">
        <img src="layer-far.avif" alt="" />
      </div>
      <div class="parallax-layer" data-depth="5">
        <img src="layer-mid.avif" alt="" />
      </div>
      <div class="parallax-layer" data-depth="2">
        <img src="layer-near.avif" alt="" />
      </div>
      <div class="parallax-layer" data-depth="1">
        <img src="layer-front.avif" alt="" />
      </div>
      <div class="parallax-layer" data-depth="0">
        <h1>Your Hero Text</h1>
      </div>
    </div>
  </div>
</body>
</html>
```

The scale factor for each depth level is derived from: `scale = (perspective + |translateZ|) / perspective`. For `perspective: 2.5rem` and `translateZ(-8rem)`: `(2.5 + 8) / 2.5 = 4.2`. This formula ensures that layers pushed back in Z-space still fill the viewport.

---

## `overscroll-behavior-y: none` on the Scroll Container

The parallax container sets `overscroll-behavior-y: none` to prevent two specific browser behaviors:

1. **iOS bounce effect.** On Safari for iOS, scrollable elements have a rubber-band overscroll effect. When the parallax container hits the top or bottom of its scroll range, this bounce disrupts the 3D perspective and produces a jarring visual glitch.
2. **Chrome pull-to-refresh.** On Chrome for Android, pulling down from the top of a scrollable area triggers a refresh spinner. `overscroll-behavior-y: none` disables this for the container.

Without this property, both effects cause the `perspective` origin to shift momentarily, which makes the entire parallax scene "snap" in an unpleasant way. This is a CSS-only fix with no JavaScript required.

---

## `scroll-behavior: smooth` on the Container

The parallax container optionally sets `scroll-behavior: smooth` to animate anchor-link navigation. Keep it when:

- You have in-page anchor links (e.g., a "scroll down" button that targets `#content`).
- The animation duration (browser-controlled, typically ~300ms) is acceptable.

Remove or disable it when:

- You are using a JavaScript-controlled scroll animation (smooth + JS scroll = double animation, appears to stutter).
- Users are navigating via keyboard to sections below the fold — smooth scroll can disorient screen reader users if the jump is large.

To disable smooth scroll programmatically without removing it from the stylesheet:

```javascript
// Disable smooth scroll for specific programmatic scrolls
container.style.scrollBehavior = 'auto';
container.scrollTo({ top: targetOffset });
// Re-enable after frame
requestAnimationFrame(() => {
  container.style.scrollBehavior = '';
});
```

---

## Performance Deep-Dive

### Compositor layers and `will-change`

The browser composites each parallax layer on the GPU. To force this promotion without waiting for the animation to trigger it:

```css
.parallax-layer img,
.parallax-layer video {
  will-change: transform;
}
```

However, `will-change: transform` consumes GPU texture memory. With four image layers at 2560×800px each, you are holding approximately 80MB of texture memory on the GPU (4 layers × 2560 × 800 × 4 bytes per pixel). On mobile devices with shared GPU memory (typically 256–512MB total), this is significant.

Only apply `will-change` to the layers that actually animate:

```css
/* Only image layers parallax — the text base layer does not */
.parallax-layer:not(.parallax-layer--base) img {
  will-change: transform;
}
```

### GPU memory budget

A rough memory budget for the four AVIF layers after GPU decode:

| Layer | Dimensions | GPU texture memory |
|---|---|---|
| Far | 2560 × 800 | ~7.8 MB |
| Mid | 2560 × 800 | ~7.8 MB |
| Near | 2560 × 800 (RGBA) | ~7.8 MB |
| Front | 2560 × 800 (RGBA) | ~7.8 MB |
| Total | — | ~31 MB |

This is comfortably within budget on desktop (where GPU memory is typically 2–8GB) and marginal but acceptable on mid-range mobile.

### Testing with Chrome Layers panel

1. Open DevTools (`F12`).
2. Open the **Layers** panel: Menu > More Tools > Layers.
3. Scroll the page to trigger the parallax.
4. In the Layers panel, each parallax layer should appear as a separate compositor layer (shown as a blue bordered rectangle in the 3D view).
5. Check the "Memory" column — it shows the texture memory cost of each layer.
6. If a layer is not promoted to its own compositor layer, check that `transform-style: preserve-3d` is set on its parent and that there is no `overflow: hidden` on an ancestor that flattens the 3D context.

---

## Reduced Motion: Complete CSS Implementation

The `prefers-reduced-motion` media query must be respected. Users who opt into reduced motion typically have vestibular disorders — the fast-moving parallax layers can cause genuine physical discomfort.

A complete graceful degradation:

```css
@media (prefers-reduced-motion: reduce) {
  /* Disable 3D perspective — all layers render flat */
  .parallax-container {
    perspective: none;
    overflow-y: auto;
  }

  /* Make all layers position: relative and stack normally */
  .parallax-group {
    transform-style: flat;
  }

  .parallax-layer {
    position: relative !important;
    transform: none !important;
    inset: auto;
  }

  /* Show only the base layer image as a static hero */
  .parallax-layer:not(.parallax-layer--base) {
    display: none;
  }

  /* Show the far layer as a static background */
  .parallax-group--hero {
    background-image: url("assets/parallax/layer-far.avif");
    background-size: cover;
    background-position: center;
  }

  /* Remove all animations */
  .parallax-scroll-arrow,
  .parallax-scroll-indicator {
    animation: none;
  }
}
```

This approach shows the far layer as a static background image and hides the other layers, giving a clean, accessible hero with no motion.

---

## Touch and Mobile: iOS and Android Behavior

The CSS 3D parallax works on touch devices with two important caveats:

1. **iOS Safari.** Scrolling inside a non-`document` scroll container on iOS uses momentum scrolling, which is fast and smooth. However, iOS Safari historically had a bug where `perspective` was applied inconsistently within overflow-scrolling containers. The workaround is the Safari-specific fix described below.

2. **Android Chrome.** Chrome for Android handles the parallax correctly with no special treatment. Ensure `overscroll-behavior-y: none` is set to prevent pull-to-refresh.

**Touch scrolling inside the container:** To enable smooth momentum scrolling on iOS:

```css
.parallax-container {
  -webkit-overflow-scrolling: touch;   /* legacy Safari */
  overflow: hidden auto;
}
```

Note: `-webkit-overflow-scrolling: touch` is deprecated but harmless on modern iOS and still required for iOS 12 and earlier.

---

## Safari `contain` Fix

Safari has a bug where `contain: strict` or `contain: layout paint` on an ancestor element collapses the 3D context of the parallax layers, making them all render at `z=0`. The symptom is that all layers scroll at the same speed despite having different `translateZ` values.

**Detection script:**

```javascript
(function () {
  const isSafari =
    /^((?!chrome|android).)*safari/i.test(navigator.userAgent) ||
    (navigator.userAgent.includes('Mac') && 'ontouchend' in document);

  if (isSafari) {
    document.documentElement.classList.add('is-safari');
  }
})();
```

**CSS fix using the `.is-safari` class:**

```css
.is-safari .parallax-container,
.is-safari .parallax-group,
.is-safari .parallax-layer {
  contain: none !important;
}

.is-safari .parallax-group {
  /* Safari also needs explicit transform-style on every ancestor */
  -webkit-transform-style: preserve-3d;
  transform-style: preserve-3d;
}
```

The `contain: none` override removes the containment boundary that was collapsing the 3D context. This is a targeted fix — it applies only on Safari and only to the parallax elements. The `!important` is necessary because MkDocs Material's stylesheet applies `contain: strict` to `.md-content` elements to optimize paint performance.

---

## Firefox Repaint Bug

Firefox (versions before 120) has a repaint bug where the parallax layers stop compositing correctly after rapid scroll input, causing a brief flash of the background color between layer repaints. The workaround involves toggling a CSS class on scroll events to force a repaint cycle.

**The scroll listener approach:**

```javascript
(function () {
  const isFirefox = navigator.userAgent.toLowerCase().includes('firefox');
  if (!isFirefox) return;

  const container = document.querySelector('.parallax-container');
  if (!container) return;

  let rafId;
  let toggleState = false;

  container.addEventListener('scroll', function () {
    cancelAnimationFrame(rafId);
    rafId = requestAnimationFrame(function () {
      toggleState = !toggleState;
      container.classList.toggle('ff-repaint-hack', toggleState);
    });
  }, { passive: true });
})();
```

**The `.ff-repaint-hack` CSS toggle:**

```css
/* Alternates a harmless property to force a compositor update */
.ff-repaint-hack .parallax-layer {
  outline: 1px solid transparent;
}

.parallax-layer {
  outline: none;
}
```

**When to remove the listener:** Firefox 120+ (released November 2023) fixed the underlying repaint bug. Check `navigator.userAgent` for the Firefox version and skip the workaround for Firefox 120 and above:

```javascript
const ffVersion = parseInt(
  (navigator.userAgent.match(/Firefox\/(\d+)/) || [])[1] || '0'
);
if (isFirefox && ffVersion < 120) {
  // apply workaround
}
```

---

## Print Styles

The parallax hero should not appear in printed output. Printing a layered 3D scene produces garbled output and wastes toner. Hide the entire parallax structure for print:

```css
@media print {
  .parallax-container {
    height: auto;
    overflow: visible;
    perspective: none;
  }

  .parallax-group--hero {
    display: none;
  }

  .parallax-group--content {
    position: static;
    height: auto;
  }

  .parallax-layer {
    position: static;
    transform: none;
    height: auto;
  }
}
```

---

## Dark/Light Mode Toggle

The parallax hero looks best in dark mode. If your site supports a user-controlled light/dark toggle, wire it to `data-md-color-scheme` on the `<html>` element and persist the preference in `localStorage`:

```javascript
// Toggle function
function setColorScheme(scheme) {
  document.documentElement.setAttribute('data-md-color-scheme', scheme);
  localStorage.setItem('md-color-scheme', scheme);
}

// Read stored preference on load
(function () {
  const stored = localStorage.getItem('md-color-scheme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const scheme = stored || (prefersDark ? 'slate' : 'default');
  document.documentElement.setAttribute('data-md-color-scheme', scheme);
})();

// Wire to a toggle button
document.querySelector('.color-scheme-toggle')?.addEventListener('click', function () {
  const current = document.documentElement.getAttribute('data-md-color-scheme');
  setColorScheme(current === 'slate' ? 'default' : 'slate');
});
```

For the parallax hero specifically, force the dark scheme regardless of the user preference (the hero always looks best dark), and restore the user preference when the content section scrolls in:

```javascript
// Always show hero in dark mode
document.querySelector('.parallax-group--hero')?.addEventListener(
  'mdColorSchemeRequest',
  () => setColorScheme('slate')
);
```

---

## Adding Custom Fonts to the Hero Text

MkDocs Material loads fonts via Google Fonts by default. For hero text, you may want a display font that is not in Material's default set.

**In `mkdocs.yml`:**

```yaml
extra_css:
  - assets/stylesheets/home.css

extra_javascript:
  - assets/javascripts/home.js
```

**In `home.css`:**

```css
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&display=swap');

.parallax-hero-title {
  font-family: 'Playfair Display', Georgia, serif;
  font-weight: 900;
  font-size: clamp(2.5rem, 8vw, 7rem);
  line-height: 0.95;
  letter-spacing: -0.03em;
  color: #fff;
  /* Prevent FOUT (Flash of Unstyled Text) */
  font-display: block;
}
```

For best performance, self-host the font and use `<link rel="preload">` in the `home.html` override:

```html
<!-- In home.html, inside <head> -->
<link rel="preload"
      href="/assets/fonts/playfair-display-900.woff2"
      as="font"
      type="font/woff2"
      crossorigin />
```

Self-hosting avoids the Google Fonts DNS lookup, which can add 100–200ms to first paint on cold connections. Generate the font subset with [glyphhanger](https://github.com/zachleat/glyphhanger) to reduce file size to only the characters your hero text actually uses:

```bash
glyphhanger --whitelist="Your Hero Text Here" \
  --formats=woff2 \
  --subset=playfair-display-900.ttf
```

A subset font for 20 characters of hero text is typically 8–15 KB — dramatically smaller than the full 120KB font file.

---

## Summary Reference: CSS Variables

| Variable | Default | Controls |
|---|---|---|
| `--md-parallax-depth` | `1` | Layer depth (higher = slower scroll) |
| `--md-image-position` | `center` | `object-position` on layer images |
| `--md-parallax-perspective` | `2.5rem` | CSS `perspective` value on container |
| `--layer-opacity` | `1` | Per-layer opacity (custom extension) |
| `--layer-saturation` | `100%` | Per-layer color saturation (custom extension) |
| `--layer-blur` | `0px` | Per-layer blur filter (custom extension) |

## Summary Reference: Browser Quirks

| Browser | Issue | Fix |
|---|---|---|
| Safari (all) | `contain` collapses 3D context | `.is-safari` class + `contain: none` |
| Firefox < 120 | Repaint glitch on fast scroll | Scroll listener + `.ff-repaint-hack` toggle |
| iOS Safari | Bounce overscroll disrupts perspective | `overscroll-behavior-y: none` |
| Chrome Android | Pull-to-refresh interferes | `overscroll-behavior-y: none` |
| All browsers | `100vh` includes chrome on mobile | Use `100dvh` with `100vh` fallback |
