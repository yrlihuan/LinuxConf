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

hostname = 'kernel-%s.algo-trading.rocks' % sys.argv[1]
hostalias = sys.argv[1]
run('nc -z %s 22' % hostname)
run("ssh huan@%s 'mkdir -p alpha/build/out/bin && mkdir -p alpha/build/out/lib' && mkdir -p configs" % hostalias)
run("rsync -avz --include='*' ~/configs/* huan@%s:~/configs" % hostalias)
run("rsync -avz --exclude='.git/*' --exclude='stock_minute_ct' --include='*' ~/alphadata/*  huan@%s:~/alphadata" % hostalias)
run("rsync -avz --include='*alpha.so' --exclude='*' ~/alpha/build/out/lib/*  huan@%s:~/notebooks" % hostalias)
run("rsync -avz --include='alpha_accounting' --exclude='*'  ~/alpha/build/out/bin/* huan@%s:~/alpha/build/out/bin" % hostalias)
