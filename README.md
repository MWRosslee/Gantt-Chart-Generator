# Gantt-Chart-Generator

A lightweight **HTML-only** Gantt chart generator that runs entirely in the browser.

## Description

This project provides a single-page web app (`index.html`) that converts CSV task data into a Gantt chart visualization with:
- task numbering / sequencing,
- dependency notifications,
- critical path highlighting,
- and **drag-to-edit scheduling** (move bars horizontally to change dates).

No Python, Node.js, or backend is required.

## CSV Format

### Required columns

- `task`
- `subtask`
- `duration` (positive number of days)

### Optional sequencing and dependency columns

- Task number aliases: `task_number`, `tasknumber`, `id`, `task_id`, `number`
- Dependency aliases: `depends_on`, `dependency`, `dependencies`, `predecessor`, `blocked_by`
  - For multiple dependencies, separate values with `|` or `;` (example: `3|4`).
- Consequential flag: `consequential` (`Yes` / `No`)
- Sort aliases: `order`, `sort`, `sequence`, `rank`
- Date output columns (auto-maintained by UI): `start_date`, `end_date`
- Any other additional columns are allowed and preserved in the CSV textbox.

## Example CSV

```csv
task_number,task,subtask,duration,depends_on,consequential,order
1,Discovery,Requirements,2,,No,1
2,Discovery,Sign-off,1,1,Yes,2
3,Build,Backend,4,2,No,3
4,Build,Frontend,3,2,No,4
5,QA,Testing,2,3|4,No,5
6,Release,Deployment,1,5,Yes,6
```

## Usage

1. Open `index.html` in your browser.
2. Pick a project start date.
3. Paste or edit CSV task data.
4. Click **Generate chart**.
5. Drag bars left/right to edit schedule dates.
6. The CSV data box is updated automatically with `start_date` and `end_date` for each task.

## License

This project is licensed under the MIT License.
