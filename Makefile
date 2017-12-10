.DEFAULT: all
.PHONY: all jailbreak jailbreak_firstday

PLATFORM := unknown
ifeq ($(OS),Windows_NT)
    PLATFORM := windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		PLATFORM := linux
	endif
	ifeq ($(UNAME_S),Darwin)
		PLATFORM := osx
	endif
endif
SOURCEMOD ?= 1.8-6036
GZIP := -9

all: jailbreak_complete jailbreak jailbreak_firstday

jailbreak:
	$(MAKE) -C "jailbreak/" all
	cp "jailbreak/jailbreak.zip" "jailbreak/jailbreak.tar.gz" .

jailbreak_complete: jailbreak jailbreak_firstday
	mkdir "build/"
	cp "jailbreak.tar.gz" "jailbreak_firstday.tar.gz" "build/"
	cd "build/" && tar -xf "jailbreak.tar.gz" && tar -xf "jailbreak_firstday.tar.gz"
	cd "build/" && zip -r -9 "jailbreak_complete.zip" "addons/"
	cd "build/" && tar -caf "jailbreak_complete.tar.gz" "addons/"
	cp "build/jailbreak_complete.zip" "jailbreak_complete.zip"
	cp "build/jailbreak_complete.tar.gz" "jailbreak_complete.tar.gz"
	rm -rf "build/"

jailbreak_firstday:
	$(MAKE) -C "jailbreak_firstday/" all
	cp "jailbreak_firstday/jailbreak_firstday.zip" "jailbreak_firstday/jailbreak_firstday.tar.gz" .

spcomp:
	wget "https://dl.retroc.at/sourcemod/${SOURCEMOD}/${PLATFORM}/scripting/spcomp"
	chmod +x spcomp
