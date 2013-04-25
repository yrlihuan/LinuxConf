#!/usr/bin/env bash

# ----------------------------------------------
# variables
# ----------------------------------------------

# ----------------------------------------------
# install development tools (git, ruby, etc)
# ----------------------------------------------

# to run "sudo" without prompting password,
# modify /etc/sudoers, add the following line
# %sudo ALL=(ALL) NOPASSWD: NOPASSWD: ALL

sudo apt-get update

sudo apt-get install -y git-core
sudo apt-get install -y ruby
sudo apt-get install -y rubygems
sudo apt-get install -y vim
sudo apt-get install -y screen
sudo apt-get install -y host
sudo apt-get install -y sysbench
sudo apt-get install -y ntp

sudo apt-get install -y python-yaml
sudo apt-get install -y python-numpy
sudo gem install json

git config --global user.email "yrlihuan@gmail.com"
git config --global user.name "Huan Li"

# ----------------------------------------------
# setup ssh
# ----------------------------------------------

SSH_HOME=$HOME/.ssh

mkdir $SSH_HOME

# add authorized keys (me622)
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsyqvf+IQr8NvUFWPutNN6PMftGEqAWJAtBbVaLszgmuLPUkItfX9OKGveaFoTISxwoAKSQ5Qy5xfDnTu23PIkoSnu6JjPcdT1qPdkLMNw3EImROLPRuJ+SpzQpvpAIbfVA1YUDlBsVnezFqNmufGi3GQdOFjciOW4N5nXWpK7dBgtEFIUlpfIiWJDwYWvrUPLnAcX1zJ6fp9t3xHU1anRM1esy9cLEMuf0qFUiA+uoHQ1Js1nbMABfl3nyYWyTIA0E9+PaOESuVFLxbbzxqXczsEe7rZ8M6EDk1ElGtLrqhFMDL1Y+OkKe779z92v0U91aFgXGHJX4D5xxUS29ZFV" >> $SSH_HOME/authorized_keys

# add known hosts (github)
echo "|1|8jvxbw0MZioRfu2cO6qWBlub6PY=|TEZV42i2eTFFczTPvcEox0oiXAo= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> $SSH_HOME/known_hosts

# generate rsa key, adding to github
echo "--------------------------------------------------------------------------------------"
echo "The following steps needs operate manually. Continue when finished"
echo "1. Run ssh-keygen"
echo "2. Login your github account. Add the generated public key to auto authorized list"
echo "3. When finished, press 'y'"

read -p "when finished, type 'y' and enter: " finished
if [ "$finished" == 'y' ]; then
  echo "continue..."
else
  echo "user canceled"
  exit
fi

# ----------------------------------------------
# pull repos
# ----------------------------------------------

USER_GITHUB=yrlihuan
WORKSPACE=$HOME/workspace

mkdir $WORKSPACE
git clone git@github.com:$USER_GITHUB/LinuxConf.git $HOME/LinuxConf
git clone git@github.com:$USER_GITHUB/pyctp.git $WORKSPACE/pyctp
git clone git@github.com:$USER_GITHUB/Hermes.git $WORKSPACE/Hermes
git clone git@github.com:$USER_GITHUB/Scripts.git $WORKSPACE/scripts

git clone eagle.hvps.tk:/home/git/Ithaca.git $WORKSPACE/Ithaca
git clone eagle.hvps.tk:/home/git/qstk.git $WORKSPACE/qstk

# ----------------------------------------------
# setup working env
# ----------------------------------------------

ln -s $HOME/LinuxConf/.vim $HOME/.vim
ln -s $HOME/LinuxConf/.vimrc $HOME/.vimrc
ln -s $HOME/LinuxConf/.screenrc $HOME/.screenrc
ln -s $HOME/LinuxConf/.env $HOME/.env
ln -s $HOME/LinuxConf/.bashrc $HOME/.bashrc
ln -s $HOME/LinuxConf/.bashrc $HOME/.profile
ln -s $HOME/LinuxConf/.git-completion.bash $HOME/.git-completion.bash

# ---------------------------------------------
# Securites
# ---------------------------------------------

# disable ssh access
(crontab -l ; echo "*/5 * * * * $WORKSPACE/scripts/restrict_ssh_access.rb") | crontab -
(crontab -l ; echo "* * * * * . ~/.env; ~/workspace/Ithaca/tools/daemon/daemon.py") | crontab -

