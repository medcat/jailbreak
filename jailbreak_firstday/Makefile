GZIP=-9

.PHONY: all clean
.DEFAULT: all

all: jailbreak_firstday.zip jailbreak_firstday.tar.gz

clean:
	rm -rf "build/" "jailbreak_firstday.tar.gz" "jailbreak_firstday.zip"
	# rm -rf "scripting/jailbreak_firstday.smx"

jailbreak_firstday.zip: build
	cd "build/" && zip -r -9 "jailbreak_firstday.zip" "addons/"
	cp "build/jailbreak_firstday.zip" "jailbreak_firstday.zip"

jailbreak_firstday.tar.gz: build
	cd "build/" && $(TAR) -caf "jailbreak_firstday.tar.gz" "addons/"
	cp "build/jailbreak_firstday.tar.gz" "jailbreak_firstday.tar.gz"

build: scripting/jailbreak_firstday.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak_firstday.smx" "build/addons/sourcemod/plugins/"
	cp -a "translations/" "build/addons/sourcemod/"

scripting/jailbreak_firstday.smx: scripting/jailbreak_firstday.sp
	cd "scripting/" && ./spcomp -iinclude jailbreak_firstday.sp
