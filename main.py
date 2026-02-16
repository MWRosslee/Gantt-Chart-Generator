import argparse
import csv
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from xml.sax.saxutils import escape

REQUIRED_COLUMNS = {"task", "subtask", "duration", "consequential"}


@dataclass
class TaskRow:
    task: str
    subtask: str
    duration_days: int
    consequential: bool


@dataclass
class GanttRow:
    task: str
    subtask: str
    start: datetime
    end: datetime


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a Gantt chart from a CSV file.")
    parser.add_argument("--csv", default="tasks.csv", help="Path to the CSV file with task data")
    parser.add_argument("--start-date", help="Project start date in YYYY-MM-DD format")
    parser.add_argument("--title", default="Project Plan", help="Chart title")
    parser.add_argument(
        "--output",
        help="Optional output path. Use .png for matplotlib output or .svg for no-dependency preview.",
    )
    return parser.parse_args()


def parse_start_date(start_date_text: str | None) -> datetime:
    if not start_date_text:
        start_date_text = input("Please enter the start date in YYYY-MM-DD format: ")
    try:
        return datetime.strptime(start_date_text, "%Y-%m-%d")
    except ValueError as exc:
        raise ValueError("Start date must be in YYYY-MM-DD format.") from exc


def load_tasks(csv_path: str) -> list[TaskRow]:
    with open(csv_path, newline="", encoding="utf-8-sig") as csv_file:
        reader = csv.DictReader(csv_file)
        if reader.fieldnames is None:
            raise ValueError("CSV is empty.")

        missing = REQUIRED_COLUMNS - set(reader.fieldnames)
        if missing:
            cols = ", ".join(sorted(missing))
            raise ValueError(f"CSV is missing required columns: {cols}")

        task_rows: list[TaskRow] = []
        for row_index, raw_row in enumerate(reader, start=2):
            task = (raw_row.get("task") or "").strip()
            subtask = (raw_row.get("subtask") or "").strip()
            duration_raw = (raw_row.get("duration") or "").strip()
            consequential_raw = (raw_row.get("consequential") or "").strip().lower()

            if not task or not subtask:
                raise ValueError(f"task and subtask are required (CSV row {row_index}).")

            try:
                duration = int(float(duration_raw))
            except ValueError as exc:
                raise ValueError(f"duration must be a number (CSV row {row_index}).") from exc

            if duration <= 0:
                raise ValueError(f"duration must be > 0 (CSV row {row_index}).")

            if consequential_raw not in {"yes", "no"}:
                raise ValueError(
                    "consequential must be Yes/No "
                    f"(CSV row {row_index}, got '{raw_row.get('consequential')}')."
                )

            task_rows.append(
                TaskRow(
                    task=task,
                    subtask=subtask,
                    duration_days=duration,
                    consequential=consequential_raw == "yes",
                )
            )

        return task_rows


def build_gantt_rows(tasks: list[TaskRow], start_date: datetime) -> list[GanttRow]:
    rows: list[GanttRow] = []
    task_latest_end: dict[str, datetime] = {}

    for task_row in tasks:
        if task_row.consequential:
            start = task_latest_end.get(task_row.task, start_date)
        else:
            start = start_date

        end = start + timedelta(days=task_row.duration_days)
        task_latest_end[task_row.task] = end
        rows.append(GanttRow(task=task_row.task, subtask=task_row.subtask, start=start, end=end))

    return rows


def render_svg_preview(gantt_rows: list[GanttRow], title: str, output_path: str) -> None:
    if not gantt_rows:
        raise ValueError("No rows to render.")

    min_date = min(row.start for row in gantt_rows)
    max_date = max(row.end for row in gantt_rows)
    total_days = max((max_date - min_date).days, 1)

    left_margin = 260
    top_margin = 70
    row_height = 28
    chart_width = 1000
    bar_height = 16
    width = left_margin + chart_width + 50
    height = top_margin + len(gantt_rows) * row_height + 70

    def day_to_x(value: datetime) -> float:
        return left_margin + ((value - min_date).days / total_days) * chart_width

    lines: list[str] = []
    lines.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}">')
    lines.append('<rect width="100%" height="100%" fill="#ffffff"/>')
    lines.append(f'<text x="20" y="35" font-size="24" font-family="Arial">{escape(title)}</text>')

    # Weekly guide lines
    for day in range(0, total_days + 1, 7):
        marker = min_date + timedelta(days=day)
        x = day_to_x(marker)
        lines.append(
            f'<line x1="{x:.2f}" y1="50" x2="{x:.2f}" y2="{height - 35}" '
            'stroke="#e6e6e6" stroke-width="1"/>'
        )
        lines.append(
            f'<text x="{x + 2:.2f}" y="60" font-size="10" fill="#666" font-family="Arial">'
            f'{escape(marker.strftime("%Y-%m-%d"))}</text>'
        )

    for idx, row in enumerate(gantt_rows):
        y = top_margin + idx * row_height
        bar_x = day_to_x(row.start)
        bar_w = max(day_to_x(row.end) - bar_x, 2)
        label = f"{row.task} - {row.subtask}"

        lines.append(
            f'<text x="20" y="{y + 12}" font-size="12" font-family="Arial">{escape(label)}</text>'
        )
        lines.append(
            f'<rect x="{bar_x:.2f}" y="{y}" width="{bar_w:.2f}" height="{bar_height}" '
            'fill="#4f81bd" rx="4" ry="4"/>'
        )

    lines.append("</svg>")
    out = Path(output_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines), encoding="utf-8-sig")
    print(f"Saved SVG preview to: {out}")


def draw_with_matplotlib(gantt_rows: list[GanttRow], title: str, output_path: str | None) -> bool:
    try:
        import matplotlib.dates as mdates
        import matplotlib.pyplot as plt
    except ModuleNotFoundError:
        return False

    fig, ax = plt.subplots(figsize=(11, 6))
    for row in gantt_rows:
        ax.barh(f"{row.task} - {row.subtask}", row.end - row.start, left=row.start, align="center")

    ax.set_title(title)
    ax.set_xlabel("Date")
    ax.set_ylabel("Task / Subtask")
    ax.xaxis_date()
    ax.xaxis.set_major_locator(mdates.MonthLocator())
    ax.xaxis.set_minor_locator(mdates.DayLocator(interval=7))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y-%m"))
    fig.autofmt_xdate()
    fig.tight_layout()

    if output_path and Path(output_path).suffix.lower() != ".svg":
        out = Path(output_path)
        out.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(out, dpi=150)
        print(f"Saved chart preview to: {out}")

    plt.show()
    return True


def main() -> None:
    args = parse_args()
    start_date = parse_start_date(args.start_date)
    tasks = load_tasks(args.csv)
    gantt_rows = build_gantt_rows(tasks, start_date)

    # If user asks for SVG, always provide no-dependency preview.
    if args.output and Path(args.output).suffix.lower() == ".svg":
        render_svg_preview(gantt_rows, args.title, args.output)
        return

    used_matplotlib = draw_with_matplotlib(gantt_rows, args.title, args.output)
    if not used_matplotlib:
        fallback_output = args.output or "artifacts/gantt-preview.svg"
        if Path(fallback_output).suffix.lower() != ".svg":
            fallback_output = str(Path(fallback_output).with_suffix(".svg"))
        render_svg_preview(gantt_rows, args.title, fallback_output)
        print("matplotlib is not installed; generated SVG preview instead.")


if __name__ == "__main__":
    main()
