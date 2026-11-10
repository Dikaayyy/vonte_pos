# AGENTS.md - Vonte PoS

Instructions for AI coding agents working in this repository. Read this file and `DESIGN.md` before writing code.

**Precedence:** the tool-managed blocks at the end of this file (`antislop`, `ponytail`) are general-purpose. If anything in them conflicts with the project sections above them, the project sections win. Do not edit inside the marker comments of those blocks.

## Project

**Vonte PoS** is a standalone, 100% offline Point of Sale app for a food and beverage and retail business, built with Flutter. It is a take-home test for a Mobile Developer role. Full creative freedom over name, logo, UI, and flow, but the evaluation weights are:

1. Cashier speed and ease during a transaction (UX ergonomics) is the highest weight.
2. The four hard logic rules below.
3. Architecture, state management, database quality.
4. Bonus features.

The developer must be able to explain the architecture, data flow, database schema, and every function in a live technical interview, including live coding. Optimize for code the developer can read and explain, not for cleverness.

## Hard constraints

- Flutter and the latest stable Dart. Mobile is the primary target. Tablet portrait and landscape are bonus.
- Fully offline. No network packages, no Firebase, no analytics, no remote fonts, icons, or images.
- Architecture: Clean Architecture, organized by feature.
- State management: Cubit (`flutter_bloc`) with `equatable`.
- Database: SQLite via `sqflite`, relational schema, atomic transactions for stock deduction.
- Light theme only. Visual rules live in `DESIGN.md` and are binding for all UI work.
- UI language: Bahasa Indonesia. Code, identifiers, and docs: English.
- Do not add a package that is not listed in this file without asking first.

## Packages

Add with `flutter pub add <name>` so versions resolve to the latest compatible. Never copy version numbers from memory.

- Runtime: `flutter_bloc`, `equatable`, `get_it`, `sqflite`, `path`, `path_provider`, `image_picker`, `crypto`, `intl`.
- Dev: `flutter_test`, `bloc_test`, `mocktail`, `flutter_lints`, `sqflite_common_ffi`.
- Bonus, only when that feature is started: `fl_chart` (charts); a Bluetooth thermal printing package plus an ESC/POS helper (check that the package is actively maintained before choosing).

Navigation: Flutter's built-in `Navigator` with named routes.

## Architecture

Feature-first Clean Architecture. Dependencies point inward: presentation -> domain <- data.

```
lib/
  main.dart
  app.dart
  core/
    constants/        app_strings.dart, app_constants.dart
    database/         app_database.dart (open, migrations, PRAGMA), table definitions
    di/               injection.dart (get_it registrations)
    error/            failures.dart, result type
    theme/            app_theme.dart, tokens, app_glass.dart, shared buttons and cards
    utils/            format_rupiah.dart, date helpers, password hasher
    widgets/          shared widgets (empty state, inline error, qty stepper)
  features/
    auth/             data, domain, presentation
    store_profile/    data, domain, presentation
    category/         data, domain, presentation
    product/          data, domain, presentation
    addon/            data, domain, presentation
    cashier/          cart, stock validation, discount, checkout
    transaction/      receipt, history, report
    dashboard/        (bonus analytics)
  # each feature:
  #   domain/        entities, repository interfaces, use cases (pure Dart, no Flutter, no sqflite)
  #   data/          models (map <-> entity), data sources (sqflite), repository implementations
  #   presentation/  cubit + state, pages, widgets
test/                mirrors lib/
```

Layer rules:

- `domain` imports nothing from Flutter, `sqflite`, or `data`/`presentation`.
- Business rules (stock validation, discount calculation, totals, invoice numbering) live in `domain` as plain Dart so they are unit-testable and easy to explain.
- Widgets never call the database or repositories. They read Cubit state and call Cubit methods.
- Cubits call use cases only.
- One Cubit per feature concern: `AuthCubit`, `CategoryCubit`, `ProductCubit`, `AddonCubit`, `CartCubit`, `CheckoutCubit`, `ReportCubit`. No giant Cubit.
- States are immutable, extend `Equatable`, have `copyWith`, and carry an explicit status (initial, loading, success, failure) plus a user-facing error message when relevant.
- Money is `int` rupiah everywhere. Never `double`.
- Timestamps are stored as epoch milliseconds (UTC) integers and formatted for display only in the presentation layer.

