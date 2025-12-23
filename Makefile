# Rachel Atari 8-bit - Makefile
MADS ?= mads
ATARI800 ?= atari800

.PHONY: all run clean

all: build/rachel.xex
	@echo "Built: build/rachel.xex"

build/rachel.xex: src/main.asm src/*.asm src/net/fujinet.asm
	$(MADS) src/main.asm -o:build/rachel.xex -l:build/rachel.lst

run: build/rachel.xex
	$(ATARI800) -xl build/rachel.xex

clean:
	rm -rf build/*
