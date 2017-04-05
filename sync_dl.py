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
run('ssh -q %s exit' % hostname)
run("rsync -avz --exclude='*batch*ckpt' --include='*.ckpt' --include='*.pkl' --exclude='*' %s:~/notebooks/* ~/notebooks/checkpoints" % hostname)
