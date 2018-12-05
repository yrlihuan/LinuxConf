#!/usr/bin/env python
# -*- encoding=utf-8 -*-

import argparse
import datetime as dt
import sys
import os.path
import git

TRADERS_DIR = os.path.join(os.environ['HOME'], 'traders')
T0_ACCOUNTING_DIR = '/home/notebook-user/notebooks/t0_accounting'

def main(args):
  date_str = args.date

  # copy t0 positions.
  ssh_keyfile = os.path.join(os.environ['HOME'], '.ssh/id_rsa_t0')
  src_file = 'rsync_t0@rsync.algo-trading.rocks:/home/rsync_t0/position_t0/%s.txt' % date_str
  accounting_file = os.path.join(T0_ACCOUNTING_DIR, 'traders', 't0', date_str + '.txt')
  traders_file = os.path.join(TRADERS_DIR, 'strategies', 't0', date_str + '.txt')

  cmd = "sudo rsync -avz -e 'ssh -i %s' %s %s && sudo chown notebook-user:notebook-user %s" % (ssh_keyfile, src_file, accounting_file, accounting_file)
  print cmd
  os.system(cmd)

  cmd = "sudo cp %s %s && sudo chown huan:huan %s && chmod -x %s" % (accounting_file, traders_file, traders_file, traders_file)
  print cmd
  os.system(cmd)

  # fix portfolio file.
  if not os.path.exists(traders_file):
    print 'skipping %s' % traders_file
    return

  with open(traders_file) as fin:
    contents = fin.read()

  contents = contents.decode('gb18030')
  lines = contents.split('\n')
  out_lines = []
  total_weights = 0.0
  stock_weights = {}
  for i in xrange(len(lines)):
    l = lines[i].strip()
    if i == 0:
      if '=' in l and u'现金' in l:
        out_lines.append(l.replace(u'现金', u'总资产'))
      else:
        out_lines.append(l)
    elif i == 1:
      out_lines.append(u'沪深300对冲比例=0.5')
    elif i == 2:
      out_lines.append(u'中证500对冲比例=0.5')
      out_lines.append(u'target=position_want')
    else:
      if 'SZ39910' not in l and l != '':
        s, w, _ = l.split(',')
        total_weights += float(w)
        stock_weights[s] = float(w)

  for s, w in stock_weights.iteritems():
    out_lines.append(u'%s,%.10f,' % (s, w / total_weights))

  out_contents = u'\n'.join(out_lines)
  with open(traders_file, 'w') as fout:
    fout.write(out_contents.encode('gb18030'))

  # Push to traders repo.
  print 'Creating commit...  ',
  repo = git.Repo(TRADERS_DIR)
  repo.git.add(traders_file)
  if repo.is_dirty(index=False, working_tree=True, untracked_files=False):
    repo.git.reset('HEAD', portfolio_relative_path)
    print 'Index should be clean before updating [working tree not clean].'
    sys.exit(-1)

  if not repo.is_dirty(index=True, working_tree=False, untracked_files=False):
    print 'Portfolio file is not changed.'
    sys.exit(-1)

  repo.git.commit('-m', 'Update portfolio for t0 (%s).' % (args.date))
  print 'done!'

  print 'Submitting...  ',
  repo.git.svn('dcommit')
  print 'done!'

  repo.git.svn('rebase')

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('-d', '--date', default=dt.datetime.today().strftime('%Y%m%d'))

  args = parser.parse_args()
  main(args)

