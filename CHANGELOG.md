# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-06-14

### Changed

- `true ->` is no longer special-cased during macro expansion — it compiles
  through the same `if`/`else` path as every other clause, so it is treated like
  any other always-truthy condition rather than getting a dedicated shortcut.
  Runtime behavior is unchanged; the only observable effect is that a clause
  written after a catch-all is now compiled (as `cond` does) instead of being
  silently dropped.

## [0.1.0] - 2026-06-11

Initial release.

### Added

- `bound_cond/1` — a `cond` whose clauses can thread interim variables via
  `:bind ->` steps, keeping the same top-to-bottom evaluation, no-leak scoping,
  and `CondClauseError`-on-no-match semantics as `cond`.

[0.1.1]: https://github.com/DaTrader/bound_cond/releases/tag/v0.1.1
[0.1.0]: https://github.com/DaTrader/bound_cond/releases/tag/v0.1.0
