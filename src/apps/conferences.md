---
title: Conference and event sites
description: Building a conference site with the parallax hero and a multi-track schedule.
---

# Conferences

A conference website lives a short, intense life. It exists for a few
months, gets heavy traffic in the weeks before the event, and then
becomes an archive. The template fits this lifecycle well: it is fast
to set up, cheap to host, and the hero gives the event a poster-like
identity that does the work a flat banner cannot.

## The pages a conference site needs

Almost every conference site eventually grows the same handful of
pages. Starting with the full set is faster than adding them under
deadline pressure:

```
src/
  index.md            # hero, dates, location, primary CTA
  schedule/
    index.md          # combined schedule
    day-1.md
    day-2.md
  speakers/
    index.md
    speaker-name.md
  venue.md
  travel.md
  faq.md
  code-of-conduct.md
  sponsors.md
```

A small event can collapse this into fewer pages. A multi-day event
with multiple tracks rarely can.

## The hero as a poster

A conference hero gets to be louder than a product hero. The visitor
arrives expecting a visual. The four-layer parallax stack maps well
to event imagery:

- Depth 8: city skyline, abstract gradient, or venue exterior.
- Depth 5: stage silhouettes, architectural mid-ground, or thematic
  props.
- Depth 2: speaker silhouettes or hero typography (event name).
- Depth 1: small foreground accents (lighting, particles, a logo
  mark).

Hero copy that earns its place:

- Event name.
- Dates and city.
- A single primary CTA: "Get tickets" or "Submit a talk" depending on
  where you are in the cycle.
- A countdown if the event is imminent.

A conference site changes phase: CFP, ticket sales, schedule release,
post-event archive. Plan to swap the primary CTA at each phase rather
than packing all of them into the hero at once.

## Schedule layouts

The schedule is the page visitors return to. It needs to be readable
on a phone in a hallway. MkDocs Material's content tabs handle a
multi-track schedule cleanly:

```markdown
=== "Track A"
    | Time  | Talk                         | Speaker      |
    |-------|------------------------------|--------------|
    | 09:00 | Opening keynote              | A. Speaker   |
    | 10:00 | Title of talk                | B. Speaker   |
    | 11:00 | Title of talk                | C. Speaker   |

=== "Track B"
    | Time  | Talk                         | Speaker      |
    |-------|------------------------------|--------------|
    | 09:00 | Opening keynote              | A. Speaker   |
    | 10:00 | Title of talk                | D. Speaker   |
    | 11:00 | Title of talk                | E. Speaker   |
```

For two tracks, tabs work. For four or more tracks, tables get
unreadable on mobile. In that case, split the schedule by time slot
rather than by track:

```markdown
## 10:00 — 10:45

- **Track A:** Title of talk — A. Speaker
- **Track B:** Title of talk — B. Speaker
- **Track C:** Title of talk — C. Speaker
- **Track D:** Title of talk — D. Speaker
```

This reads on any screen size and prints cleanly.

A separate page per day (`day-1.md`, `day-2.md`) is worth the small
duplication. It lets you link directly to a day from social posts and
keeps each page short enough to scan.

## Speaker pages

Two patterns work:

**Single page with anchor links.** All speakers on `speakers/index.md`,
each as a `##` section. Good for events under ~20 speakers. Fast to
maintain.

**One page per speaker.** Each speaker gets `speakers/speaker-name.md`
with their bio, talk title, abstract, and links. Necessary for events
where speakers want shareable URLs they can put on their own sites.

If you go with the per-speaker pattern, generate the index page from
the individual files rather than maintaining a parallel list. The
`mkdocs-awesome-pages-plugin` or a small build script can handle this.

## Venue, travel, and FAQ

These three pages share a property: they are searched, not browsed.
Visitors arrive on them via the navigation or a search query, read
one specific answer, and leave. Optimize for that:

- Use clear `##` headings that match the question being asked
  ("Is there parking?", "What time does registration open?").
- Put the answer in the first sentence under the heading.
- Avoid prose introductions; visitors do not read them.

For the FAQ, MkDocs Material's `details` admonitions work well as a
collapsible list:

```markdown
??? question "Is there a code of conduct?"
    Yes. See the [Code of conduct](code-of-conduct.md) page.
```

Collapsed by default, the FAQ stays scannable even with thirty entries.

## Phase changes

A conference site goes through predictable phases. Plan for each:

1. **Save the date.** Hero only, single page, dates and CTA to
   subscribe.
2. **CFP open.** Add `cfp.md` and switch the hero CTA.
3. **Tickets on sale.** Switch the hero CTA again. Add sponsors.
4. **Schedule released.** Add the schedule and speaker pages.
5. **Event week.** Pin venue, travel, and a "today's schedule" page.
6. **Post-event.** Add recordings, photos, and a thank-you note.
   Freeze the site as an archive.

Each phase is a small content change, not a rebuild. The template
absorbs all of them without structural edits.

## After the event

When the event ends, freeze the site rather than tearing it down.
Past conference sites are useful to future organizers and to speakers
linking to their talks. Add a banner ("Looking for next year? Visit
2027.example.com") and leave the rest in place.