## Database schema (v1)

Enable foreign keys on open (`PRAGMA foreign_keys = ON` inside `onConfigure`). Use versioned migrations from day one.

- `users` (id, name, username UNIQUE, password_hash, salt, created_at)
- `sessions` (id, user_id FK, logged_in_at) - at most one active row; splash screen reads this
- `store_profile` (id, name, address, phone, receipt_footer) - one row, editable in Pengaturan, seeded with defaults
- `categories` (id, name UNIQUE)
- `products` (id, category_id FK NULL ON DELETE SET NULL, name, price, stock, photo_path, is_deleted, created_at, updated_at)
- `addons` (id, name, price, stock, is_deleted)
- `product_addons` (product_id FK, addon_id FK, PRIMARY KEY (product_id, addon_id))
- `transactions` (id, invoice_no UNIQUE, cashier_id, cashier_name, store_name, store_address, store_phone, subtotal, discount_type, discount_value, discount_amount, total, cash_received, change_amount, created_at)
- `transaction_items` (id, transaction_id FK, product_id (reference only), product_name, unit_price, qty, line_total)
- `transaction_item_addons` (id, transaction_item_id FK, addon_id (reference only), addon_name, addon_price, qty, line_total)

Rules:

- Products and add-ons are **soft-deleted** (`is_deleted = 1`). Hide them from the cashier and master lists, but keep the rows so history never breaks.
- Transaction tables store **snapshots** (names, prices, store details, cashier name). Receipts and reports read only from transaction tables, never join to current product prices.
- Category deletion sets `products.category_id` to NULL after a confirm dialog.
- `photo_path` stores a path relative to the app documents directory, not an absolute path.

## The four hard rules

These are explicit evaluation criteria. Each needs unit tests.

### 1. Shared stock validation

A product's stock is consumed by **all cart lines of that product combined**, regardless of add-ons.

- Product units used = sum of `qty` over every cart line with the same `product_id`.
- Add-on units used = sum over lines of (`line.qty` x number of that add-on attached to the line).
- Example: stock 2, cart has 1x Milk Coffee plain and 1x Milk Coffee + Extra Shot. Product units used = 2, so a third add is blocked. The same logic applies to add-on stock.
- Cart line identity = product + the set of attached add-ons. Adding the same combination increases `qty`.
- Validation runs on every add and every quantity change in `domain` (a `StockValidator`), and the UI shows the reason ("Stok tidak cukup. Tersisa 2.").
- It runs **again inside the checkout database transaction** against current stock rows. Deduct with `UPDATE ... SET stock = stock - ? WHERE id = ? AND stock >= ?` and treat zero affected rows as failure that rolls the whole transaction back.

### 2. Transaction history immutability

Changing a product's price or deleting the product after a sale must not change old receipts or reports, and must not cause nulls or errors. Achieved by snapshot columns, soft delete, and reports reading only transaction tables. Test it: sell, change price, soft-delete, reload receipt and report, assert unchanged.

### 3. Offline photo persistence

After `image_picker` returns a file, copy it into `<documents dir>/product_images/` with a generated unique filename, store the relative path, and resolve it at display time. Never keep the picker's cache path. Optionally limit size via `maxWidth` and `imageQuality`. When a photo is replaced, delete the old file. A missing file must show the placeholder, not crash.

### 4. Discount protection

- Percent discount: integer from 0 to 100 inclusive.
- Fixed discount: from 0 up to the subtotal inclusive.
- `discount_amount` is calculated in integer rupiah with one documented rounding rule (round half up), and `total = subtotal - discount_amount` is never negative.
- Invalid input shows an inline error and disables "Bayar". Enforce the same rules in the domain, not only in the UI.
- Cash received must be at least the total. Change = cash received - total.

## Checkout transaction

