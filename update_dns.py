#!env python
# -*- coding: utf-8 -*-

import requests
import json
import time
import random

config = {
    "ID": 88044,                                # 填写你自己的API Token ID
    "TokenID": "4d0820dfd73e2a3c916c5016efa90c1f",      # 填写你自己的API Token
    "domains":{
        "algo-trading.rocks": ['ln']        # 填写需要更新的域名及对应的记录
    },
    "delay": 10                                 # 检查时间
}


Action_DomainList = 'Domain.List'
Action_RecordList = 'Record.List'
Action_RecordModify = 'Record.Modify'

ip_cache = {
    'refresh_time': 0,
    'cached_ip': '0.0.0.0'
}


def get_local_ip():
    get_ip_url = [
        'http://ip.6655.com/ip.aspx',
        'http://members.3322.org/dyndns/getip',
        'http://icanhazip.com/',
        'http://ident.me/',
        'http://ipecho.net/plain',
        'http://whatismyip.akamai.com/',
        'http://myip.dnsomatic.com/',
    ]
    err_counter = 0

    while err_counter < 10:
        try:
            uri = get_ip_url[random.randint(0, len(get_ip_url)-1)]
            r = requests.get(uri)
            return r.text
        except requests.RequestException:
            err_counter += 1
            time.sleep(1)
            continue

    raise Exception('Cannot get local ip address.')


def update_local_ip():
    ip = get_local_ip()
    print('ip:', ip)
    if ip != ip_cache['cached_ip']:
        ip_cache['cached_ip'] = ip
        ip_cache['refresh_time'] = time.time()
        return True
    else:
        return False


class DnsPod():
    base_uri = 'https://dnsapi.cn'
    user_agent = 'DDNSPOD Update Agent/0.0.1 (lijyigac@gmail.com)'
    format = 'json'
    lang = 'cn'
    success_code = ["1"]

    def invoke(self, action, post_data=None):
        uri = self.base_uri + '/' +action
        if post_data is None:
            post_data = dict()
        else:
            assert isinstance(post_data, dict)
        headers = {
            'Host': 'dnsapi.cn',
            'User-Agent': self.user_agent,
            "Content-type": "application/x-www-form-urlencoded",
            "Accept": "text/json",
        }
        post_data['login_token'] = str(config['ID']) + ',' + config['TokenID']
        post_data['format'] = self.format
        r = requests.post(url=uri, data=post_data, headers=headers)
        return json.loads(r.text, encoding='utf-8')

    def __init__(self, with_config):
        self.config = with_config

    def get_domains(self):
        ret = self.invoke(Action_DomainList)
        assert ret['status']['code'] in self.success_code
        if len(ret['domains'])>0:
            return ret['domains']
        result = list()
        for domain in ret['domains']:
            if domain['name'] in config['domains']:
                result.append(domain)

    def get_records(self, domain_id):
        ret = self.invoke(Action_RecordList, {'domain_id': domain_id})
        assert ret['status']['code'] in self.success_code
        if len(ret['records'])>0:
            return ret['records']
        else:
            return None

    def update_record(self, domain_id, record_id ,record_name ,new_ip=None):
        if new_ip is None:
            new_ip = ip_cache['cached_ip']
        ret = self.invoke(Action_RecordModify, {
            'domain_id': domain_id,
            'record_id': record_id,
            'value': new_ip,
            'record_type': 'A',
            'record_line': u'默认',
            'sub_domain': record_name,
        })

        print(ret)
        assert ret['status']['code'] in self.success_code


if __name__ == '__main__':
    if update_local_ip():
        x = DnsPod(config)
        for domain in x.get_domains():
            records = x.get_records(domain_id=int(domain['id']))
            for record in records:
                if record['name'] in config['domains'][domain['name']]:
                    print(record)
                    x.update_record(domain['id'], record['id'], record['name'])

