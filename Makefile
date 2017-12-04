.DEFAULT: all
.PHONY: all

PLATFORM ?= windows
SOURCEMOD ?= 1.8-6036

all: jailbreak.smx

jailbreak.smx: jailbreak.sp spcomp
	spcomp $<

spcomp:
	wget "https://dl.retroc.at/sourcemod/$SOURCEMOD/$PLATFORM/scripting/spcomp.exe"
	cp spcomp.exe spcomp
