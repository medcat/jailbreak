GZIP=-9

.PHONY: all clean build
.DEFAULT: all

all: jailbreak_blueban.zip jailbreak_blueban.tar.gz

clean:
	$(RM) -r "build/" "jailbreak_blueban.tar.gz" "jailbreak_blueban.zip"
	$(RM) -r "scripting/jailbreak_blueban.smx"

jailbreak_blueban.zip: build
	cd "build/" && zip -r -9 "jailbreak_blueban.zip" "addons/"
	cp "build/jailbreak_blueban.zip" "jailbreak_blueban.zip"

jailbreak_blueban.tar.gz: build
	cd "build/" && $(TAR) -caf "jailbreak_blueban.tar.gz" "addons/"
	cp "build/jailbreak_blueban.tar.gz" "jailbreak_blueban.tar.gz"

build: scripting/jailbreak_blueban.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak_blueban.smx" "build/addons/sourcemod/plugins/"
	cp -a "translations/" "build/addons/sourcemod/"

scripting/jailbreak_blueban.smx: scripting/jailbreak_blueban.sp
	cd "scripting/" && $(SPCOMP) $(SPFLAGS) jailbreak_blueban.sp
