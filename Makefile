.DEFAULT: all
.PHONY: all clean

SOURCE_FILES := \
	source/commands/warden_actions.sp \
	source/commands/warden_menu.sp \
	source/commands/warden.sp \
	source/round/entities.sp \
	source/balance.sp \
	source/commands.sp \
	source/cvar.sp \
	source/hud.sp \
	source/plugin.sp \
	source/round.sp

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

all: jailbreak.zip
clean:
	rm -rf jailbreak.zip jailbreak.smx jailbreak.tar.gz build

jailbreak.zip: jailbreak.smx build
	cd "build/" && zip -9 -r "jailbreak.zip" .
	cp "build/jailbreak.zip" "jailbreak.zip"

jailbreak.tar.gz: jailbreak.smx build
	tar -czf "$@" -C "build/" .

build:
	mkdir -p "build/addons/sourcemod/plugins/"
	mkdir -p "build/addons/sourcemod/translations/"
	cp jailbreak.smx "build/addons/sourcemod/plugins/"
	cp translations/* "build/addons/sourcemod/translations/"

jailbreak.smx: jailbreak.sp spcomp
	./spcomp -iinclude $<

jailbreak.sp: ${SOURCE_FILES}
	@touch "$@"

spcomp:
	wget "https://dl.retroc.at/sourcemod/${SOURCEMOD}/${PLATFORM}/scripting/spcomp"
	chmod +x spcomp
