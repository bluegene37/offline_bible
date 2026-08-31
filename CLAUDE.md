# offline_bible

A fast, fully offline Bible app built with Flutter. Targets Android, iOS, macOS,
and web. State management is GetX; local persistence is Hive CE.

## Layout

- `lib/core/` — shared services, models, theming, storage
- `lib/features/` — feature modules (reader, search, notes, plans, audio, settings)
- `test/core/`, `test/features/` — mirrors the `lib/` structure

## Commands

```
flutter analyze
flutter test
flutter run -d <device>
```

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. When in doubt, invoke the skill.

Key routing rules:
- Product ideas/brainstorming → invoke /office-hours
- Strategy/scope → invoke /plan-ceo-review
- Architecture → invoke /plan-eng-review
- Design system/plan review → invoke /design-consultation or /plan-design-review
- Full review pipeline → invoke /autoplan
- Bugs/errors → invoke /investigate
- QA/testing site behavior → invoke /qa or /qa-only
- Code review/diff check → invoke /review
- Visual polish → invoke /design-review
- Ship/deploy/PR → invoke /ship or /land-and-deploy
- Save progress → invoke /context-save
- Resume context → invoke /context-restore
- Author a backlog-ready spec/issue → invoke /spec

Note: `/qa` and `/design-review` are browser-driven and are blind to Flutter's
canvas rendering. For this repo, QA runs on the iOS Simulator plus
`flutter analyze` / `flutter test`, not through the headless browser.
