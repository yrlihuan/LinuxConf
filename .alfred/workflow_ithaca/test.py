import os
import alfred
import logging

#s = os.popen('curl --socks5 localhost:1081 -s http://tomcat:5000/api/realtime_status').read()

opened_1080 = os.popen('ps aux | grep ssh.*1080 | grep -v grep').read()
opened_1081 = os.popen('ps aux | grep ssh.*1081 | grep -v grep').read()

cmds = []
ports = []
if opened_1080 == '':
  cmds.append('ssh -D 1080 -N -f -p 8022 tomcat.hvps.tk')
  ports.append('1080')

if opened_1081 == '':
  cmds.append('ssh -D 1081 -N -f eagle.hvps.tk')
  ports.append('1081')

if cmds:
  cmd = ' & '.join(cmds)
  alfred.log(cmd)
  os.system(cmd)
  alfred.log('p2')
  alfred.exit('proxies on port(s): ' + ', '.join(ports))
else:
  alfred.exit('all proxies are running')
