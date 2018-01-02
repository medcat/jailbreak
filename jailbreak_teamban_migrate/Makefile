GZIP=-9

.PHONY: all clean
.DEFAULT: all

all: jailbreak_teamban_migrate.zip jailbreak_teamban_migrate.tar.gz

clean:
	$(RM) -r "build/" "jailbreak_teamban_migrate.tar.gz" "jailbreak_teamban_migrate.zip"
	$(RM) -r "scripting/jailbreak_teamban_migrate.smx"

jailbreak_teamban_migrate.zip: build
	cd "build/" && zip -r -9 "jailbreak_teamban_migrate.zip" "addons/"
	cp "build/jailbreak_teamban_migrate.zip" "jailbreak_teamban_migrate.zip"

jailbreak_teamban_migrate.tar.gz: build
	cd "build/" && $(TAR) -caf "jailbreak_teamban_migrate.tar.gz" "addons/"
	cp "build/jailbreak_teamban_migrate.tar.gz" "jailbreak_teamban_migrate.tar.gz"

build: scripting/jailbreak_teamban_migrate.smx
	mkdir -p "build/addons/sourcemod/plugins/"
	cp "scripting/jailbreak_teamban_migrate.smx" "build/addons/sourcemod/plugins/"
	cp -a "translations/" "build/addons/sourcemod/"

scripting/jailbreak_teamban_migrate.smx: scripting/jailbreak_teamban_migrate.sp
	cd "scripting/" && $(SPCOMP) $(SPFLAGS) jailbreak_teamban_migrate.sp
