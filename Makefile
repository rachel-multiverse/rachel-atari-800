# Rachel Atari 8-bit - Makefile
MADS ?= .tools/mads
ATARI800 ?= atari800

.PHONY: all tools test run clean

all: build/rachel.xex
	@echo "Built: build/rachel.xex"

tools: .tools/mads

.tools/mads: tools/fetch-mads.sh
	./tools/fetch-mads.sh

build/rachel.xex: src/main.asm src/*.asm src/net/fujinet.asm | .tools/mads
	mkdir -p build
	$(MADS) src/main.asm -o:build/rachel.xex -l:build/rachel.lst

test: build/rachel.xex
	python3 tests/test_protocol.py

run: build/rachel.xex
	$(ATARI800) -xl build/rachel.xex

clean:
	rm -rf build/*
