.DEFAULT: all
.PHONY: all clean jailbreak jailbreak_firstday jailbreak_map

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
COMPLETE_TARS := jailbreak.tar.gz \
	jailbreak_firstday.tar.gz \
	jailbreak_map.tar.gz \

all: jailbreak_complete jailbreak jailbreak_firstday jailbreak_map

clean:
	$(MAKE) -C "jailbreak/" clean
	$(MAKE) -C "jailbreak_firstday/" clean
	$(MAKE) -C "jailbreak_map/" clean
	rm -rf "build/" "jailbreak_complete.tar.gz" "jailbreak_complete.zip" ${COMPLETE_TARS} ${COMPLETE_TARS:%.tar.gz=%.zip}

jailbreak:
	$(MAKE) -C "jailbreak/" all
	cp "jailbreak/jailbreak.zip" "jailbreak/jailbreak.tar.gz" .

jailbreak_complete: jailbreak jailbreak_firstday jailbreak_map
	mkdir "build/"
	cp ${COMPLETE_TARS} "build/"
	cd "build/" && for file in ${COMPLETE_TARS}; do tar -xf "$$file"; done
	cd "build/" && zip -r -9 "jailbreak_complete.zip" "addons/"
	cd "build/" && tar -caf "jailbreak_complete.tar.gz" "addons/"
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
