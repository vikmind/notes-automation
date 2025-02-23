#!/usr/bin/env python3
import os
from datetime import date, timedelta

dir_path = os.path.normpath(os.path.dirname(os.path.realpath(__file__)) + '/../')
os.chdir(dir_path)
today = date.today()

next_monday = today + timedelta(days=7-today.weekday())
next_sunday = today + timedelta(days=13-today.weekday())

# Write header
new_file_name = '_Done_{}.md'.format(next_monday.strftime('%Y-%m-%d_W%V'))
template = [
    '### {} week {}'.format(next_monday.strftime('%Y'), next_monday.strftime('%V')),
    '#### {} - {}'.format(next_monday.strftime('%d.%m'), next_sunday.strftime('%d.%m')),
    '* * *',
    'Project|Goal|Mon|Tue|Wed|Thu|Fri|Sat|Sun|All|Complete?',
    '---|---|---|---|---|---|---|---|---|---|---\n'
    ]
new_week_file = open(new_file_name, 'w+')
new_week_file.write('\n'.join(template))

# Read focus.txt file
focus_file = open('focus.txt', 'r')
focus_lines = focus_file.read().splitlines()
focus_file.close()

# Prepare headers with goals
count = 0
longest_project = 0
longest_goal = 0
projects = []
goals = []
for line in focus_lines:
  count += 1
  div3 = count % 3
  if div3 == 1:
    if len(line) > longest_project: longest_project = len(line)
    projects.append(line)
  if div3 == 2:
    if len(line) > longest_goal: longest_goal = len(line)
    goals.append(line)

# Write headers with goals
for idx, project in enumerate(projects):
  line = '{} | {} |-|-|-|-|-|-|-|**0.0**|**N**'.format(
      project + ' '*(longest_project - len(project)),
      goals[idx] + ' '*(longest_goal - len(goals[idx])))
  new_week_file.write(line + '\n')

new_week_file.close()

print('File {} created'.format(new_file_name))
