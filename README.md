# Gantt-Chart-Generator

This repository contains:

1. A Python script for simple CSV-driven Gantt chart visualization.
2. VBA source modules for building an Excel XLAM add-in with project-management features.

## Python quick start

```bash
pip install pandas matplotlib
python main.py
```

## Excel XLAM add-in

See `excel_addin_README.md` for full setup and workflow.

Core features in the VBA add-in:

- Hierarchical WBS (tasks / subtasks / sub-subtasks)
- Multi-project consolidation
- Day/Week/Month timeline rendering across years
- Resource and person allocation fields
- Project status and resource-load reporting

VBA source files are under:

- `excel_addin/VBA/modUtils.bas`
- `excel_addin/VBA/modGanttAddIn.bas`
- `excel_addin/VBA/modGanttReporting.bas`
- `excel_addin/VBA/modGanttRibbon.bas`
