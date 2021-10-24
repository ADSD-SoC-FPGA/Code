ifneq ($(KERNELRELEASE),)
# kbuild part of makefile
obj-m  := hello_kernel_module.o

else
# normal makefile

# path to kernel directory
KDIR ?= ~/linux-socfpga

default:
	$(MAKE) -C $(KDIR) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- M=$$PWD

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
endif
