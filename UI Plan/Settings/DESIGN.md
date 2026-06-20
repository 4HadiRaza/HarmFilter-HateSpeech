---
name: HarmFilter Design System
colors:
  surface: '#141218'
  surface-dim: '#141218'
  surface-bright: '#3b383e'
  surface-container-lowest: '#0f0d13'
  surface-container-low: '#1d1b20'
  surface-container: '#211f24'
  surface-container-high: '#2b292f'
  surface-container-highest: '#36343a'
  on-surface: '#e6e0e9'
  on-surface-variant: '#cbc4d2'
  inverse-surface: '#e6e0e9'
  inverse-on-surface: '#322f35'
  outline: '#948e9c'
  outline-variant: '#494551'
  surface-tint: '#cfbcff'
  primary: '#cfbcff'
  on-primary: '#381e72'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#6750a4'
  secondary: '#cdc0e9'
  on-secondary: '#342b4b'
  secondary-container: '#4d4465'
  on-secondary-container: '#bfb2da'
  tertiary: '#e7c365'
  on-tertiary: '#3e2e00'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#141218'
  on-background: '#e6e0e9'
  surface-variant: '#36343a'
typography:
  hero-num:
    fontFamily: Epilogue
    fontSize: 64px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.04em
  title-lg:
    fontFamily: Epilogue
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.2'
  section-header:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: 2px
  body-reading:
    fontFamily: Newsreader
    fontSize: 17px
    fontWeight: '400'
    lineHeight: '1.6'
  ui-label:
    fontFamily: Space Grotesk
    fontSize: 13px
    fontWeight: '500'
    lineHeight: '1.0'
  micro-label:
    fontFamily: Space Grotesk
    fontSize: 10px
    fontWeight: '700'
    lineHeight: '1.0'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-padding: 16px
  element-gap: 12px
  section-margin: 32px
  grid-columns: '12'
  gutter: 12px
---

## Brand & Style

This design system establishes a high-stakes, "Digital Guardian" aesthetic tailored for a youth audience that values both street-style edge and technical sophistication. It merges the raw, structural integrity of **Brutalism**—seen in its heavy borders and monospaced accents—with a **Sleek Minimalism** that utilizes pitch-black voids to create depth and focus.

The visual narrative is one of a "Security Command Center" translated into a premium consumer experience. It evokes a sense of urgency and importance through the use of Vivid Crimson accents against a monochromatic base, demanding attention without sacrificing the smooth, addictive flow of a modern social application. The goal is to make digital safety feel like an elite skill rather than a chore.

## Colors

The palette is strictly nocturnal, utilizing a "Total Black" philosophy to maximize contrast and reduce eye strain during late-night usage. 

- **The Red Thread:** The Vivid Crimson Red (#E8001D) is the only allowed chromatic accent. It represents both the "Danger" of the digital world and the "Power" of the user to control it.
- **Surface Hierarchy:** Depth is achieved through subtle shifts in dark grays. Avoid using shadows for depth; instead, use the defined surface increments and the 1px #2A2A2A border to delineate objects.
- **Prohibitions:** Blue and purple are strictly forbidden to ensure the design remains distinct from generic tech and social platforms. White backgrounds are replaced with #F5F5F5 text on black for a high-contrast, premium feel.

## Typography

The typographic system uses a tri-font strategy to balance impact, readability, and technical flavor.

1.  **Display (Epilogue):** Used for headlines and major impact numbers. It should feel heavy and undeniable.
2.  **UI & Labels (Space Grotesk):** This serves as the "Terminal" font. It provides the security dashboard feel. All section headers must be uppercase with wide tracking (2px) to mimic data readouts.
3.  **Reading (Newsreader):** For long-form educational content. The serif choice adds an air of traditional authority and "literary" credibility to safety lessons, contrasting against the aggressive UI.

## Layout & Spacing

This design system utilizes a **Fixed-Fluid Hybrid Grid**. On mobile devices, content follows a 12px gutter system with 16px side margins. 

- **The 12px Rhythm:** Almost all spatial relationships are governed by the 12px increment (gap between cards, gap between icons and text).
- **Density:** The layout should feel dense but organized—resembling a dashboard where information is packed efficiently. 
- **Floating Navigation:** The primary navigation must be a detached, floating element positioned at the bottom of the screen, featuring a subtle red glow (#E8001D at 15% opacity) to signify the "active" safety state.

## Elevation & Depth

In this design system, elevation is not conveyed through traditional shadows, but through **Tonal Layering** and **Luminous Borders**.

- **Level 0 (Background):** #090909.
- **Level 1 (Cards/Content):** #111111 or #161616 with no border.
- **Level 2 (Interactive/Pinned):** #1C1C1C with a 1px solid border of #2A2A2A.
- **Glow Effects:** The only "soft" element in the UI is the Crimson Accent Glow. This is reserved for the floating navigation and critical "Active Shield" states. It should feel like a light source behind the UI, not a shadow beneath it.

## Shapes

The shape language is "Softened Geometric." 

- **Cards:** Use a 12px radius to maintain a modern, friendly app feel while the dark colors provide the "serious" edge.
- **Buttons:** A slightly tighter 8px radius distinguishes interactive actions from static containers.
- **Inputs:** Use a sharper 4px radius to reinforce the "terminal" and data-entry nature of the educational components.
- **Borders:** Every elevated surface (#1C1C1C) must have a 1px border. This "wireframe" look is essential to the Techno-Brutalist aesthetic.

## Components

**Buttons:**
- **Primary:** Background #E8001D, Text #F5F5F5 (Space Grotesk Bold).
- **Secondary:** Background transparent, Border 1px #2A2A2A, Text #F5F5F5.
- **Ghost:** Text #8A8A8A, no background.

**Cards:**
- All cards use #111111 or #161616. Elevated cards use #1C1C1C with the #2A2A2A border. Padding is strictly 16px.

**Inputs:**
- Background #090909, Border 1px #2A2A2A. On focus, the border changes to #E8001D with a 4px crimson outer glow.

**Floating Bottom Nav:**
- A detached pill shape. Background #161616 with a 1px #2A2A2A border. Icons are Lucide, 20px size. The active state features a Crimson Red icon and a subtle `0px 4px 20px rgba(232, 0, 29, 0.15)` glow beneath the pill.

**Progress Bars:**
- Track: #1F1F1F. Indicator: #E8001D. No rounded caps on the indicator (keep them flush/square) for a more technical appearance.

**Micro-Interactions:**
- Use "Terminal-style" cursor blinks for loading states. Transitions between screens should be "hard cuts" or "fast slides" (200ms) to maintain a high-performance feel.