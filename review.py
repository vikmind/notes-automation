#!/usr/bin/env python3
import os
import subprocess
import json
import requests
from datetime import date, timedelta, datetime

dir_path = os.path.normpath(os.path.dirname(os.path.realpath(__file__)) + '/../')
os.chdir(dir_path)
today = date.today()
current_monday = today - timedelta(days=today.weekday())
current_filename = current_monday.strftime('_Done_%Y-%m-%d_W%V.md')

subprocess.run(['git', 'pull'], check=True)

token = json.loads(open(os.path.normpath(os.environ['HOME'] + '/.todoist.config.json'), 'r').read())['token']

data = requests.get(
    "https://api.todoist.com/sync/v9/completed/get_all",
    { "since": datetime(*today.timetuple()[:6]).isoformat() },
    headers={"Authorization": "Bearer " + token}
).json()

items = data['items']
projects = data['projects']

def taskToMd(item):
  return f"- [{projects[item['project_id']]['name']}] {item['content']}"

file = open(current_filename, 'a')
file.write('\n'.join(list(map(taskToMd, items))))

if today.weekday() < 6:
  tomorrow = today + timedelta(days=1)
  file.write(tomorrow.strftime('\n\n#### %A, %B %d\n'))

file.close()

subprocess.run([os.environ['EDITOR'], current_filename])
