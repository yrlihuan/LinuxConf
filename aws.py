from __future__ import absolute_import, print_function, unicode_literals, division

import argparse
import logging
import os
import sys
import subprocess
import time

import boto3

def list_instances(only_running=True):
  client = boto3.client('ec2')
  data = client.describe_instances()
  reservations = data['Reservations']

  ret = []
  for r_data in reservations:
    for d in r_data['Instances']:
      if only_running and d['State']['Name'] != 'running':
        continue

      instance_id = d['InstanceId']
      instance_launch_time = d['LaunchTime'].strftime('%Y-%m-%d_%H:%M:%S')
      instance_ip = d.get('PublicIpAddress', '--')
      instance_state = d['State']['Name']
      ret.append((instance_id, instance_launch_time, instance_ip, instance_state))


  ret.sort(key=lambda t: t[1])
  ret.reverse()
  return ret

def create_instance(launch_template):
  res = boto3.resource('ec2')
  res.create_instances(LaunchTemplate={'LaunchTemplateId': launch_template}, MaxCount=1, MinCount=1)

def terminate_instance(instance_id):
  client = boto3.client('ec2')
  client.terminate_instances(
    InstanceIds=[instance_id]
  )

def ping_test(ip, n=100):
  logger.info('Ping test: %s', ip)
  cmd = 'ping -c {} -i 0.2 -q {} | grep -oP \'\d+(?=% packet loss)\''.format(n, ip)
  output = subprocess.check_output(['bash', '-c', cmd]).decode()
  loss_rate = float(output) / 100.0
  logger.info('Packet loss rate: %.3f.', loss_rate)

  return loss_rate

def try_ssh_login(ip, remote_user='ubuntu', ssh_key='/home/huan/.ssh/yrlihuan06.pem'):
  ssh_options = '-i {} -o "StrictHostKeyChecking=no"'.format(ssh_key)
  remote_login = '{}@{}'.format(remote_user, ip)

  cmd = 'ssh {ssh_options} -o ConnectTimeout=5 {remote_login} true'.format(ssh_options=ssh_options, remote_login=remote_login)
  return os.system(cmd) == 0

def start_proxy(ip, remote_user='ubuntu', ssh_key='/home/huan/.ssh/yrlihuan06.pem', remote_port=8022, local_port=1887):
  ssh_options = '-o "StrictHostKeyChecking=no"'
  if ssh_key:
    ssh_options += ' -i {}'.format(ssh_key)

  cmds = []
  # shutdown ssh forwarding in local machine.
  cmds += [
    'bash -c "ps aux | grep \'ssh.*fNL.*0.0.0.0:{local_port}\' | grep -v grep | awk \'{{print \$2}}\' | xargs -r kill"'.format(local_port=local_port),
  ]

  # check if shadowsocks exists in remote. install it if not.
  remote_login = '{}@{}'.format(remote_user, ip)

  data = {
    'ssh_options': ssh_options,
    'remote_login': remote_login,
    'local_port': local_port,
    'remote_port': remote_port,
  }
  check_ssr = "ssh {ssh_options} {remote_login} [[ -f \$HOME/shadowsocksr/README.rst ]] && echo \"yes\" || echo \"no\"".format(**data)
  logger.info('Checking ssr installation in remote: %s', check_ssr)
  if subprocess.check_output(['bash', '-c', check_ssr]).strip().decode() == 'no':
    cmds += [
      'ssh {ssh_options} {remote_login} "sudo apt update"'.format(**data),
      'ssh {ssh_options} {remote_login} "sudo apt install -y python"'.format(**data),
      'scp {ssh_options} /home/huan/shadowsocksr.tar.gz {remote_login}:~/'.format(**data),
      'ssh {ssh_options} {remote_login} "tar zxvf shadowsocksr.tar.gz"'.format(**data),
    ]

  # restart ssserver in remote.
  cmds += [
    'ssh {ssh_options} {remote_login} "ps aux | grep server.py | grep -v grep | awk \'{{print \$2}}\' | xargs -r sudo kill"'.format(**data),
    'ssh {ssh_options} {remote_login} "sudo python shadowsocksr/shadowsocks/server.py -p {remote_port} -k lipp1983wh -m aes-256-cfb -O auth_sha1_v4 -o http_simple -d start"'.format(**data),
  ]

  # start ssh forwarding.
  cmds += [
    'bash -c "ssh {ssh_options} -fNL 0.0.0.0:{local_port}:localhost:{remote_port} {remote_login}"'.format(**data),
  ]

  for cmd in cmds:
    logger.info('Run: %s', cmd)
    os.system(cmd)

