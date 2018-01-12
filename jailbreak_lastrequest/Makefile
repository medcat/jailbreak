GZIP=-9

.PHONY: all clean build
.DEFAULT: all

all: jailbreak_lastrequest.zip jailbreak_lastrequest.tar.gz

clean:
	$(RM) -r "build/" "jailbreak_lastrequest.tar.gz" "jailbreak_lastrequest.zip"
	$(RM) -r "scripting/jailbreak_lastrequest.smx"

jailbreak_lastrequest.zip: build
	cd "build/" && zip -r -9 "jailbreak_lastrequest.zip" "addons/"
	cp "build/jailbreak_lastrequest.zip" "jailbreak_lastrequest.zip"

jailbreak_lastrequest.tar.gz: build
	cd "build/" && $(TAR) -caf "jailbreak_lastrequest.tar.gz" "addons/"
	cp "build/jailbreak_lastrequest.tar.gz" "jailbreak_lastrequest.tar.gz"

build: scripting/jailbreak_lastrequest.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak_lastrequest.smx" "build/addons/sourcemod/plugins/"
	cp -a "configs/" "build/addons/sourcemod/"
	cp -a "translations/" "build/addons/sourcemod/"

scripting/jailbreak_lastrequest.smx: scripting/jailbreak_lastrequest.sp
	cd "scripting/" && $(SPCOMP) $(SPFLAGS) jailbreak_lastrequest.sp
