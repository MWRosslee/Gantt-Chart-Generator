import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime, timedelta

# Load data from the CSV
df = pd.read_csv('tasks.csv')

# Ask for start date
start_date = input("Please enter the start date in YYYY-MM-DD format: ")
start_date = datetime.strptime(start_date, "%Y-%m-%d")

# Prepare data for the Gantt chart
gantt_data = []
current_date = start_date

for i, row in df.iterrows():
    start = current_date
    end = start + timedelta(days=row['duration'])
    gantt_data.append((row['task'], row['subtask'], start, end))
    if row['consequential'] == 'Yes':
        current_date = end

# Create Gantt chart
fig, ax = plt.subplots()
for task, subtask, start, end in gantt_data:
    ax.barh(task + ' - ' + subtask, end - start, left=start, align='center')

# Set the title
plt.title('Project Plan')

# Set the x-axis to display months
ax.xaxis_date()
ax.xaxis.set_major_locator(mdates.MonthLocator())
ax.xaxis.set_minor_locator(mdates.DayLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m'))
plt.show()
