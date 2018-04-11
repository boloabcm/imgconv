# Project: Image converter
# File: Makefile
# Version: 0.1
# Create by: Rom1 <rom1@canel.ch> - CANEL - https://www.canel.ch
# Date: 11/04/2018
# Licence: GNU GENERAL PUBLIC LICENSE v3

PREFIX = ~/bin

all: install

install:
	cp imgconv.sh $(PREFIX)/imgconv
	cp autowhite $(PREFIX)/autowhite

link:
	ln -s $(shell pwd)/imgconv.sh $(PREFIX)/imgconv
	ln -s $(shell pwd)/autowhite $(PREFIX)/autowhite

desinst:
	@rm -i $(PREFIX)/imgconv
	@rm -i $(PREFIX)/autowhite
