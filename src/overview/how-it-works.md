---
title: How CSS 3D Parallax Works
description: A complete technical deep-dive into the math, mechanics, and rendering pipeline behind pure-CSS 3D perspective parallax — perspective, translateZ, scale compensation, sticky positioning, paint containment, and browser quirks.
---

# How CSS 3D Parallax Works

This page is the long version. It walks through every CSS rule that contributes to the parallax effect, explains the math the browser is doing, and shows you what to look for when something is off. By the end you should be able to explain the technique to a colleague, debug a misbehaving layer, and adapt the approach to a non-MkDocs project.

The short version is this: there is no animation. There is no scroll listener. There is no `requestAnimationFrame` loop. The browser already projects 3D-transformed elements during scroll. We are just placing layers in 3D space and letting the compositor do its job.

---

## The CSS 3D coordinate system

Before any code, the mental model.

CSS 3D transforms operate in a right-handed coordinate system anchored to the element they apply to:

- **X** runs left to right
- **Y** runs top to bottom (yes, downward — this is unusual outside CSS)
- **Z** points out of the screen toward the viewer

A `translateZ(20px)` moves an element 20px toward you. A `translateZ(-20px)` pushes it 20px away. The browser draws the projected 2D result based on a vanishing point set by `perspective`.

The vanishing point is what makes 3D feel like depth. Without `perspective`, an element with `translateZ(-1000px)` looks identical to the same element with no transform — there is no projection happening, just a flat translation in a plane the user does not perceive.

`perspective` establishes that projection geometry. It is, effectively, the distance between the camera (the user) and the rendered surface. A small perspective value (like our `2.5rem`) creates a strong, exaggerated depth effect. A large perspective value (like `2000px`) creates a subtle, almost orthographic view.

---

## `perspective` (property) vs `perspective()` (function)

There are two ways to apply perspective in CSS, and they behave differently.

```css
/* Property — applied to the parent. All transformed children share one
   vanishing point anchored to this element. */
.scroll-container {
  perspective: 2.5rem;
}

/* Function — applied to the element itself. Each element gets its own
   independent vanishing point. */
.layer {
  transform: perspective(2.5rem) translateZ(-10rem);
}
```

For a parallax hero, you want the **property** form on the scroll container. Every layer inherits the same vanishing point, so they composite together as one coherent 3D scene. If each layer had its own `perspective()` function call, the layers would feel disconnected — a layer at depth 8 would have a completely different projection from a layer at depth 1, and the visual relationship between them would break.

The shared vanishing point is what makes the four `<picture>` elements read as one cinematic scene rather than four floating cards.

---

## The exact math

Here is the formula the browser uses to project a translated element back to 2D coordinates:

```
visual_movement = scroll_distance × (perspective / (perspective + |translateZ|))
```

Plug in our setup:

- `perspective = 2.5rem` (let's call this `p`)
- A layer at depth 8 has `translateZ(-8 × 2.5rem) = -20rem`

For every `1rem` of scroll, the depth-8 layer moves:

```
1rem × (2.5rem / (2.5rem + 20rem))
= 1rem × (2.5 / 22.5)
= 0.111rem
```

It moves about 11% as fast as the scroll itself. That is the parallax — slower movement for things that are further away.

Compare to depth 1 (`translateZ(-2.5rem)`):

```
1rem × (2.5rem / (2.5rem + 2.5rem))
= 1rem × 0.5
= 0.5rem
```

Depth 1 moves at half speed. Depth 0 (no translate) moves at full speed.

This is not a hack. It is the same projection math the browser uses for every transformed element on every page. We are just feeding scroll position into it.

---

## Scale compensation: why `scale(depth + 1)`

If you only `translateZ` a layer back, it appears smaller in the viewport because it is further from the camera. To keep each layer filling the viewport at the same visual size, you scale it up to compensate.

The compensation factor comes from the same projection math, inverted:

```
visual_size = original_size × (perspective / (perspective + |translateZ|))
```

For depth 8:

```
visual_size = 1 × (2.5 / 22.5) = 0.111
```

The layer would render at 11% of its source size. To bring it back to 100%, multiply by `(perspective + |translateZ|) / perspective`:

```
correction = (2.5 + 20) / 2.5 = 9
```

That equals `depth + 1`. For any depth value `d`:

```
correction = (p + d × p) / p = 1 + d = d + 1
```

So the CSS rule is:

```css
.mdx-parallax__layer {
  transform:
    translateZ(calc(var(--md-parallax-perspective) * var(--md-parallax-depth) * -1))
    scale(calc(var(--md-parallax-depth) + 1));
}
```

After projection and scaling cancel out, every layer appears full size. But the parallax remains, because the translate's effect on scroll-driven movement is independent of size. The compensation only restores apparent size — it does not undo the depth-dependent scroll rate.

---

## The scroll container vs document scroll

Most pages scroll the `html` or `body` element. This implementation does not. The parallax wraps everything in a custom scroll container:

```css
.mdx-parallax {
  height: 100vh;
  overflow: hidden auto;
  perspective: 2.5rem;
  perspective-origin: 50vw 50vh;
  width: 100vw;
}
```

This matters for several reasons:

1. **`perspective` only works on its children.** If the scrolling element is `body`, you cannot put `perspective` on `body` and have it apply to a positioned child without breaking other layout assumptions. A dedicated container is cleaner.
2. **`overflow: hidden auto`** turns this element into a scroll viewport. The browser treats it as the scrolling surface and renders its scrollable height accordingly.
3. **Document-level scroll bars are suppressed.** The parallax owns the scrolling experience. The user scrolls inside the container, not outside it.

This is a tradeoff. You lose some browser features that assume document-level scroll (like scroll-restoration, some smooth-scrolling defaults, and certain mobile gestures). You gain a clean isolation that lets perspective behave predictably.

---

## Sticky text and `margin-bottom: -100vh`

The hero text sits in front of the layers but does not parallax. It is sticky:

```css
.mdx-hero__scrollwrap {
  height: 100vh;
  margin-bottom: -100vh;
  position: sticky;
  top: 0;
  z-index: 9;
}
```

`position: sticky` with `top: 0` pins the element to the top of its containing block as you scroll past it. As long as the wrapper has room to be sticky inside its parent group, the text stays glued to the top of the viewport.

The `margin-bottom: -100vh` is the critical detail. Without it, the sticky wrapper would still occupy `100vh` of layout space inside the group, pushing all subsequent content down by a full viewport height. The negative margin pulls subsequent content back up so the next group starts immediately after the hero — visually overlapping the bottom of the sticky text region without disrupting layout.

This is the standard "sticky overlay" pattern. The element is sticky for paint, transparent for layout.

---

## Paint containment with `contain: strict`

The first parallax group sets:

```css
.mdx-parallax__group:first-child {
  contain: strict;
  height: 140vh;
}
```

`contain: strict` is shorthand for `contain: size layout paint style`. It tells the browser:

- **size**: this box's size is independent of its children — children can't make it grow
- **layout**: layout inside this box does not affect anything outside
- **paint**: nothing rendered inside this box paints outside its borders
- **style**: counter and quote scopes are local

For us, **paint** is the critical part. Layers are scaled up by `scale(depth + 1)` — a depth-8 layer is 9× its source size. Without paint containment, the scaled-up layer would bleed outside the hero section and paint over the content groups below it. With `contain: strict`, the bleed is clipped at the section boundary.

The cost: an additional compositor layer is spawned for the contained box, and the box is excluded from some optimizations (because the browser must enforce the containment guarantees). Worth it for the parallax — those layers are huge.

---

## Why the first group is `140vh` (and adapts to wide viewports)

Because the far layer at depth 8 only scrolls at 11% of viewport speed, it needs significantly more scroll runway to traverse a meaningful portion of itself. If the first group were only `100vh`, the far layer would barely move before the user scrolled past it. The hero would feel static.

Setting `height: 140vh` gives 40% extra scroll distance, which translates to roughly 4.4% of viewport height of far-layer movement (40% × 11%). That's the visible parallax sweep.

On wide viewports the math shifts. A 21:9 monitor is much wider than tall, and `100vh` is small compared to `100vw`. The CSS uses media queries keyed to the height-vs-width ratio:

```css
@media (min-width: 125vh) { .mdx-parallax__group:first-child { height: 120vw; } }
@media (min-width: 137.5vh) { .mdx-parallax__group:first-child { height: 125vw; } }
@media (min-width: 150vh) { .mdx-parallax__group:first-child { height: 130vw; } }
@media (min-width: 162.5vh) { .mdx-parallax__group:first-child { height: 135vw; } }
@media (min-width: 175vh) { .mdx-parallax__group:first-child { height: 140vw; } }
@media (min-width: 187.5vh) { .mdx-parallax__group:first-child { height: 145vw; } }
@media (min-width: 200vh) { .mdx-parallax__group:first-child { height: 150vw; } }
```

`min-width: 125vh` evaluates true when the viewport width is at least 1.25× its height — a moderately wide aspect ratio. The further you go, the taller the hero becomes (in `vw` units), preserving enough scroll distance for the parallax to read.

---

## The blend layer

After the four image layers, there is a fifth empty layer:

```html
<div class="mdx-parallax__layer mdx-parallax__blend"></div>
```

Its job is purely visual:

```css
.mdx-parallax__blend {
  background-image: linear-gradient(to bottom, transparent, var(--md-default-bg-color));
  bottom: 0;
  height: min(100vh, 100vw);
  top: auto;
}
```

It is a gradient from transparent at the top to the page background color at the bottom. Without it, the transition from the hero scene to the next content group is a hard horizontal line where the layers stop and the next section's solid background begins. The blend layer feathers that transition into a soft fade.

It uses `--md-default-bg-color` so it always matches whatever theme is active.

---

## Z-index stacking

The CSS sets:

```css
.mdx-parallax__layer {
  z-index: calc(10 - var(--md-parallax-depth, 0));
}
```

A layer at depth 1 (foreground) gets `z-index: 9`. A layer at depth 8 (far background) gets `z-index: 2`. The blend layer (no depth) gets `z-index: 10`. The hero text wrapper has `z-index: 9` and is the topmost interactive element.

This explicit stacking matters because the `transform-style: preserve-3d` context normally orders elements by their Z position, but the order can flip in subtle ways when scaling and translating combine. Setting `z-index` removes the ambiguity and guarantees the closest-feeling layers paint on top of the further ones.

---

## Browser quirks

### Safari and `contain`

Safari handles `contain: strict` differently from Chrome and Firefox. In Safari, paint containment can clip transformed children that should still be visible — the layers disappear at certain scales. The fix is to disable containment for Safari:

```html
<script>
  if ("Apple Computer, Inc." === navigator.vendor)
    document.documentElement.classList.add("safari")
</script>
```

```css
.safari .mdx-parallax__group:first-child {
  contain: none;
}
```

The detection is feature-flagged on `navigator.vendor` because that string is Safari-specific. Removing `contain` costs a small amount of paint area (since layers can technically bleed outside the section), but in practice the bleed is invisible because subsequent groups paint on top.

### Firefox repaint bug

Firefox has a bug where `contain: strict` combined with the initial scroll position causes a brief repaint flash on first interaction. The workaround is to remove `contain` for the first few thousand pixels of scroll, then restore it:

```javascript
if (navigator.userAgent.includes("Gecko/")) {
  const el = document.querySelector(".mdx-parallax")
  el.addEventListener("scroll", function handler() {
    if (el.scrollTop > 3000) {
      document.body.classList.remove("ff-hack")
      el.removeEventListener("scroll", handler)
    } else {
      document.body.classList.toggle("ff-hack", el.scrollTop <= 1)
    }
  }, { passive: true })
}
```

```css
.ff-hack .mdx-parallax__group:first-child {
  contain: none !important;
}
```

The listener is cheap (`passive: true`, fires only on scroll, removes itself after threshold). Once the user is past the hero section, the listener detaches and Firefox runs without the workaround.

---

## Why this beats JavaScript scroll listeners

A JavaScript parallax typically looks like:

```javascript
window.addEventListener("scroll", () => {
  const y = window.scrollY
  layer1.style.transform = `translateY(${y * 0.1}px)`
  layer2.style.transform = `translateY(${y * 0.3}px)`
  // ...
})
```

This runs on the **main thread**, the same thread that handles JavaScript, layout, and paint. Every scroll event triggers JS, which mutates inline style, which the browser must reconcile against the existing layout, then re-paint. On slow devices or under heavy JS load, this loop runs longer than the 16.67ms frame budget — and you get visible jank.

The CSS perspective approach runs on the **compositor thread**, which is decoupled from the main thread. The compositor takes the GPU layers (already painted) and re-projects them based on scroll position. There is no JS to run, no layout to recompute, no repaint. Even on a saturated main thread, the parallax remains smooth.

This is the same reason `transform` and `opacity` are the only CSS properties recommended for animation — they are compositor-only.

---

## Why this beats `animation-timeline: scroll()`

The CSS Scroll-Linked Animations API lets you bind keyframe animations to scroll position:

```css
@keyframes drift {
  from { transform: translateY(0); }
  to   { transform: translateY(-100px); }
}

.layer {
  animation: drift linear;
  animation-timeline: scroll();
}
```

This is conceptually similar to our perspective approach, but with weaker support and worse performance characteristics on some engines. Browser support is limited (Chromium only, until Firefox catches up). And on engines that do implement it, the animation is still computed per-element rather than as a single GPU projection — so a 4-layer parallax becomes 4 independently-driven animations.

The perspective approach uses one transform per layer, all driven by a single scroll position via the projection matrix. It is simpler, faster, and works in every browser.

---

## Debugging

Chrome DevTools has two tools that help when something is wrong:

1. **Layers panel** (Application → Layers, or `Ctrl+Shift+P` → "Show Layers")
   - Shows every compositor layer the browser created
   - Each `.mdx-parallax__layer` should appear as its own layer
   - If a layer is missing, check that `transform-style: preserve-3d` is set on the parent group

2. **3D View** (Layers panel toolbar, "3D View" button)
   - Tilts the rendered page so you can see Z-positioned elements as if from the side
   - Useful for verifying that layers are at the depths you expect
   - You should see four flat planes at increasing distances behind the viewport

Common failure modes and what to check:

| Symptom | Likely cause |
|---|---|
| All layers move at the same speed | `transform-style: preserve-3d` missing on the group |
| Layers are tiny | `scale(depth + 1)` rule missing or overridden |
| Layers bleed past the hero section | `contain: strict` missing or overridden by browser-specific override |
| Hero text scrolls with the page | Sticky wrapper missing `top: 0` or `position: sticky` |
| First scroll causes a flash | Firefox `.ff-hack` not applied |
| Layers disappear on Safari | `.safari` class not removing `contain` |
| Wide layers crop the wrong area | `--md-image-position` set incorrectly per layer |

The math is straightforward, the rules are few, and the browser does most of the work. When something is wrong, it is almost always one missing rule or a typo in a CSS variable name.
