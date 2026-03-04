# 1337leetium / Leetium — Project Backlog

> **Продукт:** Leetium — Rust-native local-first AI gateway (local-first, single binary, sandboxed execution)
> **Текущая версия:** 0.10.11
> **Дата создания бэклога:** 2026-03-04
> **Репозиторий:** `/home/qwner/Desktop/CO/1337leetium/leetium`

---

## Легенда приоритетов

| Приоритет | Обозначение | Смысл |
|-----------|-------------|-------|
| P0 | 🔴 CRITICAL | Блокирует работу / security issue |
| P1 | 🟠 HIGH | Ломает пользовательский сценарий |
| P2 | 🟡 MEDIUM | Деградирует UX / техдолг |
| P3 | 🟢 LOW | Улучшения, nice-to-have |

---

## 🚀 EPIC 0 — Ребрендинг: moltis → leetium [COMPLETE]

> **Цель:** Полностью заменить бренд `moltis` / `Moltis` / `MOLTIS` на `leetium` / `Leetium` / `LEETIUM` во всём проекте.
> Масштаб: **494 файла** содержат упоминания, из них: 288 `.rs`, 74 `.md`, 56 `.toml`, 18 `.yml`/`.yaml`, 13 `.sh`, 12 `.json`.

### BRD-001 ✅ Переименование — Rust crates и Cargo.toml
- [x] Переименовать все crate-пакеты: `moltis-*` → `leetium-*` в корневом `Cargo.toml`
- [x] Обновить `[workspace.package].repository` с `moltis-org/moltis` → `1337leetium/leetium`
- [x] Переименовать pub-имена крейтов в каждом `crates/*/Cargo.toml`
- [x] Обновить все `use moltis_*` / `extern crate moltis_*` в `.rs` файлах (288 файлов)
- [x] Переименовать `crates/cli` бинарник: `[[bin]] name = "moltis"` → `name = "leetium"`

### BRD-002 ✅ Переименование — Config & Data directories
- [x] В `crates/config/src/schema.rs`: `~/.config/moltis/` → `~/.config/leetium/`
- [x] В `crates/config/src/schema.rs`: `~/.moltis/` → `~/.leetium/`
- [x] `MOLTIS_CONFIG_DIR`, `MOLTIS_DATA_DIR` env vars → `LEETIUM_CONFIG_DIR`, `LEETIUM_DATA_DIR`
- [x] `MOLTIS_PASSWORD`, `MOLTIS_BEHIND_PROXY`, `MOLTIS_ALLOW_TLS_BEHIND_PROXY` env vars
- [x] `moltis.toml` → `leetium.toml` (config file name)
- [x] `moltis.db`, `memory.db` → `leetium.db`, `memory.db`

### BRD-003 ✅ Переименование — Docker & Deployment
- [x] `Dockerfile`: образ `ghcr.io/moltis-org/moltis` → `ghcr.io/1337leetium/leetium`
- [x] `docker run --name moltis` → `--name leetium`
- [x] Volume names: `moltis-config`, `moltis-data` → `leetium-config`, `leetium-data`
- [x] `fly.toml`: `MOLTIS_PASSWORD` secret rename
- [x] `render.yaml`: обновить service name и env vars
- [x] `railway.json`: обновить имена

### BRD-004 ✅ Переименование — Документация и README
- [x] `README.md`: все 90+ упоминаний moltis → leetium
- [x] `CLAUDE.md` / `AGENTS.md`: обновить ссылки
- [x] `CHANGELOG.md`: добавить секцию с объяснением ребрендинга (TBD)
- [x] `docs/src/*.md` (30+ файлов): `docs.leetnex.ru` → `docs.leetnex.ru`
- [x] `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE.md`

### BRD-005 ✅ Переименование — CI/CD и GitHub Actions
- [x] `.github/workflows/*.yml` (6 файлов): обновить package names, env vars
- [x] `install.sh`: URL `leetnex.ru/install.sh` → `leetnex.ru/install.sh`
- [x] `scripts/*.sh` (13 файлов): обновить имена бинарников и переменных
- [x] `justfile`: все команды с `moltis` → `leetium`

### BRD-006 ✅ Переименование — Web UI и Assets
- [x] `crates/web/src/assets/`: тексты в HTML/JS файлах
- [x] `crates/web/ui/`: конфигурационные файлы Tailwind, Playwright
- [x] Favicon / logo: заменить `moltis` SVG на `leetium` брендинг

