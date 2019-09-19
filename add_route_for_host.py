from __future__ import absolute_import, print_function, unicode_literals, division

import argparse
import os
import re
import socket
import subprocess
import sys

def get_ip_for_host(host):
  expr_ip = re.compile('^[0-9]+.[0-9]+.[0-9]+.[0-9]+$')
  if expr_ip.match(host):
    return host

  return socket.gethostbyname(host)

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

def get_wifi_gateway(wifi_device):
  outputs = subprocess.check_output(['ip', 'route'])
  outputs = outputs.decode()
  '''
  default via 192.168.31.1 dev enp6s0 proto dhcp src 192.168.31.145 metric 100
  default via 192.168.43.1 dev wlx286c07970851 proto dhcp metric 600
  169.254.0.0/16 dev wlx286c07970851 scope link metric 1000
  192.168.31.0/24 dev enp6s0 proto kernel scope link src 192.168.31.145
  192.168.31.1 dev enp6s0 proto dhcp scope link src 192.168.31.145 metric 100
  192.168.43.0/24 dev wlx286c07970851 proto kernel scope link src 192.168.43.77 metric 600
  '''

  lines = outputs.split('\n')
  for l in lines:
    l = l.strip()
    if not l:
      continue

    parts = l.split(' ')
    if parts[0] == 'default' and parts[1] == 'via' and parts[3] == 'dev' and parts[4] == wifi_device:
      return parts[2]

  print('Do no know how to process output of \'ip route\'')
  sys.exit(-1)

def get_route_for_host(host_ip):
  outputs = subprocess.check_output(['ip', 'route'])
  outputs = outputs.decode()
  '''
  47.111.159.85 via 192.168.43.1 dev wlx286c07970851
  '''

  lines = outputs.split('\n')
  for l in lines:
    l = l.strip()
    parts = l.split(' ')
    if len(parts) == 5 and parts[0] == host_ip and parts[1] == 'via' and parts[3] == 'dev':
      return parts[4], parts[2]

  return '', ''

def set_route_for_host(host_ip, device, gateway):
  route_dev, route_gw = get_route_for_host(host_ip)
  print(route_dev, route_gw)
  if route_dev == device and route_gw == gateway:
    print('Route for host has been set.')
    return False

  if route_dev and route_gw:
    print('Remove current route for host: via {} dev {}... '.format(route_gw, route_dev), end='')
    subprocess.check_call(['sudo', 'ip', 'route', 'del', host_ip])
    print('Done')

  print('Set route for host: via {} dev {}... '.format(gateway, device), end='')
  subprocess.check_call(['sudo', 'ip', 'route', 'add', host_ip, 'via', gateway, 'dev', device])
  print('Done')

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('--host', default='eagle4.algo-trading.rocks')

  args = parser.parse_args()

  host_ip = get_ip_for_host(args.host)

  wifi_device, wifi_state, _ = get_wifi_status()
  if wifi_state != 'connected':
    print('Wifi is not connected!')
    sys.exit(-1)

  wifi_gw = get_wifi_gateway(wifi_device)
  #print(wifi_device, wifi_gw)

  set_route_for_host(host_ip, wifi_device, wifi_gw)

