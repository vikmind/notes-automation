#!/usr/bin/env python3
import os
import subprocess
import json
import requests
from datetime import date, timedelta, datetime

dir_path = os.path.normpath(os.path.dirname(os.path.realpath(__file__)) + '/../')
os.chdir(dir_path)
today = date.today()
tomorrow = today + timedelta(days=1)
current_monday = today - timedelta(days=today.weekday())
current_filename = current_monday.strftime('_Done_%Y-%m-%d_W%V.md')

subprocess.run(['git', 'pull'], check=True)

token = json.loads(open(os.path.normpath(os.environ['HOME'] + '/.todoist.config.json'), 'r').read())['token']

tasks = requests.get(
    "https://api.todoist.com/api/v1/tasks/completed/by_completion_date",
    { "since": datetime(*today.timetuple()[:6]).isoformat(), "until": datetime(*tomorrow.timetuple()[:6]).isoformat() },
    headers={"Authorization": "Bearer " + token}
).json()['items']

projects = requests.get(
    "https://api.todoist.com/api/v1/projects",
    headers={"Authorization": "Bearer " + token}
).json()['results']

def taskToMd(item):
  return f"- [{projects[item['project_id']]['name']}] {item['content']}"

file = open(current_filename, 'a')
file.write('\n#### {}\n'.format(today.strftime('%A, %B %d')))
file.write('\n'.join(list(map(taskToMd, tasks))))

file.close()

subprocess.run([os.environ['EDITOR'], current_filename])
