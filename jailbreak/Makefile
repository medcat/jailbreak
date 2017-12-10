GZIP=-9

.PHONY: all
.DEFAULT: all

all: jailbreak.zip jailbreak.tar.gz
	rm -rf "build/"

jailbreak.zip: build
	cd "build/" && zip -r -9 "jailbreak.zip" "addons/"
	cp "build/jailbreak.zip" "jailbreak.zip"

jailbreak.tar.gz: build
	cd "build/" && tar -caf "jailbreak.tar.gz" "addons/"
	cp "build/jailbreak.tar.gz" "jailbreak.tar.gz"

build: scripting/jailbreak.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak.smx" "build/addons/sourcemod/plugins/"
	mkdir -p "build/addons/sourcemod/scripting/include/"
	cp "scripting/jailbreak.inc" "build/addons/sourcemod/scripting/include/"
	mkdir -p "build/addons/sourcemod/configs"
	cp -a "configs/" "build/addons/sourcemod/configs/"
	mkdir -p "build/addons/sourcemod/translations"
	cp -a "translations/" "build/addons/sourcemod/translations/"

scripting/jailbreak.smx:
	cd "scripting/" && ./spcomp -iinclude jailbreak.sp
