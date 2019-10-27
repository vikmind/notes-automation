#!/usr/bin/env python3
import os
import subprocess
import re
from datetime import date, timedelta

dir_path = os.path.normpath(os.path.dirname(os.path.realpath(__file__)) + '/../')
os.chdir(dir_path)
today = date.today()
current_monday = today - timedelta(days=today.weekday())
current_filename = current_monday.strftime('_Done_%Y-%m-%d_W%V.md')

subprocess.run(['git', 'pull'], check=True)
subprocess.run(['todoist', 's'], check=True)

data = subprocess.check_output(['todoist', '--csv', 'cl', '-f', 'today']).decode('utf-8').splitlines()

def taskToMd(line):
  return re.sub(r'^\d.+#"?([^,"]+)"?,*"?([^"]+)"?$', r'- [\1] \2', line)

file = open(current_filename, 'a')
file.write('\n'.join(list(map(taskToMd, data))))

if today.weekday() < 6:
  tomorrow = today + timedelta(days=1)
  file.write(tomorrow.strftime('\n\n#### %A, %B %d\n'))

file.close()

subprocess.run([os.environ['EDITOR'], current_filename])
