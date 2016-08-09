#!/bin/bash

if [ ! -e ~/Nico.rc ]; then 
	echo "Nico.rc wasn't found in the home directory."
	echo "Please specify Nico.rc's path."
	exit 1;
fi

cd ~
ln -s ~/Nico.rc/vimrc ~/.vimrc
ln -s ~/Nico.rc/vim ~/.vim
mkdir -p ~/.config/terminator
ln -s ~/Nico.rc/terminator/config ~/.config/terminator/config
cd -
