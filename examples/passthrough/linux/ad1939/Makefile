# Set default options
KDIR ?= ../linux-socfpga
INSTALL_MOD_PATH ?= /srv/nfs/de10nano/ubuntu-rootfs

# Compose our full "make" command, with relevant options
MAKECMD = $(MAKE) -C $(KDIR) M=$(CURDIR) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

# This is the default if no target is specified
modules:
	$(MAKECMD) modules

modules_install:
	$(MAKECMD) modules_install

clean:
	$(MAKECMD) clean

help:
	$(MAKECMD) help
