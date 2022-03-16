# Python Script to run VSG on a VHDL file
# Authors: Ross Snider, Trevor Vannoy
# SPDX-License-Identifier: MIT
#
# Steps to format/check a VHDL file
# 1. Set the VHDL file name and path (lines 18-19)
#    Note: In the path string Python treats a backslash (\) as an escape character.
#          Use forward slashes (/), double back slashes (\\) or a string literal (r"\").
# 2. Set the yaml path and file name for the yaml vhdl style guide (line 22)
# 3. Run this script in Python
# 4. Fix VHDL style errors/warnings and rerun as necessary
# Note: requires vsg installed: https://github.com/jeremiah-c-leary/vhdl-style-guide

import os
from pathlib import Path

# VHDL file to format
vhdl_file = "vhdl_file_name.vhd"
vhdl_path = Path(r"C:/<path_to_vhdl_file_directory>")

# VHDL Style Guide location
yaml_path = Path(r"C:/<path_to_yaml_file_directory>")
yaml_file = yaml_path / "adsd_vhdl_style.yaml"

# Get current directory
cwd = os.getcwd()
print("Current working directory: {0}".format(cwd))

# Change to directory containing VHDL file
os.chdir(vhdl_path)
print("Changing to VHDL file directory: {0}".format(os.getcwd()))

# Modify/Format the VHDL file
command_str = str("vsg -c " + str(yaml_file) + " -f " + vhdl_file + " --fix")
print(f"command: {command_str}")
os.system(command_str)

# Change back to the original directory
os.chdir(cwd)
print("Changing back to directory: {0}".format(os.getcwd()))
