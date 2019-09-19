from __future__ import absolute_import, print_function, unicode_literals, division

import argparse
import os
import subprocess
import sys

def get_wifi_status():
  outputs = subprocess.check_output(['nmcli', '-t', 'device'])
  outputs = outputs.decode()
  '''
  DEVICE TYPE STATE CONNECTION
  wlx286c07970851 wifi connected XT1045
  enp6s0 ethernet unmanaged --
  lo loopback unmanaged --
  '''

  lines = outputs.split('\n')
  for l in lines:
    l = l.strip()
    if not l:
      continue

    device, t, state, connection = l.split(':')
    if state != 'unmanaged':
      return device, state, connection

  print('Failed to get wifi status! ' + outputs)
  sys.exit(-1)

def connect(connection):
  # connection needs to be added before running this. command to add connection is:
  #   sudo nmcli dev wifi connect XT1045 password cfb82465
  outputs = subprocess.check_output(['sudo', 'nmcli', 'connection', 'up', connection])
  outputs = outputs.decode()
  '''
  Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/6)
  '''

  if 'successfully' not in outputs:
    print('Failed to disconnect: ', outputs)
    sys.exit(-1)

def disconnect(dev):
  outputs = subprocess.check_output(['sudo', 'nmcli', 'device', 'disconnect', dev])
  outputs = outputs.decode()
  '''
  Device 'wlx286c07970851' successfully disconnected.
  '''

  if 'successfully' not in outputs:
    print('Failed to disconnect: ', outputs)
    sys.exit(-1)

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('--connection', default='XT1045')

  args = parser.parse_args()

  device, state, connection = get_wifi_status()
  if state == 'connected':
    if connection == args.connection:
      print('Already connected to {}.'.format(args.connection))
      sys.exit(0)
    else:
      print('Wifi is connected to {}. Disconnect it ...'.format(connection), end='')
      disconnect(device)
      device, state, connection = get_wifi_status()
      print('done')

  if state == 'disconnected':
    print('Try to connect to {} ...'.format(args.connection), end='')
    connect(args.connection)
    print('done')

