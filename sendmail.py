#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys
import smtplib
from email.mime.text import MIMEText
from email.header import Header

mail_host="smtp.exmail.qq.com"
mail_user="al@xiaochuankeji.cn"
mail_pass=""


sender = 'alert@xiaochuankeji.cn'
'''
'''
receivers = ['fengxinzhi2014@xiaochuankeji.cn']


text="在%s ，%s" %(sys.argv[1],sys.argv[2])
message = MIMEText(text, 'plain', 'utf-8')
message['From'] = Header("最右 监控系统 报警邮件", 'utf-8')
message['To'] =  Header("运维", 'utf-8')

subject = '最右 监控系统 报警邮件'
message['Subject'] = Header(subject, 'utf-8')


try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)
    smtpObj.login(mail_user,mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print "邮件发送成功"
except smtplib.SMTPException:
    print "Error: 无法发送邮件"
