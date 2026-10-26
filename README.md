# DevCamp 2.0 • Dart & Flutter Assignments Portfolio 🚀

> **DevSource / DevCamp 2.0 • Mobile App Development Track**  
> Maintained by **[@hiyaraj97-dev](https://github.com/hiyaraj97-dev)**

This repository hosts compulsory weekly assignments and capstone projects developed during **DevCamp 2.0**. Each project is organized into its own self-contained directory with dedicated source code, test suites, and documentation.

---

## 📂 Projects Directory

| Week | Project | Domain | Technologies | Folder Link |
|---|---|---|---|---|
| **Week 1** | **SplitSmart** | Expense Sharing & Debt Settlement | Modern Dart 3.x, Records, CLI, Unit Testing | [📁 `project1_splitsmart/`](project1_splitsmart/) |
| **Week 2** | **Taskify (To-Do App)** | Daily Task Management & Persistence | Flutter (Material 3), Key-Value Storage, Theming, State Management | [📁 `project2_todo_app/`](project2_todo_app/) |

---

## ⚡ Quick Start & Run Guides

### 1️⃣ Project 1: SplitSmart (Week 1 Compulsory)

SplitSmart is a command-line expense sharing and debt settlement engine that tracks group expenses, calculates net balances, handles custom splits, and simplifies debt transfers.

```bash
# Navigate to Project 1
cd project1_splitsmart

# Run all demonstrations (including the compulsory DevCamp test scenario):
dart run main.dart

# Open the Interactive Terminal Menu:
dart run main.dart --interactive

# Run the comprehensive test suite (15/15 tests passing):
dart run test/runner.dart
```

*🌐 Browser Option: Copy [`project1_splitsmart/dartpad_main.dart`](project1_splitsmart/dartpad_main.dart) into [DartPad](https://dartpad.dev).*

---

### 2️⃣ Project 2: Taskify To-Do App (Week 2 Compulsory)

Taskify is a Flutter to-do list application built with Material 3, input validation, categories, priorities, local persistent storage, dark mode, search, and progress tracking.

```bash
# Navigate to Project 2
cd project2_todo_app

# Run the Flutter application on Mobile, Desktop, or Chrome:
flutter pub get
flutter run
# or specifically on Chrome:
flutter run -d chrome

# Run the automated verification test suite:
dart test/runner.dart
```

*🌐 Browser Option: Copy [`project2_todo_app/dartpad_main.dart`](project2_todo_app/dartpad_main.dart) into [DartPad Flutter](https://dartpad.dev/flutter) to run the full application with simulated persistent storage and theme toggle.*

---

## 📋 DevCamp Week 2 Specification Checklist

- [x] **Add Task with Validation**: Modal sheet with title validation (`Task.validateTitle`), notes, priority, category, and due date.
- [x] **Edit & Delete Tasks**: Quick tap to edit; swipe-to-delete with confirmation modal and floating **UNDO** snackbar.
- [x] **Visual Completion Feedback**: Animated checkbox, strikethrough text, muted opacity, and sorting below active tasks.
- [x] **Local Persistent Storage**: Key-value JSON persistence (`SharedPreferencesStorageService`) restoring tasks between sessions.
- [x] **Categories & Priorities**: 6 categories with icons & badges, 3 urgency priority badges (High, Medium, Low).
- [x] **Light / Dark Mode Toggle**: AppBar toggle switching between Material 3 Light and Slate Dark mode, persisted to storage.
- [x] **Extensions Implemented**: Live search, status/category/priority filter chips, due date & overdue badges, progress summary card.
- [x] **Tested & Verified**: 100% test pass rate across models, services, and specification lifecycle.

---

## 👥 Repository Author

- GitHub: [@hiyaraj97-dev](https://github.com/hiyaraj97-dev)
- Repository: [devcampassignment1](https://github.com/hiyaraj97-dev/devcampassignment1)
