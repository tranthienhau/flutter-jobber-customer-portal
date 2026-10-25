# Midas Client Portal - Design System

Bright, modern mobile customer portal for a commercial facility services company. Clean, calm,
trustworthy, lots of whitespace, one bold lemon accent used sparingly against warm ink.

## Color (use ONLY these colors)
- Background: #FCFAF4 (warm tinted near-white page)
- Surface / cards / sheets: #FFFFFF
- Surface alt (grouped rows): #F6F2E4
- Accent (lemon): #FFD60A - primary button fills, active tab indicator, focus rings, key highlights. Text on lemon is ALWAYS ink #1F1C0C, never white.
- Accent tint: #FFF6C7 - chips, selected states
- Accent pressed: #E6C000
- Accent fill (dark olive gold, white-text safe): #826D05 - links and small accent text
- Support (sky): #7DB8FF for decoration; data series / icons use #4194FF
- Ink (text primary, hero cards): #1F1C0C
- Text secondary: #575238
- Text tertiary / placeholders: #6B6650
- Hairline divider: #ECE6D2
- Input / control border: #9B9556
- Success #0E7C3A on #E3F4E9, Warning #A75906 on #FAEFE1, Danger #CE2020 on #FBE5E5, Info #1F4F8A on #E3F0FF
No default violet or indigo, no flat neutral grey. Neutrals stay warm-tinted.

## Typography
- UI + body: Plus Jakarta Sans. Display (screen titles, hero numbers): Unbounded.
- Display 32/700 -0.02em (Unbounded), Title 20/600, Body 16/400, Label 14/500, Caption 13/500.
- Use only these 5 sizes. Minimum text 12px (13px chips and tags, 14px legal text).
- Amounts and counts use tabular numerals.

## Frame and layout
- 393x852 mobile frame. Top ~59px and bottom ~34px safe areas kept clear.
- 8pt spacing scale (4, 8, 12, 16, 24, 32). Screen edge padding 20px.
- Radius: card 20, control 14, input 12, pill 999.
- Elevation soft only: 0 1px 2px rgba(0,0,0,.04) + 0 8px 24px rgba(0,0,0,.06).
- Icons: one set, rounded outline (Lucide style), 24px, 1.75 stroke.

## Shared components
- Bottom tab bar (exactly 4 tabs, this order): Home (house), Requests (clipboard-list), Invoices (receipt), Support (message-circle). Active tab: ink icon + ink label with a small lemon #FFD60A pill behind the icon. Inactive: #6B6650. Flat white bar, hairline top border #ECE6D2, bottom safe-area inset. Never rename, reorder, add or remove tabs.
- Top header: screen title in Unbounded 20/600 left; Home shows customer avatar + bell with lemon dot on the right; pushed screens show a back chevron.
- Primary button: pill, lemon #FFD60A, ink #1F1C0C label, pressed #E6C000, disabled 40%.
- Secondary button: white pill, 1px #9B9556 border, ink label.
- Text input: white, 12px radius, 1px #9B9556 border, focus 2px lemon ring, error #CE2020.
- Card: white, 20px radius, soft shadow.
- Chip: pill, #FFF6C7 fill, ink text, 13px.
- Status chips (icon + text): Requested = #E3F0FF with #1F4F8A; Scheduled = #FFF6C7 with #5E4F00; In progress = #FAEFE1 with #A75906; Completed = #E3F4E9 with #0E7C3A.

## Gradient and focal rules
- One bold focal element per screen (hero card, big number, photo, timeline).
- Hero cards that carry white text use solid ink #1F1C0C (optionally a subtle ink to #2E2A14 blend). The soft lemon -> sky blend is decoration only, never behind text.
- Flat tab bar. Pills on dark surfaces use lemon fill with ink text.

## Imagery
Real photography only: clean commercial buildings, office lobbies, carpets, restrooms, crew portraits. Empty states and onboarding also use real photos or flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects.

## Meaning of color
Red only for errors, destructive actions and truly urgent states. Non-urgent warnings use the warning color with an icon.

## Copy scope
Do not mention: Telehealth, Crypto, Wallet. No online payment button (invoices are view-only). No invented integrations beyond Jobber, QuickBooks Online and GoHighLevel. No person names beyond: Dana Whitfield, Kevin Ortiz, Maria Gonzalez, Luis M., Jordan Ellis.
