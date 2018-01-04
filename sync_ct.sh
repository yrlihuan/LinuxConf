#!/bin/bash
rsync -avz --exclude='*.lock' --include='*' dl1:~/notebooks/ctable_gen/ ~/notebooks/ctable/
rsync -avz --exclude='*.lock' --include='*' ~/notebooks/ctable/ dl1:~/notebooks/ctable/
rsync -avz --exclude='*.lock' --include='*' ~/notebooks/ctable/ dl2:~/notebooks/ctable/
rsync -avz --exclude='*.lock' --include='*' ~/notebooks/ctable/ dl3:~/notebooks/ctable/
rsync -avz --exclude='*.lock' --include='*' ~/notebooks/ctable/ dl4:~/notebooks/ctable/
rsync -avz --exclude='*.lock' --include='*' ~/notebooks/ctable/ dl5:~/notebooks/ctable/
rsync -avz --exclude='*.lock' --include='*' ~/notebooks/ctable/ dl6:~/notebooks/ctable/
