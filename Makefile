
PLATFORM := unknown
TAR := tar
GZIP := -9

ifeq ($(OS),Windows_NT)
    PLATFORM := windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		PLATFORM := linux
	endif
	ifeq ($(UNAME_S),Darwin)
		PLATFORM := osx
		export TAR := gtar
	endif
endif

export TAR
export GZIP
export SPCOMP := "$(abspath spcomp)"
export SPFLAGS := "-i$(abspath include/common)" "-i$(abspath include/jailbreak)"
DEFAULT_PLUGINS = jailbreak \
	jailbreak_firstday \
	jailbreak_map \
	jailbreak_redmute \
	jailbreak_teamban
OPTIONAL_PLUGINS = jailbreak_teamban_migrate
ALL_PLUGINS = $(DEFAULT_PLUGINS) $(OPTIONAL_PLUGINS)
SOURCEMOD ?= 1.8-6036
COMPLETE_TARS := jailbreak.tar.gz \
	jailbreak_firstday.tar.gz \
	jailbreak_map.tar.gz \
	jailbreak_teamban.tar.gz \

.DEFAULT: all
.PHONY: all clean $(ALL_PLUGINS)

all: jailbreak_complete $(OPTIONAL_PLUGINS)
clean:
	$(MAKE) -C "jailbreak/" clean
	$(MAKE) -C "jailbreak_firstday/" clean
	$(MAKE) -C "jailbreak_map/" clean
	$(MAKE) -C "jailbreak_redmute/" clean
	$(MAKE) -C "jailbreak_teamban/" clean
	$(MAKE) -C "jailbreak_teamban_migrate/" clean
	$(RM) -r "build/" "jailbreak_complete.tar.gz" "jailbreak_complete.zip" $(COMPLETE_TARS) $(COMPLETE_TARS:%.tar.gz=%.zip) "jailbreak_teamban_migrate.tar.gz" "jailbreak_teamban_migrate.zip"

jailbreak:
	$(MAKE) -C "jailbreak/" all
	cp "jailbreak/jailbreak.zip" "jailbreak/jailbreak.tar.gz" .

jailbreak_complete: $(DEFAULT_PLUGINS)
	mkdir -p "build/addons/sourcemod/scripting/include/"
	cp ${COMPLETE_TARS} "build/"
	cd "build/" && for file in $(COMPLETE_TARS); do $(TAR) -xf "$$file"; done
	cd "build/" && zip -r -9 "jailbreak_complete.zip" "addons/"
	cd "build/" && $(TAR) -caf "jailbreak_complete.tar.gz" "addons/"
	cp -a "include/jailbreak/jailbreak.inc" "include/jailbreak/jailbreak/" "build/addons/sourcemod/scripting/include/"
	cp "build/jailbreak_complete.zip" "jailbreak_complete.zip"
	cp "build/jailbreak_complete.tar.gz" "jailbreak_complete.tar.gz"

all-plugins: $(ALL_PLUGINS)
	mkdir -p "build/addons/sourcemod/scripting/include"
	for v in $(ALL_PLUGINS); do cp -a $$v/build/* "build/"; done
	cp -a "include/jailbreak/jailbreak.inc" "include/jailbreak/jailbreak/" "build/addons/sourcemod/scripting/include/"

jailbreak_firstday:
	$(MAKE) -C "jailbreak_firstday/" all
	cp "jailbreak_firstday/jailbreak_firstday.zip" "jailbreak_firstday/jailbreak_firstday.tar.gz" .

jailbreak_map:
	$(MAKE) -C "jailbreak_map/" all
	cp "jailbreak_map/jailbreak_map.zip" "jailbreak_map/jailbreak_map.tar.gz" .

jailbreak_redmute:
	$(MAKE) -C "jailbreak_redmute/" all
	cp "jailbreak_redmute/jailbreak_redmute.zip" "jailbreak_redmute/jailbreak_redmute.tar.gz" .

jailbreak_teamban:
	$(MAKE) -C "jailbreak_teamban/" all
	cp "jailbreak_teamban/jailbreak_teamban.zip" "jailbreak_teamban/jailbreak_teamban.tar.gz" .

jailbreak_teamban_migrate:
	$(MAKE) -C "jailbreak_teamban_migrate/" all
	cp "jailbreak_teamban_migrate/jailbreak_teamban_migrate.zip" "jailbreak_teamban_migrate/jailbreak_teamban_migrate.tar.gz" .

spcomp:
	wget "https://dl.retroc.at/sourcemod/${SOURCEMOD}/${PLATFORM}/scripting/spcomp"
	chmod +x spcomp
