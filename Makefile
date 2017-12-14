.DEFAULT: all
.PHONY: all clean jailbreak jailbreak_firstday jailbreak_map

PLATFORM := unknown
TAR := tar
GZIP := -9

ifeq ($(OS),Windows_NT)
    PLATFORM := windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		PLATFORM := linux
	endif
	ifeq ($(UNAME_S),Darwin)
		PLATFORM := osx
		export TAR := gtar
	endif
endif

export TAR
export GZIP
export SPCOMP := "$(abspath spcomp)"
export SPFLAGS := "-i$(abspath include/common)" "-i$(abspath include/jailbreak)"
SOURCEMOD ?= 1.8-6036
COMPLETE_TARS := jailbreak.tar.gz \
	jailbreak_firstday.tar.gz \
	jailbreak_map.tar.gz \

all: jailbreak_complete jailbreak jailbreak_firstday jailbreak_map

clean:
	$(MAKE) -C "jailbreak/" clean
	$(MAKE) -C "jailbreak_firstday/" clean
	$(MAKE) -C "jailbreak_map/" clean
	rm -rf "build/" "jailbreak_complete.tar.gz" "jailbreak_complete.zip" $(COMPLETE_TARS) $(COMPLETE_TARS:%.tar.gz=%.zip)

jailbreak:
	$(MAKE) -C "jailbreak/" all
	cp "jailbreak/jailbreak.zip" "jailbreak/jailbreak.tar.gz" .

jailbreak_complete: jailbreak jailbreak_firstday jailbreak_map
	mkdir -p "build/"
	cp ${COMPLETE_TARS} "build/"
	cd "build/" && for file in $(COMPLETE_TARS); do $(TAR) -xf "$$file"; done
	cd "build/" && zip -r -9 "jailbreak_complete.zip" "addons/"
	cd "build/" && $(TAR) -caf "jailbreak_complete.tar.gz" "addons/"
	cp -a "include/jailbreak/jailbreak.inc" "include/jailbreak/jailbreak/" "build/addons/sourcemod/scripting/include/"
	cp "build/jailbreak_complete.zip" "jailbreak_complete.zip"
	cp "build/jailbreak_complete.tar.gz" "jailbreak_complete.tar.gz"

jailbreak_firstday:
	$(MAKE) -C "jailbreak_firstday/" all
	cp "jailbreak_firstday/jailbreak_firstday.zip" "jailbreak_firstday/jailbreak_firstday.tar.gz" .

jailbreak_map:
	$(MAKE) -C "jailbreak_map/" all
	cp "jailbreak_map/jailbreak_map.zip" "jailbreak_map/jailbreak_map.tar.gz" .

spcomp:
	wget "https://dl.retroc.at/sourcemod/${SOURCEMOD}/${PLATFORM}/scripting/spcomp"
	chmod +x spcomp