Inside a single `db.transaction`:

1. Re-validate stock for every product and add-on.
2. Generate `invoice_no` (format `VNT-YYYYMMDD-0001`, sequence resets daily).
3. Insert `transactions`, then `transaction_items`, then `transaction_item_addons`, all with snapshots.
4. Deduct product and add-on stock.
5. Any failure rolls back everything. The cart is cleared only after success.

## Feature scope

Mandatory (from the test): splash with session check, register and offline login with validation, category CRUD with cashier filter, product CRUD with photo (camera or gallery), add-ons with their own stock attachable to products, search and category filter, cart with add-ons and quantity changes, percent or fixed discount, cash and change, receipt preview (store and cashier details, time, items and add-ons, subtotal, discount, total, payment, change), offline report (total revenue, successful transaction count, history).

Planned bonus, in priority order (update this list as decisions change):

1. Low stock indicator
2. Quick cash buttons
3. Responsive tablet layouts
4. Hold / save bill
5. Date filters and charts on the dashboard
6. Bluetooth thermal printer (ESC/POS), last because it needs a physical device to verify

Nice to have: a "Muat data contoh" action in Pengaturan that seeds sample categories, products, and add-ons so a reviewer can test the APK quickly.

## UI rules

- Follow `DESIGN.md`. Use the shared `AppGlass`, `AppCard`, and button widgets. Do not hand-roll glass or colors in screens.
- No gradients on components. No dark theme. No blurred items inside lists.
- Tap targets 48dp or larger. Tabular numerals. Money right-aligned. One `formatRupiah` helper.
- All strings in `app_strings.dart`.

## Working agreements

- Work in small vertical slices (one feature path at a time: entity, repository, use case, Cubit, UI, tests). Do not generate the whole project in one go.
- Before starting a slice, state the plan in a few lines. After it, run `flutter analyze` and `flutter test` and fix issues before moving on.
- Touch only files related to the current slice.
- If the spec is ambiguous, ask instead of guessing.
- Prefer simple, explicit code. Avoid abstractions that need a long explanation. Add a short comment only for non-obvious business reasons (why, not what).
- Keep `README.md` current as features land: architecture, state management, table structure, bonus features.

### Interaction with other agent skills

The `ponytail` and `antislop` blocks at the end of this file are installed by their tools. They stay untouched. This section says how they apply here.

**ponytail (minimal code)**

- Everything listed under "Feature scope", "The four hard rules", and "Checkout transaction" counts as asked for. Do not skip or shrink it because ponytail says to skip features. A vague request is still resolved against this file, not reduced to a minimal version.
- Ponytail's "keep the structure the codebase already has" means: keep the Clean Architecture layers, repository interfaces, use cases, and Cubits described here. Do not collapse layers to save lines.
- Never apply the lazy approach to: architecture layers, domain validation, the checkout transaction, schema constraints (foreign keys, soft delete, snapshots), or tests.
- The "one small test" in ponytail is a minimum. The Testing section in this file is the requirement.
- Lean code is welcome inside a layer: no extra wrappers, no speculative options, no unused abstractions.
- Mark a deliberate shortcut with `shortcut: <the limit>, <when to upgrade>` as ponytail asks. The developer must be able to explain every shortcut in the interview.
- Keep ponytail's closing note (what was skipped or not checked, plus risks) at the end of each reply.

**antislop**

- Use "during" mode while building and "after" mode for the final audit. Announce the active mode as the antislop block requires.
- No emoji, banner comments, or comments that restate code. No invented numbers or placeholder stats in UI or seed data.
- UI direction comes from `DESIGN.md`. If antislop asks for a direction, point it there.

**If still unsure:** follow the project sections, keep the change small, and ask.

## Testing

Required unit tests (domain and Cubit level):

- Shared stock validation, including the Milk Coffee + Extra Shot example and add-on stock.
- Discount calculation and every guard in rule 4.
- Total, cash, and change calculation.
- Immutability scenario from rule 2 (repository-level test using an in-memory or temporary database).
- Rupiah formatter output.
- Checkout rollback when stock is insufficient mid-transaction.