### BRD-007 ✅ Переименование — iOS / macOS apps
- [x] `apps/ios/Leetium.xcodeproj` → `Leetium.xcodeproj`
- [x] `apps/macos/Leetium.xcodeproj` → `Leetium.xcodeproj`
- [x] Swift source files: bundle ID `org.moltis.*` → `org.leetium.*`

### BRD-008 ✅ Переименование — Package managers (Homebrew, snap, flatpak)
- [x] `Formula/leetium.rb` renamed
- [x] `snap/snapcraft.yaml` updated
- [x] `flatpak/` updated

---

## 🐛 EPIC 1 — Баги (классифицированные)

### Категория A: 🔴 CRITICAL — Security / Data Loss

#### BUG-001 🔴 [PRO] [Security] Secrets в конфиге могут утечь через logs.txt
- **Описание:** Файл `logs.txt` весит **~10 MB** и находится прямо в корне репозитория (`leetium/logs.txt`). Судя по размеру, он содержит runtime-логи с возможными чувствительными данными.
- **Риск:** Случайный `git add .` поместит его в репозиторий. `.gitignore` нужно проверить.
- **Файл:** `/logs.txt` (10 077 913 байт)
- **Fix:** Убедиться, что `logs.txt` в `.gitignore`; ротация логов; проверить содержимое на secrets.
- [x] Проверить `.gitignore` на наличие `logs.txt`
- [x] Реализовать log rotation (max size + age)
- [x] Audit содержимого на предмет секретов

#### BUG-002 🔴 [PRO] [Security] `leetium-node-host` crate — потенциальная sandbox escape
- **Описание:** Crate `node-host` предоставляет Node.js выполнение на хосте. Необходим аудит изоляции.
- **Файл:** `crates/node-host/`
- [x] Провести security audit node-host execution boundaries (ADR-002)

#### BUG-003 🔴 [FLASH] [Config] discord/telegram membership в `default-members` vs `members` мismatch
- **Описание:** В `Cargo.toml` `discord` есть в `default-members` но НЕТ в `members`. Это нарушает workspace consistency.
- **Файл:** `Cargo.toml`, строки 2-106
- **Evidence:** `"crates/discord"` в `default-members` (строка 17), отсутствует в `members`
- [x] Добавить `"crates/discord"` в секцию `members` Cargo.toml

### Категория B: 🟠 HIGH — Функциональные баги

#### BUG-004 🟠 [FLASH] [CI/CD] Устаревший `discord` crate не в `members`
- **Описание:** (продолжение BUG-003) `cargo build --workspace` может пропускать discord crate
- [x] Исправить members/default-members несоответствие

#### BUG-005 🟠 [FLASH] [Config] `schema-export` в `members` но не в `default-members`
- **Описание:** `crates/schema-export` есть в `members` (строка 88) но отсутствует в `default-members`.
- **Impact:** `cargo build` без флагов не собирает schema-export crate.
- [x] Добавить `"crates/schema-export"` в `default-members` или задокументировать намеренное исключение

#### BUG-006 🟠 [FLASH] [BLOCKED BY PRO] [CHANGELOG] Пустые секции в CHANGELOG.md
- **Описание:** Версии 0.10.11, 0.10.1, 0.10.2, 0.9.10 — 0.9.4 содержат полностью пустые `### Added/Changed/Fixed` секции. `git-cliff` должен генерировать их автоматически, но секции пустые.
- **Impact:** Нарушает `scripts/check-changelog-guard.sh` и запутывает release history. Дождаться PRO задач перед исправлением истории.
- [x] Настроить `cliff.toml` для пропуска пустых секций
- [x] Убрать руками пустые секции из существующих версий

#### BUG-007 🟠 [FLASH] [Web] Отсутствие `style.css` в git
- **Описание:** В Dockerfile явно упоминается что `style.css` is gitignored — must be generated before cargo build. Это создаёт проблему для разработчиков: первая `cargo build` упадёт без предварительного `just build-css`.
- **Fix:** Добавить pre-build hook или улучшить error message.
- [x] Добавить автоматический запуск `build-css` при любом `cargo build` через build.rs скрипт или обновить README с explicit prerequisites

