#!/usr/bin/env python3
import os
from datetime import date, timedelta

dir_path = os.path.normpath(os.path.dirname(os.path.realpath(__file__)) + '/../')
os.chdir(dir_path)
today = date.today()
current_monday = today - timedelta(days=today.weekday())

# Read and filter current week data
current_filename = current_monday.strftime('_Done_%Y-%m-%d_W%V.md')
file = open(current_filename, 'r')
lines = file.read().splitlines()
file.close()
def filterChores(line):
  return not '[Chores]' in line
filteredLines = list(filter(filterChores, lines))

# Put filtered data to current year archive
new_filename = current_monday.strftime('%Y/Done_%Y-%m-%d_W%V.md')
new_file = open(new_filename, 'w+')
new_file.write('\n'.join(filteredLines))
new_file.close()
print('{} is filtered and moved to {}'.format(current_filename, new_filename))

# Write current week headers to year report
year_filename = current_monday.strftime('%Y/Done_%Y.md')
year_file = open(year_filename, 'a')
idx = filteredLines.index(current_monday.strftime('#### %A, %B %d'))
year_file.write('\n' + '\n'.join(filteredLines[0:idx-1]) + '\n')
year_file.close()
print('{} is updated with new week'.format(year_filename))
