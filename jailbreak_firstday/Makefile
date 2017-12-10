GZIP=-9

.PHONY: all
.DEFAULT: all

all: jailbreak_firstday.zip jailbreak_firstday.tar.gz
	rm -rf "build/"

jailbreak_firstday.zip: build
	cd "build/" && zip -r -9 "jailbreak_firstday.zip" "addons/"
	cp "build/jailbreak_firstday.zip" "jailbreak_firstday.zip"

jailbreak_firstday.tar.gz: build
	cd "build/" && tar -caf "jailbreak_firstday.tar.gz" "addons/"
	cp "build/jailbreak_firstday.tar.gz" "jailbreak_firstday.tar.gz"

build: scripting/jailbreak_firstday.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak_firstday.smx" "build/addons/sourcemod/plugins/"
	mkdir -p "build/addons/sourcemod/translations"
	cp -a "translations/" "build/addons/sourcemod/translations/"

scripting/jailbreak_firstday.smx:
	cd "scripting/" && ./spcomp -iinclude jailbreak_firstday.sp
