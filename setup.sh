#!/bin/bash

RC_PATH=`pwd`

cd ~
ln -s $RC_PATH/vimrc ~/.vimrc
ln -s $RC_PATH/vim ~/.vim
mkdir -p ~/.config/terminator
ln -s $RC_PATH/terminator/config ~/.config/terminator/config
ln -s $RC_PATH/easystroke ~/.easystroke
cd $RC_PATH

