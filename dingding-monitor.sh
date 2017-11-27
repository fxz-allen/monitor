# File Name: dingding.py
# -*- coding:utf-8 -*-
import time,datetime
import json
import json
import urllib2
import math
import sys

def http_post(url, data):
    req = urllib2.Request(url)
    req.add_header('Content-Type', 'application/json')

    strdata = json.dumps(data)
    try:
        response = urllib2.urlopen(req, strdata)
    except Exception, e:
        return None
        print 'none'

    code = response.getcode()
    if code != 200:
        return None
        print 'none'

    resp = response.read()
    try:
        r = json.loads(resp)
    except Exception:
        return None
    return r

def send_dingding_message(content):
    webhook = 'https://oapi.dingtalk.com/robot/send?access_token=248f13e089ffbcb8b76280a96179016062691b7a9e9819c12e12c88fa67'
    data = {'msgtype':'markdown','markdown':{'title':'最右生产报警','text':content}}
    ret = http_post(webhook, data)

if __name__ == "__main__":
    send_dingding_message(sys.argv[1])
