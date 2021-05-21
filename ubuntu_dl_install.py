from __future__ import print_function

import sys
import os
import subprocess

USER = 'huan'

def usage():
  return '''python ubuntu_dl_install.py hostname|ip
'''

def main(host):
  sync_files = [
    "LinuxConf",
    ".pip",
  ]
  remote_commands = [
    "ls /home/huan",
    "ln -s -f LinuxConf/.git-completion.bash",
    "ln -s -f LinuxConf/.vim",
    "ln -s -f LinuxConf/.vimrc",
    "ln -s -f LinuxConf/.profile",
    "ln -s -f LinuxConf/.bashrc",
    "ln -s -f LinuxConf/.env",
    "sudo apt-get install -y ruby",
    #"sudo pip install sklearn",
    #"sudo pip install matplotlib",
    #"sudo pip install seaborn",
    #"sudo pip install plotly",
    #"sudo pip install qgrid",
    #"sudo pip install keras",
  ]

  commands = []
  for path in sync_files:
    if not path.startswith('/') and not path.startswith('~'):
      path = '/home/%s/%s' % (USER, path)

    commands.append('rsync -avz %s %s:%s' % (path, host, os.path.dirname(path)))

  for c in remote_commands:
    commands.append('ssh %s "%s"' % (host, c))

  for command in commands:
    print(command, '... ', end='')
    errcode = os.system(command + '> /dev/null')
    if errcode != 0:
      print('Failed!')
      break
    else:
      print('Success!')

if __name__ == '__main__':
  if len(sys.argv) != 2:
    print(usage())
    sys.exit(-1)

  main(*sys.argv[1:])
