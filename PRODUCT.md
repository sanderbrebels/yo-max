# Product

<!-- impeccable:product-schema 1 -->

## Platform

web (the portfolio page). The product itself is a native macOS app (SwiftUI/AppKit); its in-app design lives in Swift and `CLAUDE.md`.

## Stack

Portfolio page: static HTML/CSS, one self-contained page that can be hosted anywhere or embedded in Sander's portfolio. Sketches live in `design/schetsen/`.

## Users

- **Yo Max (the app):** Sander Brebels himself, possibly one friend. Dictates in Dutch with a Flemish accent and English technical terms, in any macOS app, all day.
- **Portfolio page:** recruiters and design leads evaluating Sander as a product designer who also builds. They skim, then decide whether the process and the craft are convincing.

## Product Purpose

Yo Max is a personal dictation app for macOS, like Wispr Flow: hold fn, speak, release, and clean text appears in whatever app has focus. Goal: the best Dutch (Flemish) quality, fast, completely free (local Whisper Large v3 Turbo, optional free Groq cleanup).

The portfolio page exists to show how Sander takes a product from idea to a working, styled native app: decisions, iterations, tests, and the result.

## Positioning

A Dutch-first dictation tool tuned for one real speaker: Flemish accent, English jargon, Dutch number/time conventions, self-corrections, formatting commands, a dictionary that learns. Local transcription, no subscription.

## Operating Context

- fn hold = record, release = paste; double-tap = hands-free; selection + short instruction = command mode with a preview card.
- Mini recorder at the bottom of the screen: brand-dark pill with a lime waveform.
- Copy card when no text field has focus; dictionary learning from History and Auto-Learn.

## Capabilities and Constraints

- Real, built features: see `CLAUDE.md` › "Gemaakte keuzes".
- Requirements: Apple Silicon, macOS 15+.
- **Open decision:** Yo Max is a fork of the open-source VoiceInk (GPL-3.0). Sander chose not to list this as a portfolio fact for now; a credit line is recommended so the page does not imply everything was built from scratch. Ask before publishing.

## Brand Commitments

- Name "Yo Max" (user-facing); the code/module keeps "VoiceInk".
- Tarmax visual identity (Sander's own design system): ink `#0B1F0D`, lime `#86F46D`, brand-dark `#212520`, Aeonik (paid, never bundled or committed; falls back to the system font).
- App icon and menu-bar icon: Tarmax diamond with lime waveform (`design/icoon/`). Proposals for new icons are pending Sander's input.
- Never use the VoiceInk name or Pro license as Yo Max's own product.

## Evidence on Hand

- Allowed on the page: link to https://github.com/sanderbrebels/yo-max (must be pushed first).
- Available but **not** approved for the page: test results (`testzinnen.md`, 10/15), "built with Claude", the VoiceInk origin.
- No screenshots, testimonials, users or metrics exist yet. Do not invent any.

## Product Principles

1. Dutch quality first: correct Dutch beats clever features.
2. Fast and free: local by default, cloud only where it is free and optional.
3. Never surprise the user: previews before replacing text, nothing executes from dictated content.
4. Fits macOS: works in every app, respects native expectations.
