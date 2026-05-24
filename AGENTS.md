# AGENTS Guide: minotaur-plasmoid

## Big Picture
- This repo is a **KDE Plasma 6 plasmoid package** (no C++ backend); runtime logic is QML-only under `plasmoid/contents`.
- Entry point is `plasmoid/contents/ui/main.qml`, which switches between compact and full UI based on form factor.
- Both `CompactRepresentation.qml` and `FullRepresentation.qml` instantiate `TickerEngine.qml` and read shared state from `engine.market` and `engine.market_value`.
- `TickerEngine.qml` is the data/service layer: it polls exchange HTTP APIs on a `Timer`, parses results, and updates UI-facing QtObject properties.
- Config flows from `plasmoid.configuration` (defined in `plasmoid/contents/config/main.xml`) into the engine and triggers `retriever.restart()` on exchange/base/target changes.

## Key Files to Read First
- `plasmoid/contents/ui/TickerEngine.qml`: request loop, abort logic, exchange-specific URL/parser map.
- `plasmoid/contents/ui/FullRepresentation.qml`: richest view of expected market fields (`last`, `high`, `low`, `day_change`, `last_update`, `update_failed`).
- `plasmoid/contents/ui/config/general.qml`: config UI and exchange selection list.
- `plasmoid/metadata.json`: plasmoid id (`com.keithdarunday.minotaur`), Plasma API minimum version, package metadata.
- `CMakeLists.txt`: packaging/install target (`plasma_install_package(plasmoid com.keithdarunday.minotaur)`).

## Developer Workflows
- Manual install (from repo root):
  - `kpackagetool6 -t Plasma/Applet --install plasmoid`
- Manual upgrade after edits:
  - `kpackagetool6 -t Plasma/Applet --upgrade plasmoid`
- Local runtime test:
  - `plasmoidviewer --applet plasmoid`
- CMake install path is available but minimal; this project is primarily operated via `kpackagetool6` and `plasmoidviewer`.

## Project-Specific Patterns
- Engine state is exposed as plain `QtObject` properties instead of models/stores; UI binds directly to those fields.
- Each exchange entry in `market_functions.markets` defines both endpoint template(s) and a parser; add new exchanges by extending this map.
- Multi-request exchanges (e.g., Bittrex uses `urls`) are aggregated with `Promise.all(...)`, then parsed in one handler.
- Previous in-flight XHR is explicitly aborted before a new request (`retriever.previousRequest.abort()`), preventing stale updates.
- Error handling convention: set `market_value.update_failed = true` and log to console; `FullRepresentation.qml` reflects this by turning timestamp red.

## Integration Boundaries
- External dependencies are public exchange REST endpoints hardcoded in `TickerEngine.qml` (`api.binance.com`, `api.gateio.ws`, `api.bittrex.com`).
- Data contract between engine and UI is implicit property names on `market_value`/`market`; keep names stable when refactoring.
- Config key names must stay synchronized across:
  - `plasmoid/contents/config/main.xml` entries (`base`, `target`, `exchange`, `interval`)
  - `plasmoid.configuration.*` reads in `TickerEngine.qml`
  - `cfg_*` bindings in `plasmoid/contents/ui/config/general.qml`

## Agent Guardrails for Edits
- Prefer editing files in `plasmoid/contents/**`; avoid touching generated build artifacts in `CMakeFiles/` and generated `Makefile`.
- Keep QML imports compatible with Qt 6 / Plasma 6 as used now (for example `import QtQuick 6.0`, `org.kde.plasma.components 3.0`).
- When adding exchange support, update both parser logic and config UI choices (`general.qml` ComboBox model).
- Validate changes by running `plasmoidviewer --applet plasmoid` and exercising config changes to confirm timer restart/update behavior.
