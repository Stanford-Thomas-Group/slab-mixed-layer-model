# AGENTS.md

## Overview

Slab mixed layer model: computes the mixed-layer transport response to a wind
forcing timeseries via the exact analytical solution to the slab model ODE
(see `README.md` for the theory and the wind angle/amplitude conventions).
Implemented in parallel as a Python package (`python/`) and a MATLAB package
(`matlab/`), sharing the same theory, conventions, and default bulk
wind-stress formula (Large & Pond, 1981).

## Python (`python/`)

- Dependency management: `uv`. Single-module package at
  `src/slabmodel/__init__.py`.
- Lint/format: `ruff` (numpy-convention docstrings enforced via `D` rules on
  all public functions; `tests/` exempt). Type checking: `ty`. Testing:
  `pytest`.
- Checks (from `python/`): `uv run ruff check .`, `uv run ruff format --check .`,
  `uv run ty check`, `uv run pytest`.

## MATLAB (`matlab/`)

- Package folder `+slabmodel/`, one function per file, camelCase naming.
- Tests: `matlab.unittest` classes under `tests/`.
- Build/check/test tasks defined in `buildfile.m` (`check` = CodeIssuesTask,
  `test` = TestTask). Run (from `matlab/`): `matlab -batch "buildtool check test"`.
  Requires MATLAB R2024b+.

## CI

GitHub Actions (`.github/workflows/python-ci.yml`, `matlab-ci.yml`) run the
above checks on pull requests and pushes to `main`.
