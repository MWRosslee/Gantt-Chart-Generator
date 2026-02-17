# Gantt-Chart-Generator

A standalone **HTML Gantt Chart app** that runs fully in your browser and supports saving/loading plans as JSON.

## Features

- ✅ No backend required (single `index.html` file)
- ✅ Edit task rows directly in the page
- ✅ Per-task consequential scheduling logic
- ✅ Live Gantt SVG preview
- ✅ Save plan to `.json`
- ✅ Load plan from `.json`
- ✅ Export rendered chart to `.svg`

## Run

Open `index.html` in any modern browser.

If you prefer serving locally:

```bash
python3 -m http.server 8000
```

Then open: `http://localhost:8000`

## JSON format

Saved files use this structure:

```json
{
  "title": "Project Plan",
  "startDate": "2026-01-01",
  "rows": [
    {
      "task": "Planning",
      "subtask": "Requirements",
      "duration": 5,
      "consequential": "Yes"
    }
  ]
}
```

## Notes

- `consequential = "Yes"` chains subtasks within the **same task**.
- `consequential = "No"` starts that subtask at the global start date.

## License

MIT.