Use `bloc_test` for Cubits and `mocktail` for mocked repositories.

## Definition of done

- Every mandatory feature above works fully offline on a release build.
- The four hard rules have passing tests.
- `flutter analyze` is clean and `flutter test` passes.
- Release APK builds (`flutter build apk --release`) and is installed and smoke-tested on a device or emulator.
- `README.md` covers project architecture, state management, database table structure, and bonus features implemented.
- Repository is on GitHub or GitLab with access for the reviewer.

<!-- antislop:start -->
## antislop
For UI, copy, people, mobile layout, or code comments work, read these installed skill files directly (use these paths even if a same-named global skill exists):
- Core filter, always on: `antislop`: `.agents/skills/antislop/SKILL.md`
- UI / visual: `antislop-ui`: `.agents/skills/antislop-ui/SKILL.md`
- Mobile / responsive: `antislop-layoutmobile`: `.agents/skills/antislop-layoutmobile/SKILL.md`
Before starting, follow the core's "Two Usage Modes" section in strict order: explicit session instruction first, then global preference, then ask. A session instruction always wins. For a resolved mode, say `antislop active: <mode> (session override).` or `antislop active: <mode> (global preference).` once before presenting findings or making edits, using the actual mode and source. Acknowledging the user's request without naming the source does not replace this notice.
Only an explicit choice of antislop during or after selects a session mode. A request to review, audit, or avoid file edits does not select a mode; read the global preference in that case. Another skill's mode does not select antislop's mode.
If the mode is unresolved, ask during/after and end the response; wait for the answer before any UI review, planning, or concept. For read-only tasks, put the active-mode notice only at the start of the final answer, never in progress messages. For editing tasks, announce before the first edit and omit it from the final answer.
To update antislop later: `npx antislop-ai --update`, or run `npx antislop-ai` and pick Overwrite them.
<!-- antislop:end -->

<!-- ponytail:start -->
# Ponytail, lazy senior dev mode

You are a lazy senior developer. The best code is the code never written. You solve the whole problem with the least new code. End your reply with one or two lines: what you skipped or did not check, and any risk the user must know.

## Before you write

Read the task and the code it touches. List every place your change must reach: callers, tests, fixtures, config, exports. Check what your change could break for users: data it would destroy or expose, callers that stop working. That is scope. Extra features are not.

## The smallest complete change

Take the first option that fully works:

1. Does it need to exist? Skip features, options and flexibility nobody asked for, and name them in one line. A vague request ("build me X") gets the smallest version that does the core job.
2. Already in this codebase (a helper, component, service, pattern)? Use it the way the surrounding code does.
3. Standard library or a platform feature? Use it, unless the project has its own. A house component beats a native widget.
4. An installed dependency? Use it. Never add a dependency for a few lines.
5. Can it be one line a reader gets at a glance? One line.
6. Otherwise: the minimum code that works.

- Be lazy about the solution, never about the change itself: finish every part the task needs, including the callers, tests and fixtures your change breaks.
- No abstraction, wrapper, type conversion, option, config, boilerplate or "for later" code nobody asked for. Keep values in the form the platform already gives you. Deletion beats addition. Keep the structure the codebase already has: its layers, interfaces and conventions.
- The shortest working diff wins, once you know everything it must touch. A one-liner that needs decoding is not short.
- Comment only the why the code cannot show, in one line.
- Bug fix: before you edit, grep every caller of the function you touch, then fix the root cause once in the shared code.
- Code you move or merge keeps its error handling and validation.
- Between options of equal size, take the one that is correct on edge cases.
- Lazy code without its check is unfinished: new non-trivial logic (a branch, a loop, a parser, money or security, or a whole new script or app) leaves one small test or an assert-based self-check. Trivial changes need none.
- A shortcut with a known limit gets a code comment in this form: `shortcut: <the limit>, <when to upgrade>`.

Never cut: validation at trust boundaries, error handling that prevents data loss, security, accessibility, the calibration real hardware needs, anything the user asked for.
<!-- ponytail:end -->