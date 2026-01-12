# Diff Viewer Test Plan

**Date**: 2026-01-12
**Feature**: Diff Visualization for File Edit Tools
**Status**: Implemented but Not Testable

---

## Implementation Summary

Diff viewer has been successfully implemented in the Klui chat interface. The feature automatically detects file editing tools and displays a line-by-line diff visualization when agents modify files.

### What Was Implemented

1. **`DiffViewer` Widget** (`lib/features/chat/widgets/diff_viewer.dart`)
   - Line-by-line diff display using `diff_match_patch` algorithm
   - Color-coded changes:
     - Green background for additions (`+`)
     - Red background for deletions (`-`)
     - Gray background for unchanged lines
   - Line numbers showing old → new mapping
   - File path display in header
   - Support for 20+ programming languages

2. **Tool Detection** (`lib/features/chat/widgets/tool_call_card.dart`)
   - Automatically detects file editing tools:
     - `file_edit`
     - `file_write`
     - `str_replace`
     - `archive_insert`
     - `archive_replace`
   - Language detection from file extensions
   - Conditional rendering: shows diff instead of plain text result

3. **Dependencies**
   - `diff_match_patch: ^0.4.0` added to `pubspec.yaml`
   - Uses semantic diff cleanup for better readability

---

## Test Requirements (Blocked)

### Why Testing is Blocked

The diff viewer feature requires **file system control** to test, which is not yet implemented in Klui. File system control is a prerequisite for agents to actually edit files, which would trigger the diff viewer display.

### Required Prerequisites

1. **File System Management UI**
   - File browser/tree view
   - File upload/download
   - File creation/deletion
   - Directory navigation

2. **Backend File Operations**
   - Letta backend file tool integration
   - Agent workspace management
   - File permissions and access control

3. **Tool Input Validation**
   - Ensure `old_content` and `new_content` are properly passed
   - Verify `file_path` parameter is included
   - Handle large file diffs (performance testing)

---

## Future Test Plan

Once file system control is implemented, execute the following tests:

### Test Case 1: Basic File Edit
**Scenario**: Agent edits a single line in a Python file

**Steps**:
1. Create a file `test.py` with content:
   ```python
   def hello():
       print("Hello, World!")
   ```

2. Instruct agent to change "Hello, World!" to "Hello, Klui!"

3. Verify diff viewer displays:
   - Red line: `-     print("Hello, World!")`
   - Green line: `+     print("Hello, Klui!")`
   - Line numbers: `4 → 4`
   - File path: `test.py`
   - Syntax highlighting for Python

**Expected Result**:
- ✅ Diff viewer appears in tool call card
- ✅ Changes are clearly visible
- ✅ Colors match the design system

### Test Case 2: Multi-Line Edit
**Scenario**: Agent adds a function with multiple lines

**Steps**:
1. Create a file `utils.dart` with basic imports
2. Agent adds a new helper function (5+ lines)
3. Verify all added lines are green

**Expected Result**:
- ✅ Multiple consecutive green lines
- ✅ Proper line number continuity
- ✅ No duplicate lines shown

### Test Case 3: File Creation
**Scenario**: Agent creates a new file

**Steps**:
1. Instruct agent to create `new_file.py`
2. Agent writes initial content

**Expected Result**:
- ✅ Diff shows entire content as green (additions)
- ✅ Old line numbers are empty
- ✅ New line numbers start from 1

### Test Case 4: Large File Diff
**Scenario**: Agent edits a file with 100+ lines

**Steps**:
1. Create a large file (100+ lines)
2. Make changes in middle of file
3. Scroll through diff viewer

**Expected Result**:
- ✅ Performance remains smooth
- ✅ Line numbers are accurate
- ✅ Changes are easily locatable

### Test Case 5: Multiple File Types
**Scenario**: Test different programming languages

**File Types to Test**:
| Extension | Language | Expected Highlighting |
|-----------|----------|----------------------|
| `.py` | Python | ✅ |
| `.js` | JavaScript | ✅ |
| `.dart` | Dart | ✅ |
| `.json` | JSON | ✅ |
| `.md` | Markdown | ✅ |
| `.yaml` | YAML | ✅ |
| `.sh` | Bash | ✅ |