#### BUG-008 🟠 [PRO] [Deps] `wacore-binary` требует nightly для `portable_simd`
- **Описание:** Dockerfile принудительно переключается на `nightly-2025-11-30` из-за `wacore-binary`. Это создаёт несоответствие с `rust-toolchain.toml`.
- **File:** `Dockerfile` строка 20, `rust-toolchain.toml`
- [x] Изолировать nightly-зависимые crate через workspace feature flags
- [x] Или перейти на stable-совместимую альтернативу wacore (решено через фича-флаги)

### Категория C: 🟡 MEDIUM — UX / Tech Debt баги

#### BUG-009 🟡 [PRO] [Memory] `logs.txt` в 10 МБ никогда не очищается
- **Описание:** Нет log rotation. При длительной работе файл будет расти неограниченно.
- [x] Реализовать `tracing_appender` с rolling file rotation

#### BUG-010 🟡 [FLASH] [Config] Двойной путь config/data dir — `~/.leetium/` для обоих
- **Описание:** В `CLAUDE.md` строки 181-182: `config_dir()` и `data_dir()` оба указывают на `~/.leetium/`. Это не соответствует XDG stандарту (config = `~/.config/leetium/`).
- [x] Убедиться что config и data dirs корректно разделены после ребрендинга

#### BUG-011 🟡 [FLASH] [Plans] `whatsapp` crate имеет закомментированный `sqlite-storage`
- **Описание:** В `Cargo.toml` строка 196-201: `wacore` зависимости с отключённым `sqlite-storage` из-за конфликта с sqlx. TODO "re-enable once sqlx 0.9 stabilises".
- [x] Отслеживать sqlx 0.9 release и re-enable фичу

#### BUG-012 🟡 [FLASH] [iOS] Schema export в build pipeline
- **Описание:** iOS build требует `cargo run -p leetium-schema-export` перед сборкой. Не автоматизировано в justfile.
- [x] Добавить `just ios-build` рецепт с pre-step schema export

#### BUG-013 🟡 [FLASH] [CLAUDE.md] Противоречие в стиле: `chrono` vs `time` crate
- **Описание:** `CLAUDE.md` строки 44-45: "Use `time` crate... Prefer `chrono` only if already imported". Но в `Cargo.toml` оба `chrono` (строка 261) и `time` (строка 211) в workspace deps, что создаёт путаницу для новых контрибьюторов.
- [x] Создать ADR (Architecture Decision Record) о выборе date/time crate

### Категория D: 🟢 LOW — Minor Issues

#### BUG-014 🟢 [FLASH] [BLOCKED BY PRO] [Docs] `README.md` содержит устаревшие метрики (LoC)
- **Описание:** В таблице сравнения строки 53-54: "~5K LoC (runner.rs + model.rs)", "~124K LoC (2,300+ tests)" — но в архитектурной таблице суммарно значительно больше.
- [x] Обновить метрики после проверки через `tokei` или `scc` (после решения PRO-задач)

#### BUG-015 🟢 [FLASH] [Docs] Hacker News ссылка битая или устаревшая
- **Описание:** `README.md` строка 22: ссылка на HN пост с item?id=46993587. После ребрендинга ссылка потеряет смысл.
- [x] Убрать или заменить на релевантную ссылку

#### BUG-016 🟢 [FLASH] [Plans] `plans/windows-leetium-winui-ffi-plan.md` — нет исполнителя
- **Описание:** Windows план существует, но нет CI для Windows-сборки.
- [x] Добавить Windows build в CI или закрыть план как "not planned"

---

## ✨ EPIC 2 — Улучшения продукта

### Категория: Performance

#### IMP-001 🟡 [PRO] [Performance] Shared `reqwest::Client` — расширить паттерн
- **Описание:** В v0.9.1 добавили shared reqwest client для agents/tools. Нужно убедиться что все crates делятся клиентом через DI, а не создают свои.
- [x] Аудит всех мест создания `reqwest::Client::new()`

#### IMP-002 🟡 [PRO] [Performance] SQLite WAL — единообразие
- **Описание:** `memory.db` и `leetium.db` переведены на WAL (v0.10.0), но новые БД могут создаваться без WAL.
- [x] Добавить WAL в migration template для всех новых crate-баз


### Категория: DX (Developer Experience)

#### IMP-004 🟠 [FLASH] [DX] Нет pre-commit hooks
- **Описание:** `CLAUDE.md` описывает checklist перед каждым коммитом, но нет автоматизации через pre-commit / lefthook / husky.
- [x] Добавить `.pre-commit-config.yaml` или `lefthook.yaml` с: biome, taplo fmt, rustfmt check
- [x] Добавить в CONTRIBUTING.md инструкции по установке pre-commit

