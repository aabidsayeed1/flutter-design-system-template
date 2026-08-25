# Flutter Design System Template

Single-command token pipeline for Flutter.

## Phase 1 Goal

Change values in [tokens.json](lib/core/design_system/generator/tokens.json), run one command, and the app theme + token files update.

## Generate Command

```bash
dart run lib/core/design_system/generator/generate_tokens.dart
```

The generator now validates token schema before writing files. Invalid tokens fail fast with a clear `StateError`.

## What The Generator Owns

- Generated token files under [lib/core/design_system/generated](lib/core/design_system/generated)
- Wrapper scaffolding in [lib/core/design_system/tokens](lib/core/design_system/tokens)
- Theme files:
	- [lib/core/design_system/theme/app_theme.dart](lib/core/design_system/theme/app_theme.dart)
	- [lib/core/design_system/theme/app_theme_extension.dart](lib/core/design_system/theme/app_theme_extension.dart)
- Context extension:
	- [lib/core/design_system/extensions/context_extension.dart](lib/core/design_system/extensions/context_extension.dart)
- Responsive helpers:
	- [lib/core/design_system/responsive/responsive.dart](lib/core/design_system/responsive/responsive.dart)
	- [lib/core/design_system/responsive/responsive_value.dart](lib/core/design_system/responsive/responsive_value.dart)
- Token export barrel:
	- [lib/core/design_system/tokens/tokens.dart](lib/core/design_system/tokens/tokens.dart)

## Manual Code Safety

- Existing manual methods in token wrapper classes are preserved.
- Missing wrapper files are auto-created.
- Theme-specific color override getters are now updated when values change in [tokens.json](lib/core/design_system/generator/tokens.json), not just appended once.

## Themes

- Theme keys are read from `themes` in [tokens.json](lib/core/design_system/generator/tokens.json).
- For each key, generator creates:
	- Generated color class (for source of truth)
	- Token wrapper class named from key (`light -> LightColorTokens`, `dark -> DarkColorTokens`, `aurora -> AuroraColorTokens`)
	- AppTheme entry in `AppTheme.themes`

## App Wiring

The app currently uses a selectable brand theme with system dark-mode support in [lib/main.dart](lib/main.dart).

## Current Status

- Phase 1 workflow is complete for local development: edit [tokens.json](lib/core/design_system/generator/tokens.json), run the generate command, and consume tokens in app UI.
- Project is intentionally app-first right now (not packaged yet).
- Next phase focuses on reliability and automation (schema validation, tests, and Figma export integration).

## Schema Validation Rules

- Required sections: `themes`, `spacing`, `radius`, `typography`, `dimensions`, `elevations`
- `themes` must include `light`
- Theme color values must be in `#RRGGBB` format
- Every theme must use the same color keys as `light`
- Responsive values (`mobile`, `tablet`, `desktop`) must be numeric
- `dimensions.*.type` must be one of: `width`, `height`, `radius`
- `elevations` values must define numeric `mobile`, `tablet`, `desktop`
- Typography color references must exist in `themes.light.colors`
- Typography `lineHeight` is optional, but when provided it must include numeric `mobile`, `tablet`, `desktop`
- Typography `letterSpacing` is optional, but when provided it must be numeric
- Optional per-theme `gradients` are supported
- If gradients are present in `light`, all themes must define gradients with identical keys
- Gradient types supported: `linear`, `radial`, `sweep`
- Optional per-theme `shadows` are supported
- If shadows are present in `light`, all themes must define shadows with identical keys
- Each shadow token must define a non-empty `layers` array
- Shadow layer `opacity` must be between `0` and `1` when provided

## Gradient Token Schema

Put gradients inside each theme, next to `colors`:

```json
{
	"themes": {
		"light": {
			"colors": { "primary": "#2563EB" },
			"gradients": {
				"brandLinear": {
					"type": "linear",
					"begin": "topLeft",
					"end": "bottomRight",
					"colors": ["primary", "secondary"]
				},
				"surfaceRadial": {
					"type": "radial",
					"center": "center",
					"radius": 1.15,
					"colors": ["#FFFFFF", "#DBEAFE"]
				},
				"statusSweep": {
					"type": "sweep",
					"center": "center",
					"startAngle": 0.0,
					"endAngle": 6.28318,
					"colors": ["#16A34A", "#F59E0B", "#DC2626", "#16A34A"]
				}
			}
		}
	}
}
```

Preferred approach: use color-key references in gradient `colors` (for example `primary`, `secondary`, `error`) so gradients stay synchronized with theme colors.

Fallback approach: direct hex colors are still supported (`#RRGGBB`) when needed.

Generated outputs include:

- [lib/core/design_system/generated/generated_gradient_tokens.dart](lib/core/design_system/generated/generated_gradient_tokens.dart)
- [lib/core/design_system/tokens/gradient_tokens.dart](lib/core/design_system/tokens/gradient_tokens.dart)
- `context.gradients` access via [lib/core/design_system/extensions/context_extension.dart](lib/core/design_system/extensions/context_extension.dart)

## Shadow And Elevation Token Schema

Put shadows inside each theme, next to `colors` and `gradients`:

```json
{
	"themes": {
		"light": {
			"colors": { "shadow": "#0F172A" },
			"shadows": {
				"card": {
					"layers": [
						{ "x": 0, "y": 4, "blur": 12, "spread": 0, "color": "shadow", "opacity": 0.12 }
					]
				}
			}
		}
	}
}
```

