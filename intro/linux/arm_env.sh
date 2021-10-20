# SPDX-License-Identifier: MIT
#---------------------------------------------------------------------------
# Description:  Cross Compiling Shell Environment for ARM
#---------------------------------------------------------------------------
# Author:       Trevor Vannoy
# Company:      Montana State University
# Create Date:  March 22, 2019
# Revision:     1.0
# License: MIT  (opensource.org/licenses/MIT)
#---------------------------------------------------------------------------
#
# usage: source arm_env.sh
#

# Setup the CROSS_COMPILE environment variable so we can cross compile for the arm SoC
export CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-
export ARCH=arm

# Change the shell prompt so we can distinguish between the terminal with the cross_compile shell and the other normal ones
# Info on prompt syntax: https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
export PS1="\[\e[01;33m\]arm|\[\e[01;35m\]\w \[\e[01;31m\]>> \[\e[0m\]"
