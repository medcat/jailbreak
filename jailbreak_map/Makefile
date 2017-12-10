GZIP=-9

.PHONY: all clean
.DEFAULT: all

all: jailbreak_map.zip jailbreak_map.tar.gz

clean:
	rm -rf "build/" "jailbreak_map.tar.gz" "jailbreak_map.zip"
	# rm -rf "scripting/jailbreak_map.smx"

jailbreak_map.zip: build
	cd "build/" && zip -r -9 "jailbreak_map.zip" "addons/"
	cp "build/jailbreak_map.zip" "jailbreak_map.zip"

jailbreak_map.tar.gz: build
	cd "build/" && tar -caf "jailbreak_map.tar.gz" "addons/"
	cp "build/jailbreak_map.tar.gz" "jailbreak_map.tar.gz"

build: scripting/jailbreak_map.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak_map.smx" "build/addons/sourcemod/plugins/"
	cp -a "translations/" "build/addons/sourcemod/"
	cp -a "configs/" "build/addons/sourcemod/"

scripting/jailbreak_map.smx: scripting/jailbreak_map.sp
	cd "scripting/" && ./spcomp -iinclude jailbreak_map.sp
