# Theme System Migration Guide

**Date**: 2026-01-12
**Purpose**: Document theme system migration and prevent future regressions

---

## The Problem

We have **two theme systems** in Klui:
1. **Old system**: `AppTheme` class with hardcoded colors
2. **New system**: `KluiCustomColors` extension with CRT theme colors

### What Causes Theme Regressions?

When code uses `AppTheme.primaryColor` (green) instead of `colors.success` from `KluiCustomColors`, it breaks the CRT theme and shows the default green color instead of the amber CRT color.

#### Why This Happens Repeatedly

1. **Context window compression** loses context about which theme system to use
2. **Copy-paste coding** from old files that haven't been migrated
3. **Auto-completion** suggests `AppTheme` classes
4. **No lint rule** to prevent using `AppTheme`

---

## Files with Issues

### ✅ Fixed Files

1. **`lib/features/agents/screens/agent_create_screen.dart`**
   - **Issue**: Used `AppTheme.primaryColor` for success message
   - **Fixed**: Changed to `colors.success` from `KluiCustomColors`
   - **Line**: 521

2. **`lib/features/providers/screens/provider_create_screen.dart`**
   - **Issue**: Used `AppTheme.primaryColor` for success message
   - **Fixed**: Changed to `colors.success` from `KluiCustomColors`
   - **Line**: 63

### ⚠️ Files Still Using AppTheme

1. **`lib/features/agents/screens/agent_create_screen.dart`**
   - Still has 100+ `AppTheme` references
   - Used for spacing, border radius, text styles
   - **Status**: Partially migrated (only critical success message fixed)
   - **Note**: Spacing and sizing values from `AppTheme` are OK, only colors matter

2. **`lib/features/providers/screens/provider_list_screen.dart`**
   - Uses `AppTheme` for some styling
   - **Impact**: Unknown, needs audit

---

## Correct Pattern

### ❌ WRONG - Using AppTheme colors

```dart
// DON'T DO THIS
import 'package:klui/core/theme/app_theme.dart';

SnackBar(
  backgroundColor: AppTheme.primaryColor,  // ❌ Green hardcoded color
)

Container(
  color: AppTheme.errorColor,  // ❌ Red hardcoded color
)
```

### ✅ CORRECT - Using KluiCustomColors

```dart
// DO THIS
import 'package:klui/core/theme/klui_theme_extension.dart';

final colors = Theme.of(context).extension<KluiCustomColors>()!;

SnackBar(
  backgroundColor: colors.success,  // ✅ CRT amber color
)

Container(
  color: colors.error,  // ✅ CRT red color
)
```

---

## Available Colors in KluiCustomColors

All colors are defined in `lib/core/theme/klui_theme_extension.dart`:

| Color | Usage | CRT Color |
|-------|-------|-----------|
| `colors.background` | Page background | Dark amber (#0a0a00) |
| `colors.surface` | Cards, panels | Slightly lighter amber |
| `colors.success` | Success states | Amber CRT green (#00ff00) |
| `colors.error` | Error states | CRT red (#ff0044) |
| `colors.warning` | Warnings | CRT amber (#ffcc00) |
| `colors.textPrimary` | Main text | CRT white (#ccff00) |
| `colors.textSecondary` | Secondary text | Dimmed white |
| `colors.border` | Borders, dividers | CRT border green |
| `colors.primary` | Primary actions | CRT white |
| `colors.userBubble` | User messages | Bright amber |
| `colors.assistantBubble` | Assistant messages | Muted amber |

---

## What's Safe to Use from AppTheme

The following `AppTheme` values are **OK to use** because they're not colors:

- ✅ `AppTheme.spacing16` - Spacing constants
- ✅ `AppTheme.radiusSmall` - Border radius
- ✅ `AppTheme.headlineSmall` - Text styles
- ✅ `AppTheme.bodyMedium` - Text styles

**Rule of thumb**: If it ends in `Color`, don't use it. Use `KluiCustomColors` instead.

---

## Migration Checklist

When working on a file, check for these patterns:

### Color-Related Properties
- [ ] `backgroundColor` → Should use `KluiCustomColors`
- [ ] `color:` (Text style) → Should use `KluiCustomColors` or `KluiTextStyles`
- [ ] `Container(color: ...)` → Should use `KluiCustomColors`
- [ ] `BoxShadow(color: ...)` → Should use `KluiCustomColors`

### How to Migrate

1. Add import:
   ```dart
   import 'package:klui/core/theme/klui_theme_extension.dart';
   ```

2. Add colors variable in your build method:
   ```dart
   @override
   Widget build(BuildContext context) {
     final colors = Theme.of(context).extension<KluiCustomColors>()!;
     // Now use: colors.success, colors.error, etc.
   }
   ```

3. Replace color references:
   ```dart
   // Before
   AppTheme.primaryColor
   AppTheme.errorColor
   AppTheme.successColor  // If it exists

   // After
   colors.primary
   colors.error
   colors.success
   ```

---

## Testing Theme

After any UI changes, verify:

1. **Success messages** should be amber/green CRT color, NOT default green
2. **Error messages** should be CRT red
3. **Buttons** should use CRT colors
4. **Backgrounds** should be amber/dark, NOT white or default Material

### Visual Test

Create a new agent/provider and verify the success message:
- ✅ Correct: Amber CRT color background with white text
- ❌ Wrong: Bright green background with white text

---

## Prevention Strategy

### 1. Code Review Checklist

Before submitting code, verify:
- [ ] No `AppTheme.*Color` in new code
- [ ] All colors use `KluiCustomColors`
- [ ] Import `klui_theme_extension.dart` when using colors

### 2. Update CLAUDE.md

Add to section 11.5 (Theme System):

```markdown
### Theme and Color Usage

**MANDATORY**: Always use `KluiCustomColors` for colors, never `AppTheme`.

❌ WRONG:
```dart
backgroundColor: AppTheme.primaryColor
```

✅ CORRECT:
```dart
final colors = Theme.of(context).extension<KluiCustomColors>()!;
backgroundColor: colors.success
```

**Safe to use from AppTheme**:
- Spacing: `AppTheme.spacing16`
- Border radius: `AppTheme.radiusSmall`
- Text styles: `AppTheme.bodyMedium`

**NOT safe**:
- Any property ending in `Color`
```

### 3. Consider Adding a Linter Rule

Create a custom lint rule in `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - prefer_klui_custom_colors:
      banned_names:
        - AppTheme.primaryColor
        - AppTheme.errorColor
        - AppTheme.successColor
```

---

## Summary

**Root Cause**: Mixed use of old `AppTheme` and new `KluiCustomColors`
**Solution**: Always use `KluiCustomColors` for colors
**Prevention**: Code review checklist + potential linter rule

**Key Takeaway**: When in doubt, check existing CRT-themed files like `chat_screen.dart` for the correct pattern.

---

**Last Updated**: 2026-01-12
**Status**: Active - All new code must follow these guidelines
