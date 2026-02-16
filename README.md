# Gantt-Chart-Generator

A Python utility to generate a Gantt chart from task data in CSV format, with optional Excel export via **xlwings**.

## What it does

- Reads tasks/subtasks from a CSV file.
- Validates required columns and row values.
- Supports a project start date (prompted or passed via CLI).
- Builds per-task consequential timelines.
- Generates either:
  - interactive chart output with matplotlib (if installed), or
  - an SVG preview that works with standard Python only.
- Optionally exports into Excel via `xlwings` (task table + chart image when available).

## CSV structure

The input CSV must include these columns:

- `task`: Main task name.
- `subtask`: Subtask name.
- `duration`: Duration in days (must be positive).
- `consequential`: `Yes` or `No`.

Example:

```csv
task,subtask,duration,consequential
Main Task 1,Sub Task 1,3,Yes
Main Task 1,Sub Task 2,4,Yes
Main Task 2,Sub Task 1,2,No
Main Task 2,Sub Task 2,1,Yes
Main Task 3,Sub Task 1,2,Yes
```

## Installation

Optional dependencies:

```bash
pip install matplotlib xlwings
```

## Usage

Prompted mode:

```bash
python main.py
```

Generate a preview file (works in restricted environments):

```bash
python main.py --csv tasks.csv --start-date 2026-01-01 --output artifacts/gantt-preview.svg
```

Generate Excel output using xlwings:

```bash
python main.py --csv tasks.csv --start-date 2026-01-01 --output artifacts/gantt-preview.png --excel-output artifacts/gantt-plan.xlsx
```

> If `matplotlib` is unavailable, Excel export still writes task data and notes that chart image generation was skipped.

Optional arguments:

- `--csv` path to CSV file (default: `tasks.csv`)
- `--start-date` start date in `YYYY-MM-DD`
- `--title` custom chart title
- `--output` output path (`.svg` always works; image formats like `.png` require matplotlib)
- `--excel-output` output `.xlsx` path for xlwings export
- `--excel-sheet` sheet name for xlwings export (default: `Gantt Plan`)

## License

MIT.
