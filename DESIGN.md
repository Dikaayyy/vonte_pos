---
version: 1
name: Vonte Soft Glass
app: Vonte PoS
colors:
  background: "#EAF1F4"
  atmos-teal: "#99F6E4"
  atmos-sky: "#BAE6FD"
  surface-card: "#FFFFFF"
  surface-glass: "rgba(255,255,255,0.62)"
  surface-glass-strong: "rgba(255,255,255,0.80)"
  border-glass: "rgba(255,255,255,0.85)"
  border-hairline: "rgba(15,23,42,0.08)"
  shadow: "rgba(15,23,42,0.08)"
  primary: "#0F766E"
  primary-pressed: "#115E59"
  primary-soft: "#CCFBF1"
  on-primary: "#FFFFFF"
  on-surface: "#0F172A"
  on-surface-variant: "#475569"
  on-surface-muted: "#5F6C7B"
  success: "#15803D"
  success-soft: "#DCFCE7"
  warning: "#B45309"
  warning-soft: "#FEF3C7"
  error: "#B91C1C"
  error-soft: "#FEE2E2"
typography:
  fontFamily: Manrope
  fontFeatures: ["tabular-figures"]
  total-display:
    fontSize: 32px
    fontWeight: 800
    letterSpacing: -0.02em
  headline-lg:
    fontSize: 22px
    fontWeight: 700
  headline-md:
    fontSize: 18px
    fontWeight: 700
  title:
    fontSize: 16px
    fontWeight: 600
  body-md:
    fontSize: 14px
    fontWeight: 500
  body-sm:
    fontSize: 13px
    fontWeight: 500
  label:
    fontSize: 14px
    fontWeight: 600
  caption:
    fontSize: 12px
    fontWeight: 500
  price:
    fontSize: 15px
    fontWeight: 700
rounded:
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  gutter-compact: 16px
  gutter-expanded: 24px
sizes:
  touch-min: 48px
  button-height: 52px
  button-height-primary: 56px
  chip-height: 40px
  nav-bar-height: 64px
  cart-panel-width: 380px
breakpoints:
  compact: "< 600dp (phone)"
  medium: "600-839dp (tablet portrait)"
  expanded: ">= 840dp (tablet landscape)"
blur:
  glass-sigma: 16
  max-simultaneous-blur-layers: 3
---

# Vonte Soft Glass

## Overview

Vonte PoS is a cashier tool. People use it standing up, one-handed, in a hurry, often under bright shop lighting. The look is **light, calm, and frosted**: a pale cool background, white translucent glass for the chrome, and one deep teal for everything that matters. It should read as fast and trustworthy, not as a showcase.

Priorities, in order:

1. **Speed and legibility.** Prices, quantities, totals, and stock must be readable at a glance. Large tap targets, tabular numerals, clear states.
2. **One accent.** Teal marks the primary action, the active state, and focus. Nothing else is saturated.
3. **Glass as a tool, not decoration.** Glass is used on chrome that floats above content (navigation, cart panel, sheets, dialogs). Repeated items (product cards, list rows) are near-solid white so the screen stays quick and legible.

This is a **light-mode-only** design. Do not add a dark theme.

## Gradients

Gradients are not used on components. No gradient buttons, no gradient cards, no gradient FAB, no gradient text.

The single exception is the background wash: at most two large, soft blurred circles (`atmos-teal`, `atmos-sky`, at or below 35% opacity) behind the screen so glass has something to refract. They are optional per screen. If a screen reads fine without them, leave them out.

## Colors

- `background` is the page base. It is never pure white and never dark.
- `surface-card` (solid white) is the default for repeated content: product cards, list rows, receipt paper.
- `surface-glass` is for floating chrome. `surface-glass-strong` is for surfaces that carry dense text over varied content (cart panel, bottom sheets, dialogs).
- Every glass edge has a hairline. White-on-white borders disappear on a light background, so pair `border-glass` with `border-hairline`, plus the soft `shadow`.
- `primary` (`#0F766E`) is the only saturated foreground color. White text on it passes contrast for normal text. Use `primary-soft` for active chips and selected rows, never as a large fill.
- Status colors are semantic only: `success` (paid, in stock), `warning` (low stock), `error` (invalid input, out of stock). Each has a `*-soft` background for badges and inline messages. They never appear as button or card fills.
- Text: `on-surface` for content, `on-surface-variant` for secondary text, `on-surface-muted` for metadata. Do not go lighter than `on-surface-muted` for anything the cashier needs to read.

