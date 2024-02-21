KDIR ?= ../linux-socfpga
default:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR) CROSS_COMPILE=arm-linux-gnueabihf-

modules_install:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR) modules_install

clean:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR) clean

help:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR) help
