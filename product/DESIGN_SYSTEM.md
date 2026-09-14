# Design System — Sunlit QuietEarth

Revised at M1.6. The previous direction ("warm earthy calm") was executed as beige on beige and read
as a wellness brochure: low contrast, brown-dominant, visually tired. Calm was confused with muted,
and muted became sleepy. See `duck/m1_6_inference_and_visual_reset.md` for the full reset.

**Sunlit QuietEarth = Gentler Streak energy + QuietEarth introspection.**
Bright, optimistic, spacious, tactile, playful — and still introspective.
Not spa. Not ashram. Not AI app. Not mental-health clinic.

## Design references translated, not copied
Borrow interaction lessons only:
- Gentler Streak: **the quality bar.** Calm can be bright. Softer UI, clearer cards, hero information
  visible rather than buried, light visual treatment, liveliness without noise.
- Calm: immediate serenity and low cognitive load.
- Headspace: meditation feels approachable rather than mystical or intimidating.
- Balance: personalization is part of the daily loop, not a settings checkbox.
- Waking Up: intellectual seriousness, strong typography, room for explanation.

Do NOT copy their illustrations, layouts, photography, icons, shapes, brand colours, copy, or trade
dress. Gentler Streak is a bar, not a source.

## Palette

### Light — the default, and the one that must feel alive
| Token | Hex | Use |
|---|---|---|
| `sunlitIvory` | `#FDF7EC` | canvas |
| `daylight` | `#FFFFFF` | cards, sheets |
| `deepSpruce` | `#12332B` | primary text, primary action fill |
| `spruceMuted` | `#41594E` | secondary text |
| `seaGlass` | `#3FAE8C` | primary fresh green: illustration, active states, large fills |
| `mintWash` | `#DCF1E8` | tinted surfaces, selected chips |
| `tangerine` | `#EE7A52` | energy accent: highlights, at most one CTA per screen |
| `coralWash` | `#FDE6DB` | tinted surfaces |
| `lemonSun` | `#F2C14E` | sunlight highlight, used sparingly |
| `lemonWash` | `#FBF0CE` | tinted surfaces |
| `hairline` | `#E8DFCE` | 1pt separators |

### Dark — night, not gloom
| Token | Hex |
|---|---|
| canvas | `#101B18` |
| card | `#182722` |
| ink | `#F2EFE6` |
| secondary text | `#B9C9C0` |
| `seaGlass` | `#6FD3B4` |
| `tangerine` | `#FF9670` |
| `lemonSun` | `#F7D67A` |
| `hairline` | `#2A3A33` |

Keep accents bright in dark mode. Do not desaturate the product into a cave.

### Palette rules
- Text is `deepSpruce` on ivory or white. No text-on-beige murk.
- Tangerine and lemon are accents, never backgrounds for small text. Small text on an accent fill is
  `deepSpruce`, never white.
- One accent leads per screen; two accents in one composition is the ceiling.
- Brown is gone: no clay `#B7795E`, no saffron `#D39A45`, no beige-on-beige surfaces.
- Every shipped pairing is contrast-tested: ≥ 4.5:1 body, ≥ 3:1 large text and meaningful glyphs, in
  both schemes, at all Dynamic Type sizes.

## Layout
- **One hero visual per screen**, upper area, confident scale. Every screen has a single clear subject.
- Cards: `daylight` on `sunlitIvory`, 24pt radius, one soft warm elevation
  (`rgba(60, 40, 20, 0.06)`, y 8, blur 24). This deliberately reverses the old "very little shadow"
  rule — a white card on a tinted canvas needs separation to read as tactile.
- More white space than before, not less. Generous margins, tall section rhythm, fewer elements.
- Hero information is visible, not buried: today's practice, the current hypothesis, and day `x/7`
  read at a glance without expansion.
- One primary decision per screen. 44pt+ targets. Corners 18–24pt, not pill-everything.
- Type and spacing carry hierarchy before containers do.

## Typography
Apple system typography first, to stay native and avoid licensing problems.
- SF Pro for all functional text.
- New York for short reflective headings only.
- Hero headings larger and airier than the previous build: 34–40pt display with generous leading.

## Visual motif — the attention path
QuietEarth's identity remains the attention path, now sunlit and flowing rather than thin grey contour
lines on beige. Organic ribbons with warm gradient washes in sea glass, mint, coral, and lemon;
hand-drawn in feel, never mechanical.

The motif carries the methodology:
- **Onboarding** — one wide sunlit ribbon drifting across the screen.
- **Profile** — two ribbons, self-report and observation, touching where they agree and separating
  visibly where they differ. The disagreement is drawn, not only written.
- **Practice** — loops gathering toward a single anchor.
- **Completion / Day 7** — one continuous warm path under a sunrise wash.

A wash is warm sunlight. It is never a violet/blue AI gradient; the palette tokens enforce this.
The motif is a metaphor, not a score or a promise of enlightenment.

## Motion
- Light springs on arrivals and selections, 180–320ms. More playful than the previous 200–500ms.
- The attention path animates on profile reveal and session completion — a drift, not a bounce.
- Subtle haptics on real transitions only.
- No streaks, badges, confetti, or gamified celebration.
- Reduce Motion replaces every animated path with its resolved static state; nothing becomes
  unreachable or unreadable.

## Forbidden
Generic AI aesthetics:
- electric violet/blue gradients
- glowing neural networks
- glassmorphism
- chat bubbles as primary UI
- sparkles and "AI magic" iconography

Meditation clichés:
- stock yogis
- lotus logo by default
- mountain-lake hero photography
- chakras, incense, pebbles

Added at M1.6:
- beige-on-beige, brown-dominant surfaces, low-contrast "spa" palettes, gloom
- **any trait-attached gauge, score ring, meter, or percentage-filled progress bar.** Confidence and
  evidence strength are shown as words or a four-step ordinal indicator. See the numbers policy in
  `duck/m1_6_inference_and_visual_reset.md` — this is a visual rule as much as a copy rule.

## Tone
Calm, curious, non-authoritarian — brighter in delivery, unchanged in substance.
Prefer: `Here's what we think so far.` · `We found evidence both for and against this.` · `Let's test that.`
Avoid: `Your true mind type is…` · `AI detected your cognitive style.` · `Your focus score is…`