## Typography

Font: **Manrope**, bundled as a local asset (`assets/fonts/`, declared in `pubspec.yaml`). The app is 100% offline, so never load fonts at runtime (no runtime `google_fonts` fetching).

- All numbers (prices, quantities, totals, stock) use **tabular figures** so columns line up and values do not jitter when they change. In Flutter: `fontFeatures: [FontFeature.tabularFigures()]`.
- Money is right-aligned in tables and lines.
- `total-display` is bold (800), not light. The amount to pay is the most important number on the checkout screen.
- Do not use more than three sizes on one card.
- Format: `Rp15.000`. One shared `formatRupiah` helper, covered by a unit test. Never format money inline in widgets.

## Layout and responsiveness

Primary target is phone. Tablet is bonus but must not break.

| Class | Width | Navigation | Cashier screen |
|---|---|---|---|
| compact | under 600dp | floating glass bottom bar (4 items) | product grid, 2 columns. Cart is a bottom sheet opened from a sticky summary bar showing item count and total. |
| medium | 600-839dp | floating glass bottom bar | product grid, 3 columns. Cart is a bottom sheet or slide-over panel. |
| expanded | 840dp and up | navigation rail on the left | product grid, 4 columns, with a fixed cart panel (`cart-panel-width`) on the right. |

Gutters are 16dp compact, 24dp expanded. Use `LayoutBuilder` against the breakpoints above; do not branch on device type.

Navigation items: Kasir, Produk, Laporan, Pengaturan. There is no center FAB. The cashier screen is the home screen and the first tab.

## Elevation and depth

Three tiers only.

1. **Card (solid).** `surface-card`, `border-hairline`, soft shadow. Product cards, list rows, receipt.
2. **Glass.** `surface-glass` or `surface-glass-strong`, `border-glass` plus `border-hairline`, backdrop blur, soft shadow. Bottom nav, rail, cart panel, sheets, dialogs, top bar when content scrolls under it.
3. **Accent glass.** Glass tinted with `primary-soft`. At most one per screen: the total/summary block.

Primary buttons are solid `primary` with no glow and no gradient.

### Glass performance rules (Flutter)

`BackdropFilter` is expensive on mid and low-end Android devices, which is what many cashiers use.

- Build one reusable `AppGlass` widget (`ClipRRect` + `BackdropFilter(ImageFilter.blur(sigmaX: 16, sigmaY: 16))` + `DecoratedBox`). Do not hand-roll glass in screens.
- Never put `BackdropFilter` inside a scrolling list or grid item.
- No more than `max-simultaneous-blur-layers` (3) blurred layers visible at once.
- `AppGlass` has a single switch that falls back to solid `surface-glass-strong` without blur. Keep it working.

## Shapes

- `rounded.lg` (16) for cards and list rows.
- `rounded.xl` (24) for bottom sheets, dialogs, the floating nav bar.
- `rounded.md` (12) for buttons and inputs.
- `rounded.full` for chips, badges, and quantity steppers.

## Components

**Product card** (solid). Photo on top (square crop, local file, with a neutral placeholder when missing), name (max two lines), price in `price` style. States:
- Default: tap adds one unit.
- Has add-ons: tap opens the add-on sheet instead (see below). Show a small topping icon in the corner.
- Low stock (at or below a constant threshold): warning badge "Sisa 3".
- Out of stock: dimmed, "Habis" badge, not tappable.
- Cart already holds all available stock: not tappable, inline hint "Stok sudah di keranjang".

**Category chips.** Horizontal scroll row. Active chip: `primary-soft` fill, `primary` text, `primary` hairline. Inactive: transparent, `on-surface-variant`. First chip is always "Semua". Height 40, tap target at least 48.

