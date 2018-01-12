GZIP=-9

.PHONY: all clean build
.DEFAULT: all

JAILBREAK_SOURCE := $(shell find "scripting/jailbreak/" -name "*.sp")

all: jailbreak.zip jailbreak.tar.gz

clean:
	$(RM) -r "build/" "jailbreak.tar.gz" "jailbreak.zip"
	$(RM) -r "scripting/jailbreak.smx"

jailbreak.zip: build
	cd "build/" && zip -r -9 "jailbreak.zip" "addons/"
	cp "build/jailbreak.zip" "jailbreak.zip"

jailbreak.tar.gz: build
	cd "build/" && $(TAR) -caf "jailbreak.tar.gz" "addons/"
	cp "build/jailbreak.tar.gz" "jailbreak.tar.gz"

build: scripting/jailbreak.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak.smx" "build/addons/sourcemod/plugins/"
	cp -a "translations/" "build/addons/sourcemod/"

scripting/jailbreak.smx: scripting/jailbreak.sp $(JAILBREAK_SOURCE)
	cd "scripting/" && $(SPCOMP) $(SPFLAGS) jailbreak.sp
