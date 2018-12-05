#!/usr/bin/env python

import datetime as dt
import os
import os.path
import re
import sys

def usage():
  return '''python clear_history_in_dir_v2.py dir_to_clear keep_recent_n keep_every_n
'''

def main(dir_to_clear, recent_n, every_n):
  files = os.listdir(dir_to_clear)
  p = re.compile('.*(20[0-9]{6})[^0-9]')

  files_with_date = []
  for f in files:
    m = p.match(f)
    if m:
      files_with_date.append((m.groups()[0], f))

  if len(files_with_date) == 0:
    print 'No files with date in filename!'
    sys.exit(-1)

  files_with_date.sort(key=lambda t: t[0])
  d0 = dt.datetime.strptime(files_with_date[0][0], '%Y%m%d')
  last_range_kept = -1

  actions = []
  for i, t in enumerate(files_with_date):
    date_str, f = t
    d = dt.datetime.strptime(date_str, '%Y%m%d')
    range_ind = (d - d0).days / every_n
    if range_ind != last_range_kept:
      last_range_kept = range_ind
      actions.append((f, 'keep'))
      continue

    if len(files_with_date) - i <= recent_n:
      actions.append((f, 'keep'))
    else:
      actions.append((f, 'delete'))

  for f, action in actions:
    print f, action
    if action == 'delete':
      path = os.path.join(dir_to_clear, f)
      cmd = 'rm %s' % path
      os.system(cmd)

if __name__ == '__main__':
  if len(sys.argv) != 4:
    print usage()
    sys.exit(-1)

  dir_to_clear = sys.argv[1]
  recent_n = int(sys.argv[2])
  every_n = int(sys.argv[3])

  main(dir_to_clear, recent_n, every_n)

