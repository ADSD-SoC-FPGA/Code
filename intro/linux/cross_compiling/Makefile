# SPDX-License-Identifier: MIT
# Copyright (c) 2018,2022 Trevor Vannoy.  All rights reserved.
#---------------------------------------------------------------------------------
# Description:  Makefile for Cross Compiling for both ARM and x86 Architectures
#               Running make creates two subdirectories: /exec (for the executables) 
#                                                    and /build (for the object files)
#               Under each of these there are two additional subdirectories created:
#               /arm and /x86 for the architecture specific files.
#---------------------------------------------------------------------------------
# Author:       Trevor Vannoy
# Company:      Montana State University
# Create Date:  March 22, 2018
# Revision:     1.1
# License: MIT  (opensource.org/licenses/MIT)
#---------------------------------------------------------------------------------
# Usage: Step 1: Export the cross compilation variables:
#                ARCH=arm and CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-
#                This can be done with the associated script: arm_env.sh
#                command: source arm_env.sh or . arm_env.sh
#
#	 Step 2: In line 26, add the name of the program (e.g. EXEC=hello)
#                In line 29, add the source file(s) (e.g. SRCS=hello.c)
#

# name of the executable
EXEC=

# list the c source files
SRCS=

# define the object files by using suffix replacement on the SRCS list
OBJS=$(SRCS:.c=.o)

# directories where include files are located
INCLUDE_DIRS=.

# put an "-I" in front of each include directory;
# this is the way GCC needs the include directories specified
INC_PARAMS=$(foreach d, $(INCLUDE_DIRS), -I$d)

# build directories
BUILDDIR=build
X86BUILDDIR=$(BUILDDIR)/x86
ARMBUILDDIR=$(BUILDDIR)/arm

# executable directories
EXECDIR=exec
X86EXECDIR=$(EXECDIR)/x86
ARMEXECDIR=$(EXECDIR)/arm

# GCC flags
# 	-g		: retain debugging/symbol info in executable
# 	-Wall 	: enable all compilation warnings
# 	-std 	: which c standard to use
# 	-O 		: optimization level; 0 is no optimization
# 	-I 		: include directories where headers are located
CFLAGS=-g -Wall -std=gnu99 -O0 $(INC_PARAMS)

# linker flags
# 	-static	: use static linking instead of dynamic linking
# We don't need static linking for the x86 host because the shared objects
# are guaranteed to be on our host. On our ARM target, however, it's possible
# that some libraries may be missing or have incompatible versions; thus, we
# default to static linking, at the expense of larger binaries; if this is
# undesirable for your application, use dynamic linking instead!
ARM_LDFLAGS=-static

# arm cross compiler
CC_ARM=$(CROSS_COMPILE)gcc

# x86 host compiler
CC_X86=gcc

# Rule syntax:
# target: prerequisites
#     recipe
#
# The target is the thing that gets created, prerequisites need to be executed
# before the target can be run, and the recpie defines how to create or update
# the target. Unless declared as phony, targets are assumed to be a real filename.
# Declaring a target as phony indicates that the target name is not a file that
# will be created. If a normal target already exists (e.g. the file or directory
# exists), then the target won't be run if the target is up to date.

# phony target to create the build directories and both exectuables
.PHONY: all
all : dirs arm x86

# phony target to build for the ARM archiecture; first create build directories,
# then build the executable.
.PHONY: arm
ifdef CROSS_COMPILE
arm: armdirs $(ARMEXECDIR)/$(EXEC)
else
arm:
	@echo "----------------------------------"
	@echo "**not building arm target because CROSS_COMPILE isn't exported**"
	@echo "----------------------------------"
endif

# phony target to build for x86; first create build directories, then build
# the executable
.PHONY: x86
x86: x86dirs $(X86EXECDIR)/$(EXEC)

# target to build the ARM executable. The ARM object files are prereqs.
# The recipe runs gcc with the linker flags to make the binary.
# $^ is the list of all the prereqs, and $@ is the target
$(ARMEXECDIR)/$(EXEC): $(ARMBUILDDIR)/$(OBJS)
	$(CC_ARM) $(ARM_LDFLAGS) $^ -o $@

# target to build the ARM objects from the c files (which are preqreqs);
# the recipe runs gcc with the cflags and creates the objects files for each
# source file.
$(ARMBUILDDIR)/$(OBJS): $(SRCS)
	@echo "----------------------------------"
	@echo "building for arm..."
	@echo "----------------------------------"
	$(CC_ARM) $(CFLAGS) -c $^ -o $@

# target to build the x86 exectuable; same as the equivalent ARM target
$(X86EXECDIR)/$(EXEC): $(X86BUILDDIR)/$(OBJS)
	$(CC_X86) $^ -o $@

# target to build the x86 object files; same as the equivalent ARM target
$(X86BUILDDIR)/$(OBJS): $(SRCS)
	@echo "----------------------------------"
	@echo "building for x86 host..."
	@echo "----------------------------------"
	$(CC_X86) $(CFLAGS) -c $^ -o $@


# phony target to make make build and executable directories if they don't
# already exist.
.PHONY: dirs
dirs: x86dirs armdirs

# only create the arm directories if teh CROSS_COMPILE environment variable is
# defined
ifdef CROSS_COMPILE
.PHONY: armdirs
armdirs: $(ARMBUILDDIR) $(ARMEXECDIR)
else
armdirs:
endif

# phony targer to create the x86 build directories
.PHONY: x86dirs
x86dirs: $(X86BUILDDIR) $(X86EXECDIR)

# target to create the x86 build directory
$(X86BUILDDIR):
	@echo "----------------------------------"
	@echo "creating x86 directories..."
	@echo "----------------------------------"
	mkdir -p $@

# target to create the ARM build directory
$(ARMBUILDDIR):
	@echo "----------------------------------"
	@echo "creating arm directories..."
	@echo "----------------------------------"
	mkdir -p $@

# target to create the x86 executable directory
$(X86EXECDIR):
	mkdir -p $@

# target to create the ARM executable directory
$(ARMEXECDIR):
	mkdir -p $@


# phony target to remove build files and executables
.PHONY: clean
clean:
	@echo "----------------------------------"
	@echo "removing build files..."
	@echo "----------------------------------"
	rm -rf $(BUILDDIR)
	@echo "----------------------------------"
	@echo "removing executable files..."
	@echo "----------------------------------"
	rm -rf $(EXECDIR)

# phony target that just lists all available targets
.PHONY: help
help:
	@echo "----------------------------------"
	@echo "available targets:"
	@echo "----------------------------------"
	@echo "all: build for arm and x86"
	@echo "arm: build for arm"
	@echo "x86: build for x86"
	@echo "dirs: create all build directories"
	@echo "x86dirs: create x86 build directories"
	@echo "armdirs: create arm build directories"
	@echo "clean: remove build and exectuable files"
	@echo "help: show this help text"
