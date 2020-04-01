TOPTARGETS := all clean dist-no-debug dist
AMSBRANCH := $(shell git symbolic-ref --short HEAD)
AMSHASH := $(shell git rev-parse --short HEAD)
AMSREV := $(AMSBRANCH)-$(AMSHASH)

ifneq (, $(strip $(shell git status --porcelain 2>/dev/null)))
    AMSREV := $(AMSREV)-dirty
endif

COMPONENTS := fusee stratosphere mesosphere exosphere thermosphere troposphere libraries

all: $(COMPONENTS)

thermosphere:
	$(MAKE) -C thermosphere all

exosphere: thermosphere
	$(MAKE) -C exosphere all

stratosphere: exosphere libraries
	$(MAKE) -C stratosphere all

mesosphere: exosphere libraries
	$(MAKE) -C mesosphere all

troposphere: stratosphere
	$(MAKE) -C troposphere all

sept: exosphere
	$(MAKE) -C sept all

fusee: exosphere mesosphere stratosphere sept
	$(MAKE) -C $@ all

libraries:
	$(MAKE) -C libraries all

clean:
	$(MAKE) -C fusee clean
	rm -rf out

dist-no-debug: all
	$(eval MAJORVER = $(shell grep 'define ATMOSPHERE_RELEASE_VERSION_MAJOR\b' libraries/libvapours/include/vapours/ams/ams_api_version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval MINORVER = $(shell grep 'define ATMOSPHERE_RELEASE_VERSION_MINOR\b' libraries/libvapours/include/vapours/ams/ams_api_version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval MICROVER = $(shell grep 'define ATMOSPHERE_RELEASE_VERSION_MICRO\b' libraries/libvapours/include/vapours/ams/ams_api_version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval AMSVER = $(MAJORVER).$(MINORVER).$(MICROVER)-$(AMSREV))
	rm -rf shrekmosphere-$(AMSVER)
	rm -rf out
	mkdir shrekmosphere-$(AMSVER)
	mkdir shrekmosphere-$(AMSVER)/atmosphere
	mkdir shrekmosphere-$(AMSVER)/sept
	mkdir shrekmosphere-$(AMSVER)/switch
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000008
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/contents/010000000000000D
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000032
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000034
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000036
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000037
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/fatal_errors
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/config_templates
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/config
	cp fusee/fusee-primary/fusee-primary.bin shrekmosphere-$(AMSVER)/atmosphere/reboot_payload.bin
	cp fusee/fusee-mtc/fusee-mtc.bin shrekmosphere-$(AMSVER)/atmosphere/fusee-mtc.bin
	cp fusee/fusee-secondary/fusee-secondary.bin shrekmosphere-$(AMSVER)/atmosphere/fusee-secondary.bin
	cp fusee/fusee-secondary/fusee-secondary.bin shrekmosphere-$(AMSVER)/sept/payload.bin
	cp sept/sept-primary/sept-primary.bin shrekmosphere-$(AMSVER)/sept/sept-primary.bin
	cp sept/sept-secondary/sept-secondary.bin shrekmosphere-$(AMSVER)/sept/sept-secondary.bin
	cp sept/sept-secondary/sept-secondary_00.enc shrekmosphere-$(AMSVER)/sept/sept-secondary_00.enc
	cp sept/sept-secondary/sept-secondary_01.enc shrekmosphere-$(AMSVER)/sept/sept-secondary_01.enc
	cp sept/sept-secondary/sept-secondary_dev_00.enc shrekmosphere-$(AMSVER)/sept/sept-secondary_dev_00.enc
	cp sept/sept-secondary/sept-secondary_dev_01.enc shrekmosphere-$(AMSVER)/sept/sept-secondary_dev_01.enc
	cp config_templates/BCT.ini shrekmosphere-$(AMSVER)/atmosphere/config/BCT.ini
	cp config_templates/override_config.ini shrekmosphere-$(AMSVER)/atmosphere/config_templates/override_config.ini
	cp config_templates/system_settings.ini shrekmosphere-$(AMSVER)/atmosphere/config_templates/system_settings.ini
	cp -r config_templates/kip_patches shrekmosphere-$(AMSVER)/atmosphere/kip_patches
	cp -r config_templates/exefs_patches shrekmosphere-$(AMSVER)/atmosphere/exefs_patches
	cp -r config_templates/hbl_html shrekmosphere-$(AMSVER)/atmosphere/hbl_html
	cp stratosphere/boot2/boot2.nsp shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000008/exefs.nsp
	cp stratosphere/dmnt/dmnt.nsp shrekmosphere-$(AMSVER)/atmosphere/contents/010000000000000D/exefs.nsp
	cp stratosphere/eclct.stub/eclct.stub.nsp shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000032/exefs.nsp
	cp stratosphere/fatal/fatal.nsp shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000034/exefs.nsp
	cp stratosphere/creport/creport.nsp shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000036/exefs.nsp
	cp stratosphere/ro/ro.nsp shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000037/exefs.nsp
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000032/flags
	touch shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000032/flags/boot2.flag
	mkdir -p shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000037/flags
	touch shrekmosphere-$(AMSVER)/atmosphere/contents/0100000000000037/flags/boot2.flag
	cp troposphere/reboot_to_payload/reboot_to_payload.nro shrekmosphere-$(AMSVER)/switch/reboot_to_payload.nro
	cd shrekmosphere-$(AMSVER); zip -r ../shrekmosphere-$(AMSVER).zip ./*; cd ../;
	rm -r shrekmosphere-$(AMSVER)
	mkdir out
	mv shrekmosphere-$(AMSVER).zip out/shrekmosphere-$(AMSVER).zip
	cp fusee/fusee-primary/fusee-primary.bin out/fusee-primary.bin

dist: dist-no-debug
	$(eval MAJORVER = $(shell grep 'define ATMOSPHERE_RELEASE_VERSION_MAJOR\b' libraries/libvapours/include/vapours/ams/ams_api_version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval MINORVER = $(shell grep 'define ATMOSPHERE_RELEASE_VERSION_MINOR\b' libraries/libvapours/include/vapours/ams/ams_api_version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval MICROVER = $(shell grep 'define ATMOSPHERE_RELEASE_VERSION_MICRO\b' libraries/libvapours/include/vapours/ams/ams_api_version.h \
		| tr -s [:blank:] \
		| cut -d' ' -f3))
	$(eval AMSVER = $(MAJORVER).$(MINORVER).$(MICROVER)-$(AMSREV))
	rm -rf shrekmosphere-$(AMSVER)-debug
	mkdir shrekmosphere-$(AMSVER)-debug
	cp fusee/fusee-primary/fusee-primary.elf shrekmosphere-$(AMSVER)-debug/fusee-primary.elf
	cp fusee/fusee-mtc/fusee-mtc.elf shrekmosphere-$(AMSVER)-debug/fusee-mtc.elf
	cp fusee/fusee-secondary/fusee-secondary.elf shrekmosphere-$(AMSVER)-debug/fusee-secondary.elf
	cp sept/sept-primary/sept-primary.elf shrekmosphere-$(AMSVER)-debug/sept-primary.elf
	cp sept/sept-secondary/sept-secondary.elf shrekmosphere-$(AMSVER)-debug/sept-secondary.elf
	cp sept/sept-secondary/key_derivation/key_derivation.elf shrekmosphere-$(AMSVER)-debug/sept-secondary-key-derivation.elf
	cp exosphere/exosphere.elf shrekmosphere-$(AMSVER)-debug/exosphere.elf
	cp exosphere/lp0fw/lp0fw.elf shrekmosphere-$(AMSVER)-debug/lp0fw.elf
	cp exosphere/sc7fw/sc7fw.elf shrekmosphere-$(AMSVER)-debug/sc7fw.elf
	cp exosphere/rebootstub/rebootstub.elf shrekmosphere-$(AMSVER)-debug/rebootstub.elf
	cp mesosphere/kernel_ldr/kernel_ldr.elf shrekmosphere-$(AMSVER)-debug/kernel_ldr.elf
	cp stratosphere/ams_mitm/ams_mitm.elf shrekmosphere-$(AMSVER)-debug/ams_mitm.elf
	cp stratosphere/boot/boot.elf shrekmosphere-$(AMSVER)-debug/boot.elf
	cp stratosphere/boot2/boot2.elf shrekmosphere-$(AMSVER)-debug/boot2.elf
	cp stratosphere/creport/creport.elf shrekmosphere-$(AMSVER)-debug/creport.elf
	cp stratosphere/dmnt/dmnt.elf shrekmosphere-$(AMSVER)-debug/dmnt.elf
	cp stratosphere/eclct.stub/eclct.stub.elf shrekmosphere-$(AMSVER)-debug/eclct.stub.elf
	cp stratosphere/fatal/fatal.elf shrekmosphere-$(AMSVER)-debug/fatal.elf
	cp stratosphere/loader/loader.elf shrekmosphere-$(AMSVER)-debug/loader.elf
	cp stratosphere/pm/pm.elf shrekmosphere-$(AMSVER)-debug/pm.elf
	cp stratosphere/ro/ro.elf shrekmosphere-$(AMSVER)-debug/ro.elf
	cp stratosphere/sm/sm.elf shrekmosphere-$(AMSVER)-debug/sm.elf
	cp stratosphere/spl/spl.elf shrekmosphere-$(AMSVER)-debug/spl.elf
	cd shrekmosphere-$(AMSVER)-debug; zip -r ../shrekmosphere-$(AMSVER)-debug.zip ./*; cd ../;
	rm -r shrekmosphere-$(AMSVER)-debug
	mv shrekmosphere-$(AMSVER)-debug.zip out/shrekmosphere-$(AMSVER)-debug.zip


.PHONY: $(TOPTARGETS) $(COMPONENTS)