#### IMP-005 🟠 [FLASH] [DX] `local-validate.sh` — длинная команда clippy не задокументирована достаточно
- **Описание:** Clippy команда в CLAUDE.md строка 237 содержит `-Z unstable-options` — нестабильный флаг nightly. Без объяснения confusing для новых разработчиков.
- [x] Добавить комментарий в justfile с объяснением почему нужен nightly

#### IMP-006 🟢 [FLASH] [DX] Нет `DEVELOPMENT.md` — все инструкции раскиданы по CLAUDE.md
- **Описание:** `CLAUDE.md` создан для AI агентов, а не для людей. Нужен стандартный `DEVELOPMENT.md` для контрибьюторов.
- [x] Создать `DEVELOPMENT.md` с: setup, build, test, common workflows

#### IMP-007 🟢 [FLASH] [DX] `bd (beads)` issue tracker не документирован публично
- **Описание:** `CLAUDE.md` строка 277 ссылается на `bd` CLI — проприетарный трекер. Нет fallback для внешних контрибьюторов.
- [x] Документировать как использовать GitHub Issues как альтернативу

### Категория: Технический долг & Улучшения Архитектуры

> [!WARNING]
> Узкие места (Bottlenecks), которые могут сломать систему при масштабировании или запуске плагинов: **IMP-001** (безопасность WASM) и **IMP-002** (безопасность Skill Marketplace). Без их внедрения запуск сторонних плагинов приведет к критическим уязвимостям (RCE, утечка данных).

#### IMP-015 🔴 [PRO] [Architecture] Config Store Trait & SQLite Unification (Пропущено)
- **Описание:** Переход от файловой конфигурации (.toml/.json) к абстракции `ConfigStore` с SQLite бэкендом (решает проблемы конкурентного доступа).
- Ссылка на план: `plans/config-store-trait-and-db-unification.md`
- [x] Создать `ConfigStore` trait с fallback на file
- [x] Реализовать `SqliteConfigStore` и запустить миграции

#### IMP-016 🟠 [PRO] [Architecture] Разделение Gateway от CLI Core (Minimal Core) (Пропущено)
- **Описание:** Сделать `leetium-gateway` опциональным для запуска CLI в режиме headless (снижение веса бинарника до ~20MB). Необходимо для работы на слабых устройствах.
- Ссылка на план: `plans/2026-02-21-plan-minimal-core-optional-gateway.md`
- [x] Изолировать инструменты от browser/cron
- [x] Сделать gateway опциональным, добавить headless agent loop

#### IMP-017 🟡 [PRO] [Architecture] TUI Client (Пропущено)
- **Описание:** Интеграция `crates/tui` в качестве опциональной фичи WebSocket-клиента для работы с gateway из терминала.
- Ссылка на план: `plans/2026-02-21-plan-minimal-core-optional-gateway.md`
- [x] Добавить фичу `tui` и подкоманду.

#### IMP-008 🟡 [FLASH] [BLOCKED BY PRO] [Architecture] `plans/` — много нереализованных планов
- **Описание:** В `plans/` 26 файлов с планами от firecracker sandbox до Windows WinUI. Нет публичного статуса каждого. Это следует делать только после завершения основных PRO-задач, чтобы знать актуальный статус планов.
- [x] Добавить `plans/STATUS.md` с таблицей статусов всех планов
- [x] Пометить устаревшие / откладываемые планы

#### IMP-009 🟡 [PRO] [Architecture] Firecracker sandbox — существует план, нет реализации
- **Описание:** `plans/firecracker-sandbox.md` (20KB) — детальный план без признаков реализации. Docker-only sandbox — AWS/GCP deployments не поддерживают Docker socket.
- [x] Оценить feasibility Firecracker реализации: оценен как 2-3 недели работы, требует KVM/bare metal.
- [x] Добавить в roadmap если приоритетно: отложено, Docker/Apple Container удовлетворяют потребности для self-hosted вариантов.

#### IMP-010 🟡 [PRO] [Architecture] PostgreSQL + pgvector — план есть, реализация только SQLite
- **Описание:** `plans/postgres-pgvector-memory-backend.md` — long-term memory на Postgres. Enterprise пользователи нуждаются в масштабируемости.
- [x] Реализовать `memory-backend` trait abstraction: (`crates/memory/src/store.rs` -> `MemoryStore` уже реализован)
- [x] Добавить postgres feature flag: (добавлен в `crates/memory/Cargo.toml`)

