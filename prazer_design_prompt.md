# PRAZER — Design Prompt (UI/UX & Visual System)
### Paste this as a SEPARATE prompt into Claude Code / Antigravity / Codex — alongside the build prompt, not instead of it. This covers screens and visuals; the build prompt covers backend/pipeline logic.

---

## 0. How to use this document

This is a design-only spec. Build screens in the order listed in §4. Wire each screen to the real API endpoints defined in the build prompt (`/api/v1/analyze`, `/api/v1/status/{id}`, `/api/v1/report/{id}`) — don't hardcode mock data once the backend exists.

---

## 1. Design direction

Prazer should feel like a **calm, precise research tool** — closer to a fintech dashboard or a lab instrument than a consumer app. The audience (inventors, students, early founders) needs to trust a *score*, so the UI should read as analytical and credible, not playful. Avoid generic AI-app defaults: no cream-background-plus-terracotta-accent look, no all-black-with-one-neon-accent look. This app's identity comes from its own two palettes below — lean into those instead.

**Signature element:** the soft radial-gradient blend used in both reference palette exports (dark-to-light, or warm-to-cool) becomes the hero background — but ONLY on the Splash and Login screens. Everywhere else stays flat and disciplined (solid Alabaster Grey background, white cards). Using the gradient everywhere would dilute it; using it once, at the moment someone first opens the app, makes it memorable.

---

## 2. Design tokens

### A. Typography — Montserrat throughout
- **Install (Flutter):**
  ```bash
  flutter pub add google_fonts
  ```
- **Weight scale:**
  | Role | Weight | Use |
  |---|---|---|
  | Display / score numbers | 800 (ExtraBold) | Similarity score gauges, big dashboard stats |
  | Headings | 700 (Bold) | Screen titles, card titles |
  | Subheadings / buttons | 600 (SemiBold) | Section labels, button text |
  | Body emphasis | 500 (Medium) | Card body, list item titles |
  | Body / labels | 400 (Regular) | Paragraph text, hints, timestamps |

### B. Color system — two palettes, two distinct jobs

**Palette A — structural (background, surfaces, text). Use this everywhere by default.**
| Name | Hex | Role |
|---|---|---|
| Alabaster Grey | `#E5E4E2` | Primary app background |
| Onyx | `#0A0A0A` | Primary text; dark-mode background |
| Blue Slate | `#536878` | Secondary text, icons, borders, dividers, muted/disabled states |

**Palette B — accent (interaction only). Never use for large background areas — these are for things the user acts on.**
| Name | Hex | Role |
|---|---|---|
| Cool Horizon | `#58A6FF` | Primary buttons, links, active nav state, primary chart line |
| Grapefruit Pink | `#FF6B6B` | Secondary accent — warnings, secondary buttons, alert badges, second chart series |
| Papaya Whip | `#FFEDD5` | Tertiary — soft highlight backgrounds, badge fills, tinted card backgrounds (never text) |

