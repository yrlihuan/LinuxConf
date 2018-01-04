import sys
import os

def run(cmd):
  print cmd
  if os.system(cmd):
    print 'failed!'
    sys.exit(-1)

if len(sys.argv) < 2:
  print 'Need to specify server name, e.g., dl1'
  sys.exit(-1)

hostname = sys.argv[1]
run('scp ~/.ssh/id_rsa_market_data %s:~/.ssh/id_rsa_market_data' % hostname)
run('ssh %s "mkdir -p ~/alphadata/stock_minute_ct"' % hostname)
run('ssh %s \'rsync -avz -e "ssh -i ~/.ssh/id_rsa_market_data" rsync_user@rsync.algo-trading.rocks:/var/rsync/stock_minute_ct/* ~/alphadata/stock_minute_ct\'' % hostname)