def main_info(args):
  for info in list_instances(args.only_running):
    instance_id, launch_time, ip, state = info
    logger.info('%s, %s, %s, %s', instance_id, launch_time, ip, state)

def main_standalone(args):
  start_proxy(ip=args.host, remote_user=args.user, ssh_key=args.key, remote_port=args.remote_port, local_port=args.local_port)

def main_auto_restart(args):
  info = list_instances(only_running=False)
  if len(info) != 0 and info[0][3] == 'running':
    instance_id, instance_launch_time, instance_ip, _ = info[0]

    loss_rate = ping_test(instance_ip, 100)
    if loss_rate > args.relaunch_threshold:
      logger.info('Try to re-launch instance!')
      terminate_instance(instance_id)

      wait_cnt = 0
      while wait_cnt < 120:
        time.sleep(1)
        wait_cnt += 1
        info = list_instances(only_running=False)
        if len(info) == 0 or info[0][3] == 'terminated':
          break

      if wait_cnt < 120:
        logger.info('Instance successfully terminated.')
      else:
        logger.error('Failed to terminate instance!')
        sys.exit(-1)
    else:
      logger.info('Instance ping test passed.')

  info = list_instances(only_running=True)
  if len(info) == 0:
    logger.info('Start launching instace.')
    create_instance(args.launch_template)

    wait_cnt = 0
    while wait_cnt < 60:
      time.sleep(5)
      wait_cnt += 1
      info = list_instances(only_running=True)
      if len(info) == 0:
        continue

      _, _, instance_ip, _ = info[0]
      if try_ssh_login(instance_ip):
        break

    if wait_cnt < 60:
      logger.info('Instance successfully launched.')
      time.sleep(60)
      logger.info('Wait for 60 seconds for instance to be setup by aws.')
    else:
      logger.error('Failed to launch instance!')
      sys.exit(-1)

  logger.info('Run setup scripts.')
  info = list_instances(only_running=True)
  instance_ip = info[0][2]

  start_proxy(instance_ip)

if __name__ == '__main__':
  logging.basicConfig(format='[%(asctime)s] %(message)s')
  logger = logging.getLogger('console')
  logger.setLevel(logging.DEBUG)

  parser = argparse.ArgumentParser()
  parser.add_argument('--launch_template', default='lt-09c2384f8a0ad2a96')

  subparsers = parser.add_subparsers()

  parser_info = subparsers.add_parser('info')
  parser_info.add_argument('--only_running', default=False, action='store_true')
  parser_info.set_defaults(func=main_info)

  # run close/create/setup.
  parser_auto_restart = subparsers.add_parser('auto_restart')
  parser_auto_restart.add_argument('--relaunch_threshold', type=float, default=0.2)
  parser_auto_restart.set_defaults(func=main_auto_restart)

  # setup proxy on a standalone server (e.g., aliyun server).
  parser_standalone = subparsers.add_parser('standalone')
  parser_standalone.add_argument('--host', required=True)
  parser_standalone.add_argument('--user', required=True)
  parser_standalone.add_argument('--key', required=True)
  parser_standalone.add_argument('--remote_port', type=int, default=8022)
  parser_standalone.add_argument('--local_port', type=int, default=1887)
  parser_standalone.set_defaults(func=main_standalone)

  args = parser.parse_args()
  args.func(args)
