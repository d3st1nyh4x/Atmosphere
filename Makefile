TOPTARGETS := all clean dist
AMSBRANCH := $(shell git symbolic-ref --short HEAD)
AMSHASH := $(shell git rev-parse --short HEAD)
AMSREV := $(AMSBRANCH)-$(AMSHASH)

ifneq (, $(strip $(shell git status --porcelain 2>/dev/null)))
    AMSREV := $(AMSREV)-dirty
endif

COMPONENTS := fusee stratosphere exosphere thermosphere troposphere

all: $(COMPONENTS)

thermosphere:
	$(MAKE) -C thermosphere all

exosphere: thermosphere
	$(MAKE) -C exosphere all

stratosphere: exosphere
	$(MAKE) -C stratosphere all

troposphere: stratosphere
	$(MAKE) -C troposphere all

sept: exosphere
	$(MAKE) -C sept all

fusee: exosphere stratosphere sept
	$(MAKE) -C $@ all

clean:
	$(MAKE) -C fusee clean
	rm -rf out

dist: all
	$(eval MAJORVER = $(shell grep '\ATMOSPHERE_RELEASE_VERSION_MAJOR\b' common/include/atmosphere/version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval MINORVER = $(shell grep '\ATMOSPHERE_RELEASE_VERSION_MINOR\b' common/include/atmosphere/version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval MICROVER = $(shell grep '\ATMOSPHERE_RELEASE_VERSION_MICRO\b' common/include/atmosphere/version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval AMSVER = $(MAJORVER).$(MINORVER).$(MICROVER)-$(AMSREV))
	rm -rf shrekmosphere-$(AMSVER)
	rm -rf out
	mkdir shrekmosphere-$(AMSVER)
	mkdir shrekmosphere-$(AMSVER)/atmosphere
	mkdir shrekmosphere-$(AMSVER)/sept
	mkdir shrekmosphere-$(AMSVER)/switch
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/titles/010000000000000D
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000032
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000034
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000036
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000037
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/fatal_errors
	cp fusee/fusee-primary/fusee-primary.bin shrekmosphere-$(AMSVER)/atmosphere/reboot_payload.bin
	cp fusee/fusee-mtc/fusee-mtc.bin shrekmosphere-$(AMSVER)/atmosphere/fusee-mtc.bin
	cp fusee/fusee-secondary/fusee-secondary.bin shrekmosphere-$(AMSVER)/atmosphere/fusee-secondary.bin
	cp fusee/fusee-secondary/fusee-secondary.bin shrekmosphere-$(AMSVER)/sept/payload.bin
	cp sept/sept-primary/sept-primary.bin shrekmosphere-$(AMSVER)/sept/sept-primary.bin
	cp sept/sept-secondary/sept-secondary.bin shrekmosphere-$(AMSVER)/sept/sept-secondary.bin
	cp sept/sept-secondary/sept-secondary_00.enc shrekmosphere-$(AMSVER)/sept/sept-secondary_00.enc
	cp sept/sept-secondary/sept-secondary_01.enc shrekmosphere-$(AMSVER)/sept/sept-secondary_01.enc
	cp common/defaults/BCT.ini shrekmosphere-$(AMSVER)/atmosphere/BCT.ini
	cp common/defaults/loader.ini shrekmosphere-$(AMSVER)/atmosphere/loader.ini
	cp common/defaults/system_settings.ini shrekmosphere-$(AMSVER)/atmosphere/system_settings.ini
	cp -r common/defaults/kip_patches shrekmosphere-$(AMSVER)/atmosphere/kip_patches
	cp -r common/defaults/exefs_patches shrekmosphere-$(AMSVER)/atmosphere/exefs_patches
	cp -r common/defaults/hbl_html shrekmosphere-$(AMSVER)/atmosphere/hbl_html
	cp stratosphere/dmnt/dmnt.nsp shrekmosphere-$(AMSVER)/atmosphere/titles/010000000000000D/exefs.nsp
	cp stratosphere/eclct.stub/eclct.stub.nsp shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000032/exefs.nsp
	cp stratosphere/fatal/fatal.nsp shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000034/exefs.nsp
	cp stratosphere/creport/creport.nsp shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000036/exefs.nsp
	cp stratosphere/ro/ro.nsp shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000037/exefs.nsp
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000032/flags
	touch shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000032/flags/boot2.flag
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000037/flags
	touch shrekmosphere-$(AMSVER)/atmosphere/titles/0100000000000037/flags/boot2.flag
	cp troposphere/reboot_to_payload/reboot_to_payload.nro shrekmosphere-$(AMSVER)/switch/reboot_to_payload.nro
	cd shrekmosphere-$(AMSVER); zip -r ../shrekmosphere-$(AMSVER).zip ./*; cd ../;
	rm -r shrekmosphere-$(AMSVER)
	mkdir out
	mv shrekmosphere-$(AMSVER).zip out/shrekmosphere-$(AMSVER).zip
	cp fusee/fusee-primary/fusee-primary.bin out/fusee-primary.bin


.PHONY: $(TOPTARGETS) $(COMPONENTS)
