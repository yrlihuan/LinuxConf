# -*- encoding=utf8 -*-

import yaml
import json
import os.path
import urllib.request
import urllib.parse

import logging

CURDIR = os.path.dirname(__file__)
CONFIG_FILE = os.path.join(CURDIR, 'configs', 'wxpusher.yaml')

WX_ENABLED = True
if not os.path.exists(CONFIG_FILE):
  print('Cannot find config {}'.format(CONFIG_FILE))
  WX_ENABLED = False

CONFIG = yaml.load(open(CONFIG_FILE))
UID = CONFIG['user_id']
TOKEN = CONFIG['token']

def wx_send(msg):
  if not WX_ENABLED:
    return False

  data = {
    'appToken': TOKEN,
    'content': msg,
    'uid': UID
  }

  try:
    data = urllib.parse.urlencode(data)
    url = 'http://wxpusher.zjiecode.com/api/send/message/?{}'.format(data)
    response = urllib.request.urlopen(url)

    ret = json.loads(response.read())
    return ret['success']
  except:
    return False

def install_logging_handler(logger, fmt=None, lvl=logging.WARNING):
  wx_handler = WXHandler()
  wx_handler.setLevel(lvl)

  if fmt:
    if not isinstance(fmt, logging.Formatter) and isinstance(fmt, str):
      fmt = logging.Formatter(fmt)
    else:
      raise RuntimeError('Unknown formater type: {}'.format(fmt))

    wx_handler.setFormatter(fmt)

  logger.addHandler(wx_handler)

class WXHandler(logging.Handler):
  def emit(self, record):
    wx_send(self.format(record))

__all__ = ['wx_send', 'install_logging_handler']

if __name__ == '__main__':
  assert wx_send('send_msg test.'), 'Failed to send msg.'
  assert wx_send('send_msg 中文测试'), 'Failed to send msg.'