**Search field** (glass). Leading search icon, clear button when filled, filters as the user types. No submit button needed.

**Cart panel / cart sheet** (strong glass). Lines: name, add-ons as small caption lines under the name, quantity stepper, line total right-aligned. Swipe or a clear remove control per line. Footer: subtotal, discount, total (`total-display`), primary button "Bayar" (full width, 56 high). Empty state: plain text "Keranjang kosong" with a short hint, no illustration.

**Quantity stepper.** Pill, minus and plus buttons at least 40x40, value between. Plus is disabled when shared stock is exhausted; show the reason inline, not only by disabling.

**Add-on sheet.** Product name, add-on rows with name, extra price, stock hint, and a stepper or toggle. Live subtotal at the bottom and a primary button "Tambah ke keranjang". Add-on rows whose stock is exhausted are disabled with "Habis".

**Checkout.** One screen or sheet:
- Summary block (accent glass): subtotal, discount, total.
- Discount: segmented control "Rp | %" and a numeric field. Invalid values (negative, above subtotal, percent above 100) show an inline `error` message and block payment.
- Cash received: numeric field with Rupiah formatting, plus quick-cash chips ("Uang pas" and the next sensible banknote amounts at or above the total).
- Change ("Kembalian") updates live. If cash is below total, show "Uang kurang" in `error`.
- "Bayar" is disabled until everything is valid.

**Receipt preview.** Looks like paper: solid white `surface-card`, no glass, centered store header, dashed dividers, item rows with add-on lines indented, aligned money column, tabular figures, footer line. Actions: "Selesai" (primary) and "Cetak" (secondary, bonus).

**Report / dashboard.** Stat cards for total revenue and successful transactions, then the transaction history list. Charts (bonus) use `primary` for the main series and slate tones for secondary series. At most one highlight color. No multicolor rainbow charts.

**Buttons.** Primary: solid `primary`, `on-primary` text, 52-56 high, `rounded.md`. Secondary: glass or white with hairline, `on-surface` text. Destructive: `error` text on white with an `error` hairline, or solid `error` for the final confirm in a dialog. Text button: `primary` text, no fill.

**Inputs.** Glass or white fill, hairline border, `primary` 2px focus ring, label above or floating, inline helper/error text below. Validation errors are specific ("Harga harus lebih dari 0"), never generic.

**Feedback.** Light haptic on add-to-cart and on successful payment. Cart summary reacts within 100ms. Snackbars for non-blocking confirmations, inline text for validation, dialogs only for destructive confirms.

## Iconography

One rounded icon family used consistently, bundled locally (Material Symbols Rounded via Flutter's built-in icons is acceptable). Outline for inactive and passive states, filled for the active nav item. 24dp default. Do not mix icon families. No network-loaded icons.

## Imagery

Product photos are the only imagery. Square crop, `rounded.md`, `BoxFit.cover`. Missing photo: neutral tinted placeholder with the product's first letter, not a stock icon or mascot. No illustrations, no mascots, no decorative 3D art.

## Copy

All UI text is in Bahasa Indonesia, short and plain. Keep strings in one place (`core/constants/app_strings.dart`).

- Buttons are verbs: "Tambah", "Bayar", "Simpan", "Hapus", "Selesai".
- Errors say what is wrong and what to do: "Stok tidak cukup. Tersisa 2."
- No fake numbers, no filler stats, no hype words, no emoji in UI text.

## Do

- Use tabular numerals and right-align money.
- Keep touch targets at 48dp or larger.
- Keep the cart summary visible at all times on the cashier screen.
- Reuse `AppGlass`, `AppCard`, and the shared button widgets everywhere.
- Show the reason when something is disabled.

## Don't

- Don't add gradients to components.
- Don't blur items inside scrolling lists.
- Don't use dark backgrounds or a dark theme.
- Don't introduce a second accent color.
- Don't fill cards with solid status colors; use `*-soft` backgrounds.
- Don't load fonts, icons, or images from the network.
- Don't use glass for the receipt.
- Don't use light weights for money.
