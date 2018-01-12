GZIP=-9

.PHONY: all clean build
.DEFAULT: all

all: jailbreak_redmute.zip jailbreak_redmute.tar.gz

clean:
	$(RM) -r "build/" "jailbreak_redmute.tar.gz" "jailbreak_redmute.zip"
	$(RM) -r "scripting/jailbreak_redmute.smx"

jailbreak_redmute.zip: build
	cd "build/" && zip -r -9 "jailbreak_redmute.zip" "addons/"
	cp "build/jailbreak_redmute.zip" "jailbreak_redmute.zip"

jailbreak_redmute.tar.gz: build
	cd "build/" && $(TAR) -caf "jailbreak_redmute.tar.gz" "addons/"
	cp "build/jailbreak_redmute.tar.gz" "jailbreak_redmute.tar.gz"

build: scripting/jailbreak_redmute.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak_redmute.smx" "build/addons/sourcemod/plugins/"

scripting/jailbreak_redmute.smx: scripting/jailbreak_redmute.sp
	cd "scripting/" && $(SPCOMP) $(SPFLAGS) jailbreak_redmute.sp