**Steps**:
1. Create files with different extensions
2. Make agent edit each file
3. Verify language detection works

**Expected Result**:
- ✅ Correct language for each extension
- ✅ Fallback to 'text' for unknown extensions

### Test Case 6: Edge Cases

**6.1 Empty File Edit**
- Create empty file
- Agent adds content
- **Expected**: All lines shown as additions

**6.2 Delete All Content**
- Agent clears file completely
- **Expected**: All lines shown as deletions

**6.3 Special Characters**
- File with Unicode, emojis, special chars
- Agent edits content
- **Expected**: Characters display correctly

**6.4 Very Long Lines**
- Single line exceeding 1000 characters
- Agent edits part of it
- **Expected**: Line wraps or scrolls, content visible

### Test Case 7: Error Handling

**7.1 Missing Parameters**
- Tool returns without `old_content`
- **Expected**: Falls back to plain text display

**7.2 Invalid JSON**
- Tool returns malformed JSON in content
- **Expected**: No crash, shows raw content

**7.3 File Path Missing**
- Tool edit without `file_path`
- **Expected**: Header shows "File:" without path, diff still works

---

## Performance Benchmarks

### Target Performance
| Metric | Target | Notes |
|--------|--------|-------|
| Small files (< 100 lines) | < 100ms | Instant display |
| Medium files (100-1000 lines) | < 500ms | Noticeable but acceptable |
| Large files (1000+ lines) | < 2s | May need virtualization |

### Optimization Strategies (If Needed)
1. **Virtual scrolling** for very large diffs
2. **Lazy rendering** of diff chunks
3. **Debouncing** rapid updates
4. **Web Worker** for diff computation (if needed)

---

## Accessibility Tests

### Keyboard Navigation
- [ ] Tab through diff sections
- [ ] Screen reader announces line changes
- [ ] Arrow keys navigate between lines

### Color Contrast
- [ ] Green additions meet WCAG AA
- [ ] Red deletions meet WCAG AA
- [ ] Gray unchanged text meets WCAG AA

### Semantics
- [ ] Diff regions properly labeled
- [ ] Line numbers announced but not redundant
- [ ] File path is accessible

---

## Integration Tests

### Test with Different Agent Types

**1. Coding Agent**
- Scenario: Python development agent
- Expect: Frequent file edits, diffs show well

**2. Configuration Agent**
- Scenario: YAML/JSON config editor
- Expect: Structured file diffs, proper language detection

**3. Documentation Agent**
- Scenario: Markdown documentation updater
- Expect: Text-focused diffs, readable without syntax highlighting

---

## Documentation Updates Needed

1. **User Guide**: Explain diff viewer to users
2. **Agent Development Guide**: How agents should format tool returns
3. **Troubleshooting**: What to do if diff doesn't appear
4. **Feature Request**: File system control (tracked separately)

---

## Known Limitations

1. **No Inline Editing**: Users cannot edit files directly in the diff viewer (read-only)
2. **No Side-by-Side View**: Only unified diff view is implemented
3. **No Diff Export**: Cannot export diff as patch file
4. **No Blame Information**: No git integration for commit history

---

## Future Enhancements (Post-MVP)

1. **Side-by-Side Diff Mode**
   - Show old and new versions side by side
   - Synchronized scrolling
   - Better for large changes

2. **Diff Statistics**
   - Show summary: "Added 5 lines, removed 3 lines"
   - Character-level statistics
   - File size change indicator

3. **Search in Diff**
   - Highlight search terms across old/new content
   - Navigate between matches

4. **Undo Integration**
   - "Revert this change" button
   - Apply specific diffs only

5. **Diff Export**
   - Download as `.patch` file
   - Copy to clipboard
   - Share via link

---

## Sign-Off

**Implementation**: ✅ Complete (2026-01-12)
**Testing**: ⏳ Blocked - Awaiting File System Control
**Documentation**: ⏳ Pending

**Next Priority**: Implement File System Management (Chat Feature Plan - Phase 2)

---

**Last Updated**: 2026-01-12
**Status**: Test Plan Created - Waiting for Prerequisites