*(Assumption: "blue, orange" in the brief maps to Cool Horizon as the blue and Grapefruit Pink as the closest warm/orange-leaning accent, with Papaya Whip as a soft tertiary tint. Swap easily if you meant something else — they're just named constants, see §6.)*

Card surfaces: pure white (`#FFFFFF`) on top of the Alabaster Grey background, so cards lift slightly without introducing a new color.

### C. Layout — bento grid
- 12px grid gap, 16px card corner radius, subtle shadow (`0 2px 8px rgba(10,10,10,0.06)`) — no heavy elevation, this isn't material-design-default.
- Card sizes: 1x1 (stat), 2x1 (chart/list), 2x2 (primary CTA or featured chart). Mix sizes — don't make every card identical, that's the generic-dashboard tell.
- 24px screen padding on mobile, 32px on tablet/web.

---

## 3. App flow map

```
Splash (gradient hero, logo)
  │
  ▼
Login  ── Google OAuth via Supabase Auth ──►
  │
  ├── first-time user ──► Profile Setup ──► Main Dashboard
  └── returning user ───────────────────► Main Dashboard
                                                │
              ┌───────────────┬────────────────┼───────────────┬─────────────┐
              ▼               ▼                ▼               ▼             ▼
        New Analysis    Report History     (bento cards:    Settings     Sign Out
        (Upload)          (all reports)     tap stat/chart
              │                              → drill in)
              ▼
        Processing (live stepper: Parsing → Retrieval → Vector Math → LLM Synthesis)
              │
              ▼
        Report / Results screen  ──(saved to)──►  Report History
```

---

## 4. Screens — build in this order

### 1. Splash
- Full-screen radial gradient background blending Onyx → Blue Slate → Alabaster Grey (mirrors the reference palette export). Logo/wordmark centered in Alabaster Grey, Montserrat 800.
- Auto-advances to Login (or Dashboard if session already exists) after ~1s.

### 2. Login
- Same gradient hero treatment as Splash, slightly toned down (or a static version of it).
- Single primary action: **"Continue with Google"** button — white pill button, Google logo + Montserrat 600 label, sits in the lower third.
- Below it, small Montserrat 400 text: *"By continuing you agree this tool provides estimates, not legal advice."* (sets expectations before they even land inside).
- Auth implementation: Supabase Auth's Google OAuth provider.
  ```dart
  await supabase.auth.signInWithOAuth(OAuthProvider.google);
  ```
  Configure the Google provider (client ID/secret) in the Supabase dashboard under Authentication → Providers — not something you hardcode in the app.

### 3. Profile Setup (first login only)
- Flat Alabaster Grey background, no gradient — this is a task screen, not a hero moment.
- Fields: name (pre-filled from Google, editable), role (dropdown: Student / Independent Inventor / Founder / Attorney / Other), institution/organization (text), primary domain of work (text, e.g. "Electronics", "Biotech").
- Single "Continue" button, Cool Horizon, disabled until required fields filled.
- Skippable via a small "Skip for now" text link (top right) — don't force it; let them get to the dashboard.

### 4. Main Dashboard
- Top: greeting header, NOT a card — "Good morning, {firstName}" (time-of-day aware), Montserrat 700, sits directly on the Alabaster Grey background with generous top padding.
- Below it: bento grid —
  | Card | Size | Content |
  |---|---|---|
  | New Analysis | 2×2, Cool Horizon fill | Icon + "Start New Analysis" — the one high-emphasis card on the screen |
  | Recent Reports | 2×1 | Last 3 reports as a compact list: title, similarity score badge, date |
  | Total Analyses | 1×1, Papaya Whip tint | Big number (Montserrat 800), label "Analyses run" underneath |
  | Similarity Trend | 2×1 | Small line chart (`fl_chart`), Cool Horizon line, average similarity score over recent reports |
  | Top Prior-Art Sources | 1×1, small bar chart | Which patent offices matched most often — Grapefruit Pink bars |
- Bottom nav (or side rail on wider screens): Dashboard, New Analysis, History, Settings — 4 items max, Cool Horizon for the active icon/label, Blue Slate for inactive.

### 5. New Analysis (Upload)
- Flat background. Centered drag-and-drop zone (dashed Blue Slate border, rounded corners) with a file-picker fallback button. Accepts PDF/DOCX.
- Once a file is selected: filename chip + "Analyze" button (Cool Horizon, full width).

### 6. Processing
- Vertical stepper matching the real pipeline stages: **Parsing → Retrieval → Vector Math → LLM Synthesis**. Each step: icon, label, and a subtle pulse/spinner only on the active step; completed steps get a checkmark in Cool Horizon.
- Poll `/api/v1/status/{document_id}` to advance the stepper — don't fake the timing, drive it from real backend status.

### 7. Report / Results
- Top: circular score gauge (`fl_chart`), Cool Horizon arc on a Blue Slate track, big Montserrat 800 percentage in the center.
- Below: 2–3 sentence plain-English summary (from the Groq/Ollama explainer), in a white card.
- Below that: "Top Matching Patents" list — each row: patent title, similarity %, publication date, tap to expand excerpt.
- Fixed footer or bottom banner, small text, always visible: *"This is an automated estimate, not legal advice. Consult a registered patent attorney before filing."* — this disclaimer is non-negotiable per the build prompt's design rules.

### 8. Report History
- Simple list/grid of past reports, each card: title, score badge (color-coded: Cool Horizon for low overlap/high novelty framing, Grapefruit Pink for high overlap — pick one consistent direction and state it in a legend), date. Tap → Report screen for that document.
- Empty state (no reports yet): centered illustration-style icon, "No analyses yet" (Montserrat 700), "Run your first prior-art check to see it here." (Montserrat 400), CTA button to New Analysis. Explain what to do next, don't just show a blank screen.

### 9. Settings
- Profile fields (editable, same fields as Profile Setup), sign-out button (Grapefruit Pink text, no fill — it's a lower-emphasis destructive-ish action), app version footer.

### Error states (apply everywhere, not just one screen)
- State what happened and what to do next, in plain language, no apologies: *"Upload failed — check your connection and try again"* rather than *"Oops! Something went wrong :("*. Keep this tone consistent across every error toast/banner in the app.

---

## 5. Copy/voice guidance

- Active voice, plain verbs: "Start New Analysis," not "Submit for Processing."
- A button's label and its resulting state use the same word: "Analyze" → "Analyzing…" → "Analysis complete," not "Analyze" → "Processing" → "Done."
- Never oversell the score. Say "Similarity Score," not "Patentability Verdict" — the disclaimer only works if the rest of the copy doesn't contradict it.

---

## 6. Flutter theme setup (drop this in as your app's base theme)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrazerColors {
  static const alabasterGrey = Color(0xFFE5E4E2);
  static const onyx          = Color(0xFF0A0A0A);
  static const blueSlate     = Color(0xFF536878);
  static const coolHorizon   = Color(0xFF58A6FF);
  static const grapefruitPink = Color(0xFFFF6B6B);
  static const papayaWhip    = Color(0xFFFFEDD5);
}

final prazerTheme = ThemeData(
  scaffoldBackgroundColor: PrazerColors.alabasterGrey,
  colorScheme: ColorScheme.light(
    primary: PrazerColors.coolHorizon,
    secondary: PrazerColors.grapefruitPink,
    surface: Colors.white,
    onSurface: PrazerColors.onyx,
    onPrimary: Colors.white,
  ),
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    displayLarge:  GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: PrazerColors.onyx),
    headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: PrazerColors.onyx),
    titleMedium:   GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: PrazerColors.onyx),
    bodyMedium:    GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: PrazerColors.blueSlate),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: PrazerColors.coolHorizon,
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
```

Radial gradient helper for the Splash/Login hero (used ONLY there — see §1):
```dart
const heroGradient = RadialGradient(
  center: Alignment.topCenter,
  radius: 1.4,
  colors: [PrazerColors.onyx, PrazerColors.blueSlate, PrazerColors.alabasterGrey],
  stops: [0.0, 0.5, 1.0],
);
```

---

## 7. Instruction to the coding agent

Build screens in the order listed in §4, styling each with the tokens in §2 and §6 — don't invent new colors or reach for Material defaults. Wire Login to real Supabase Google OAuth from the start (§4.2) rather than mocking it, since the build prompt already has Supabase configured. Leave chart/list data as empty-state placeholders (§4.8) until the backend pipeline from the build prompt is returning real report data — don't fabricate sample analytics to make the dashboard look populated.
