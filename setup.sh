#!/bin/bash -e
# Parts from the homeshick wiki, specifically
# https://gist.github.com/andsens/2913223

# Paste this into ssh
# curl -sL https://gist.github.com/andsens/2913223/raw/bootstrap_homeshick.sh | tar -xzO | /bin/bash -ex
# When forking, you can get the URL from the raw (<>) button.

#./gnome-terminal.xoria256.sh

# Make sure git is going to point where I want it to.
CONFIGDIR="$HOME/.config/nalabelle"
CONFIGFILE="gitscripts.conf"
HOST=`hostname -d`
USER=`whoami`
LOCALSRC=`pwd`
LOCALSRC=$LOCALSRC/src
. $CONFIGDIR/$CONFIGFILE

if [ ! -f $CONFIGDIR/$CONFIGFILE ]; then
  echo "Give me the server to grab your bin/dotfiles."

  read -e -p "Domain for your git server: " -i $HOST HOST
  read -e -p "Your username on the server: " -i $USER USER
  read -e -p "Local repository clone location: " -i $LOCALSRC LOCALSRC

  if [ ! -d $CONFIGDIR ]; then
    mkdir -p $CONFIGDIR
  fi
  cat > $CONFIGDIR/$CONFIGFILE << EOF
## Git Script Configuration
# Domain for your git server
HOST={$HOST}
# User to file the git repository under
USER={$USER}
# Folder to store git directories
LOCALSRC={$LOCALSRC}
EOF
fi
echo "Here's my current settings:"
echo "Git Domain:       ${HOST}"
echo "Git Username:     ${USER}"
echo "Local Directory:  ${LOCALSRC}"
echo "Do you want to continue?"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) break;;
    No  ) exit;;
  esac
done

### Set some command variables depending on whether we are root or not ###
aptget='sudo apt-get'
chsh='sudo chsh'
if [ `whoami` = 'root' ]; then
  aptget='apt-get'
  chsh='chsh'
fi

### Install git and some other tools we'd like to use ###
$aptget update
$aptget install -y tmux vim git

### Install homeshick ###
if [ ! -d $HOME/.homesick/repos/homeshick ]; then
  git clone git://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
  source $HOME/.homesick/repos/homeshick/homeshick.sh
else
  source $HOME/.homesick/repos/homeshick/homeshick.sh
fi

if [ ! -d $HOME/.homesick/repos/dotfiles ]; then
  homeshick clone git@${HOST}:${USER}/other/dotfiles
fi
if [ ! -d $HOME/.homesick/repos/binfiles ]; then
  homeshick clone git@${HOST}:${USER}/other/binfiles
fi

# Install Vundle
if [ ! -d $HOME/.vim/bundle/vundle ]; then
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
fi

### Link it all to $HOME ###
echo "Force link all files?"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) $homeshick link --force; break;;
    No  ) break;;
  esac
done

### Set default shell to your favorite shell ###
echo "Do you want to change shell to bash?"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) $chsh --shell /bin/bash `whoami`; break;;
    No  ) exit;;
  esac
done

echo "Completed"