Define elevations at top-level (responsive numeric values):

```json
{
	"elevations": {
		"level1": { "mobile": 1, "tablet": 1, "desktop": 1 },
		"level2": { "mobile": 2, "tablet": 2, "desktop": 2 },
		"level3": { "mobile": 4, "tablet": 4, "desktop": 4 }
	}
}
```

Optional semantic aliases can map UI terms to base levels:

```json
{
	"elevationAliases": {
		"surface": "level1",
		"card": "level1",
		"popover": "level2",
		"dialog": "level3"
	}
}
```

Preferred approach: use color-key references in shadow layer `color` values (for example `shadow`, `overlay`) so shadow tones stay theme-aware.

Generated outputs include:

- [lib/core/design_system/generated/generated_shadow_tokens.dart](lib/core/design_system/generated/generated_shadow_tokens.dart)
- [lib/core/design_system/generated/generated_elevation_tokens.dart](lib/core/design_system/generated/generated_elevation_tokens.dart)
- [lib/core/design_system/tokens/shadow_tokens.dart](lib/core/design_system/tokens/shadow_tokens.dart)
- [lib/core/design_system/tokens/elevation_tokens.dart](lib/core/design_system/tokens/elevation_tokens.dart)
- `context.shadows` and `context.elevation` accessors via [lib/core/design_system/extensions/context_extension.dart](lib/core/design_system/extensions/context_extension.dart)

When aliases are configured, use semantic access in UI code, for example `context.elevation.card` and `context.elevation.dialog`.

## Test Commands

Run schema regression tests:

```bash
flutter test test/generator/schema_validation_test.dart
```

This includes invalid gradient-schema fixtures as well.

Run idempotency regression test:

```bash
flutter test test/generator/idempotency_test.dart
```

Run missing-file recovery regression test:

```bash
flutter test test/generator/missing_file_recovery_test.dart
```

Run theme-map sync and wrapper contract tests:

```bash
flutter test test/generator/theme_map_sync_test.dart
flutter test test/generator/token_wrapper_contract_test.dart
```

Run runtime design-system smoke tests:

```bash
flutter test test/design_system/runtime_smoke_test.dart
```

Run full generator reliability suite:

```bash
flutter test test/generator
```

Run all tests:

```bash
flutter test
```

Fixture files for invalid token inputs live under [test/fixtures](test/fixtures).

## Figma To Flutter Guide (Beginner)

If you are starting from zero, follow this order.

### Step 1: Create a test Figma file

Create a new Figma file and add Variables for:

- Colors: primary, surface, background, textPrimary, textSecondary, error
- Spacing: sm, md, lg
- Radius: md
- Typography: title, body
- Dimensions: buttonHeight, icon, avatar, imageWidth, imageHeight
- Gradients: brandLinear (linear), surfaceRadial (radial), statusSweep (sweep)

Keep the naming exactly aligned with [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).

### Step 2: Export JSON first (manual MVP)

Use a Figma tokens plugin to export variable values to JSON, then map that export into the schema used by [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).

For the first version, manual copy/paste is fine:

1. Export from Figma plugin.
2. Paste/update [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).
3. Run generator command.
4. Run tests.

For gradients in Figma Variables/plugin output, map to supported gradient types:

- `linear` with `begin`, `end`, `colors`, optional `stops`
- `radial` with `center`, `radius`, `colors`, optional `stops`
- `sweep` with `center`, `startAngle`, `endAngle`, `colors`, optional `stops`

### Step 3: Local automation after export

Once manual export works, automate the local part:

1. Save plugin export to a known file (for example `figma-export.json`).
2. Add a small transform script that converts plugin JSON to this project schema.
3. Script writes final JSON to [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).
4. Script runs [lib/core/design_system/generator/generate_tokens.dart](lib/core/design_system/generator/generate_tokens.dart).
5. Script runs generator tests.

This gives: Figma export -> transform -> generate -> validate.

### Step 4: Full automatic sync (true end goal)

To make it automatic from Figma to Flutter without manual copy/paste, yes, you need one of these:

- A custom Figma plugin you build, or
- A plugin that can sync to an external source (GitHub/HTTP endpoint) plus a local pull script.

Important limitation:

- Figma plugins cannot directly write into your local Flutter project folder for security reasons.

So full automation usually looks like:

1. Designer clicks sync/export in Figma plugin.
2. Plugin pushes JSON to remote storage (repo, API, or hosted JSON file).
3. Local script/CI pulls latest JSON.
4. Transform + generator run automatically.
5. Flutter app updates.

### Recommended path for this repo

1. Start with manual export into [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).
2. Confirm generator + tests pass.
3. Add transform script.
4. Add remote sync.
5. Later build custom plugin only if needed.

## Other Figma Tokens You May Add Next

Besides colors and gradients, common exports from Figma that are useful for Flutter:

- Opacity tokens
- Blur tokens
- Border width/style tokens
- Motion tokens (duration, curve names)
- Elevation aliases (semantic aliases mapped to base levels)
- Breakpoints and layout grid tokens
- Z-index/layer order tokens

Current generator fully supports colors, gradients, shadows, spacing, radius, typography, dimensions, and elevations.
