# Gantt-Chart-Generator
This Python script generates a Gantt chart for project tasks and their sub-tasks using data from a CSV file. 


Project: Gantt Chart Generator

# Description
This Python script generates a Gantt chart for project tasks and their sub-tasks using data from a CSV file. It's an easy way to visualize project timelines, task durations, and the sequence of tasks. The Gantt chart helps project managers to schedule tasks, manage resources more effectively, and monitor the progress of the project.

The script uses the pandas library to read and process data from the CSV file, and the matplotlib library to create the Gantt chart.

# CSV File Structure
The CSV file used as input should be structured as follows:

task: The name of the main task
subtask: The name of the sub-task
duration: The duration of the sub-task in days
consequential: Indicates if a sub-task should start immediately after the previous sub-task. This should be 'Yes' or 'No'
Here is an example of a CSV file:


Copy code
task,subtask,duration,consequential
"Main Task 1","Sub Task 1",3,Yes
"Main Task 1","Sub Task 2",4,Yes
"Main Task 2","Sub Task 1",2,No
"Main Task 2","Sub Task 2",1,Yes
"Main Task 3","Sub Task 1",2,Yes

Usage
Install the necessary Python packages if you haven't already:
Copy code
pip install pandas matplotlib
Run the Python script:
Copy code
python gantt_chart.py
The script will prompt you to enter the start date of the project in YYYY-MM-DD format.
The script will then read the tasks from the CSV file, prepare the data for the Gantt chart, and display the Gantt chart.
License
This project is licensed under the terms of the MIT license.
