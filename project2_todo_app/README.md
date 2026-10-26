# Taskify - Flutter To-Do List App 📝

> **DevSource / DevCamp 2.0 • Week 2 • Project 2 • Compulsory**  
> Built with Flutter & Dart (Material 3, Key-Value Persistent Storage, Dynamic Theming, and Responsive State Management).

`Taskify` is a daily task management application designed according to the **DevCamp 2.0 Week 2 Compulsory Specification**. It enables users to create, organize, prioritize, search, and track daily tasks with persistence across app sessions and a light/dark theme toggle.

---

## 🚀 How to Run the Project

You can run and test this project through any of the three methods below:

### Option 1: Standard Flutter App (Mobile / Desktop / Web)

```bash
# 1. Navigate to the project directory
cd todo_app

# 2. Get dependencies
flutter pub get

# 3. Run on your connected device, emulator, or Chrome browser
flutter run
# or specify Chrome directly:
flutter run -d chrome
```

### Option 2: Standalone DartPad (Zero Local Setup)

Reviewers or evaluators who want to test the entire app instantly without installing Flutter locally:
1. Open [DartPad Flutter](https://dartpad.dev/flutter).
2. Open [`dartpad_main.dart`](dartpad_main.dart).
3. Copy all code and paste it into the DartPad editor.
4. Click **Run** — the complete application (CRUD, dark mode toggle, simulated persistent storage, categories, and progress tracker) will launch directly in your browser.

### Option 3: Automated Dart Test Suite

Run the full verification suite directly from your terminal using Dart 3.x:

```bash
dart test/runner.dart
```

This verifies:
- Title validation & length constraints
- JSON serialization & round-trip deserialization
- Persistent storage service (save, load, corrupt recovery, dark mode state)
- The exact DevCamp demonstration completion cycle (Add 3, Edit 1, Complete 1, Delete 1, Persist & Re-open)
- Real-time search and multi-facet filtering (Status, Category, Priority)

---

## 📋 Features Checklist

### ✅ Compulsory Features (Specification Requirements)

| Feature | Status | Implementation Details |
|---|---|---|
| **Add a Task with Meaningful Title** | ✅ Complete | Modal bottom sheet (`TaskFormSheet`) with input validation (`Task.validateTitle`) preventing empty or single-character titles. Supports title, notes, priority, category, and optional due dates. |
| **Edit Existing Tasks** | ✅ Complete | Tap any task card or the edit button to open the pre-populated form, modify fields, and save instantly. |
| **Delete Tasks** | ✅ Complete | Swipe-to-delete with confirmation dialog, explicit delete button in form, and floating **UNDO** snackbar. |
| **Visual Completion Distinction** | ✅ Complete | Animated checkbox toggle; completed tasks display strikethrough text, muted opacity, and move beneath active pending tasks. |
| **Local Persistent Storage** | ✅ Complete | Abstracted `StorageService` implemented via `SharedPreferencesStorageService` with JSON serialization. Restores tasks seamlessly upon app restart. |
| **Categories & Priorities** | ✅ Complete | • **6 Categories**: Work, Personal, Study, Shopping, Health, Other (with distinct icons & badges).<br>• **3 Priorities**: High (Red), Medium (Orange), Low (Green) with visual urgency indicators. |
| **Light / Dark Mode Toggle** | ✅ Complete | Animated header toggle supporting Material 3 Light Mode and Slate Dark Mode. User theme preference is saved and restored automatically. |

### 🌟 Implemented Optional Extensions

1. **Due Dates & Overdue Badges**:
   - Date picker integration.
   - Highlights tasks as **"Due Today"** (amber) or **"Overdue"** (red) if past due date.
2. **Real-time Live Search**:
   - Instant search bar filtering by task title and notes.
3. **Multi-facet Filter Chips**:
   - Filter by status (`All`, `Pending`, `Completed`).
   - Filter by Category or Priority with single-tap reset.
4. **Progress Summary Hero Card**:
   - Dynamic banner displaying completed vs total task counts.
   - Smooth animated linear progress bar with completion percentage.
   - Contextual motivational greetings based on progress.

---

## 🧪 Grader Walkthrough & Demonstration Steps

The DevCamp specification outlines a test scenario to demonstrate completion. Follow these steps to verify:

```
Step 1: Create at least three tasks
  • Task A: "Study Flutter State Management" (Category: Study, Priority: High)
  • Task B: "Buy groceries & fresh fruit" (Category: Shopping, Priority: Medium)
  • Task C: "Clean workspace desk" (Category: Personal, Priority: Low)
  -> Verify all 3 appear with color-coded priority and category badges.

Step 2: Edit one task
  • Tap on Task B -> Update title to "Buy fresh apples & almond milk" -> Save.
  -> Verify the title updates instantly on the home screen.

Step 3: Complete one task
  • Tap the checkbox on Task A.
  -> Verify strikethrough styling, muted color, and progress bar increments.

Step 4: Delete one task
  • Swipe left on Task C (or tap delete icon).
  • Confirm deletion -> Notice the "UNDO" notification appears.

Step 5: Verify Persistence (Close & Re-open)
  • Close the app / restart the process (or tap "Re-open / Restore from Storage" in DartPad).
  -> Verify Task A remains completed and Task B retains its edited title!

Step 6: Toggle Theme
  • Tap the Moon / Sun icon in the top AppBar.
  -> Verify clean transition between light and dark themes.
```

---

## 📁 Architecture & File Layout

```
todo_app/
├── lib/
│   ├── main.dart                                # Application entry point & service wiring
│   ├── models/
│   │   ├── task.dart                            # Domain entity with JSON serialization & validation
│   │   ├── task_category.dart                   # Category enum, colors, and icon mappings
│   │   └── task_priority.dart                   # Priority enum, weights, and color cues
│   ├── services/
│   │   ├── storage_service.dart                 # Abstract repository contract
│   │   ├── shared_preferences_storage_service.dart # SharedPreferences JSON persistence
│   │   └── in_memory_storage_service.dart       # Mock storage for testing and web fallbacks
│   ├── state/
│   │   ├── task_filter.dart                     # Search, status, category & priority filter logic
│   │   └── task_notifier.dart                   # Central state manager (ChangeNotifier)
│   ├── theme/
│   │   ├── app_theme.dart                       # Material 3 light & dark theme definitions
│   │   └── theme_notifier.dart                  # Theme switcher with persistent storage
│   ├── screens/
│   │   ├── home_screen.dart                     # Main dashboard view
│   │   └── task_form_sheet.dart                 # Modal bottom sheet for Add / Edit
│   └── widgets/
│       ├── progress_summary_card.dart           # Hero analytics & progress bar
│       ├── search_and_filter_bar.dart           # Search input & filter chips
│       ├── task_tile.dart                       # Dismissible task item with visual states
│       ├── empty_task_view.dart                 # Empty & zero-search-results states
│       ├── priority_badge.dart                  # Priority badge component
│       └── category_chip.dart                   # Category badge component
├── test/
│   ├── models/task_model_test.dart              # Model & validation tests
│   ├── services/storage_service_test.dart       # Storage persistence tests
│   ├── state/task_manager_test.dart             # State & specification lifecycle tests
│   └── runner.dart                              # Master zero-dependency test runner
├── web/
│   ├── index.html                               # Web runner configuration
│   └── manifest.json                            # Web app manifest
├── dartpad_main.dart                            # Standalone 1-file version for DartPad
└── pubspec.yaml                                 # Project configuration & dependencies
```

---

## 📹 Video Demonstration & Submission Checklist

- [x] Flutter source code in `lib/` and standalone executable `dartpad_main.dart`
- [x] CRUD operations fully implemented and tested
- [x] Input validation with error alerts
- [x] Key-value JSON local persistence
- [x] Category and priority visual organization
- [x] Light / Dark mode toggle with preference persistence
- [x] Comprehensive unit & integration tests (`dart test/runner.dart`)
- [ ] **Short demonstration video**: Record a 60-90 second screen recording following the [Grader Walkthrough](#-grader-walkthrough--demonstration-steps), upload to Google Drive / Loom / YouTube (Unlisted), and insert your link here:
  - *Demo Video Link: [Insert URL Here]*
- [ ] **GitHub Repository**: Push this directory to your GitHub account and submit the link through the official DevCamp form.
