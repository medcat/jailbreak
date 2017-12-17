GZIP=-9

.PHONY: all clean
.DEFAULT: all

all: jailbreak_teamban.zip jailbreak_teamban.tar.gz

clean:
	rm -rf "build/" "jailbreak_teamban.tar.gz" "jailbreak_teamban.zip"
	# rm -rf "scripting/jailbreak_teamban.smx"

jailbreak_teamban.zip: build
	cd "build/" && zip -r -9 "jailbreak_teamban.zip" "addons/"
	cp "build/jailbreak_teamban.zip" "jailbreak_teamban.zip"

jailbreak_teamban.tar.gz: build
	cd "build/" && $(TAR) -caf "jailbreak_teamban.tar.gz" "addons/"
	cp "build/jailbreak_teamban.tar.gz" "jailbreak_teamban.tar.gz"

build: scripting/jailbreak_teamban.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak_teamban.smx" "build/addons/sourcemod/plugins/"
	cp -a "translations/" "build/addons/sourcemod/"

scripting/jailbreak_teamban.smx: scripting/jailbreak_teamban.sp
	cd "scripting/" && $(SPCOMP) $(SPFLAGS) jailbreak_teamban.sp