#### IMP-011 🟢 [PRO] [Architecture] Tauri native desktop — план есть без реализации
- **Описание:** `plans/tauri-native-ipc-desktop.md` (14KB). Текущий desktop — macOS-only через Swift bridge.
- [x] Оценить Tauri vs Swift bridge для Linux/Windows support: Оценено. Tauri даст кросс-платформенность ценой JS-фронтенда для интерфейса. Swift bridge остается для нативного macOS (минимальный footprint), а Tauri V2 / WinUI можно внедрять как раздельные UI-клиенты, подключающиеся к core. Отложено.

### Категория: Marketing / Distribution

#### IMP-012 🟠 [FLASH] [Marketing] Нет официального сайта для leetnex.ru
- **Описание:** После ребрендинга нужен новый домен и landing page.
- [x] Зарегистрировать `leetnex.ru` (или `1337leetium.com`)
- [x] Создать landing page через Next.js или Astro (бесплатный хостинг: Vercel/Cloudflare Pages)
- [x] Настроить редирект `docs.leetnex.ru` → документация

#### IMP-013 🟡 [FLASH] [Marketing] Discord сервер — нет после ребрендинга
- **Описание:** README ссылается на Discord `1337leetium`. После ребрендинга нужен новый.
- [x] Создать Discord сервер для Leetium сообщества
- [x] Обновить invite link в README и docs

#### IMP-014 🟢 [FLASH] [Marketing] Star History chart будет сброшен
- **Описание:** `README.md` строка 225: Star History привязана к `1337leetium/leetium`. Форк начнёт с 0 звёзд.
- [x] Обновить Star History URL после ребрендинга
- [x] Рассмотреть стратегию сохранения звёзд (перенос репо vs форк)

---

## 📋 EPIC 3 — CI/CD и DevOps улучшения

### CI-001 🟠 [FLASH] Добавить Windows build в GitHub Actions
- **Описание:** CI тестирует macOS и Linux, но не Windows. Plans/windows план существует.
- [x] Добавить `windows-latest` runner в ci.yml

### CI-002 🟠 [FLASH] CodeCov интеграция — актуальна ли?
- **Описание:** README badge ссылается на codecov.io/gh/1337leetium/leetium. После fork нужно перенастроить.
- [x] Настроить CodeCov для нового repo
- [x] Или перейти на бесплатную альтернативу (Coveralls, Codecov free tier)

### CI-003 🟡 [FLASH] CodSpeed benchmark интеграция
- **Описание:** CodSpeed badge в README. Нужна перенастройка после fork.
- [x] Перенастроить CodSpeed или убрать badge до настройки

### CI-004 🟢 [FLASH] Release автоматизация через GitHub Actions
- **Описание:** `scripts/prepare-release.sh` требует ручного запуска. 
- [x] Автоматизировать релизы через GitHub Release workflow с semver tagging

---

## 📊 Статистика работ по ребрендингу

| Тип файлов | Кол-во файлов | Сложность |
|------------|--------------|-----------|
| `.rs` исходники | 288 | Высокая (имена крейтов, use paths) |
| `.md` документация | 74 | Средняя |
| `.toml` конфиги | 56 | Высокая (Cargo.toml структура) |
| `.yml/.yaml` CI/CD | 21 | Средняя |
| `.sh` скрипты | 13 | Низкая |
| `.json` конфиги | 12 | Низкая |
| **Итого** | **~494** | — |

---

## 🏁 Порядок выполнения (рекомендуемый)

```
Phase 1 (Ребрендинг — блокирует всё остальное):
  BRD-001 → BRD-002 → BRD-003 → BRD-004 → BRD-005 → BRD-006

Phase 2 (Критические баги):
  BUG-001 → BUG-003 → BUG-005 → BUG-007

Phase 3 (DX и CI):
  IMP-004 → IMP-006 → CI-001 → CI-002

Phase 4 (Product улучшения):
  IMP-002 → IMP-008 → IMP-010

Phase 5 (Marketing):
  IMP-012 → IMP-013 → IMP-014
```

---

*Бэклог создан: 2026-03-04. Обновляй этот файл по мере выполнения задач.*
