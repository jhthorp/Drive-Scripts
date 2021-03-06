#!/bin/bash
################################################################################
#                             TrueNAS Drive Erase                              #
#                                                                              #
#             This script will export a single function that will              #
#                    begin a drive erase for a single drive                    #
################################################################################
#       Copyright © 2020 - 2021, Jack Thorp and associated contributors.       #
#                                                                              #
#    This program is free software: you can redistribute it and/or modify      #
#    it under the terms of the GNU General Public License as published by      #
#    the Free Software Foundation, either version 3 of the License, or         #
#    any later version.                                                        #
#                                                                              #
#    This program is distributed in the hope that it will be useful,           #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of            #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
#    GNU General Public License for more details.                              #
#                                                                              #
#    You should have received a copy of the GNU General Public License         #
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.    #
################################################################################

################################################################################
#                                 SCRIPT SETUP                                 #
################################################################################
#===============================================================================
# This section will store some "Process Global" variables into a stack that
# fully supports nesting into the upcoming includes so that these variables
# are correctly held intact.
#
# The following variables are currently being stored:
#    0 - SOURCING_INVOCATION - Boolean - If the script was sourced not invoked
#    1 - DIR - String - The script's directory path
#===============================================================================
# Get the global stack if it exists
if [ -z ${stack_vars+x} ]; 
then 
  declare stack_vars=(); 
fi

# Determine the BASH source (SOURCING_INVOCATION)
(return 0 2>/dev/null) &&
stack_vars[${#stack_vars[@]}]=1 || 
stack_vars[${#stack_vars[@]}]=0

# Determine the exectuable directory (DIR)
DIR_SRC="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR_SRC}" ]];
then
  DIR_SRC="${PWD}";
fi

# Convert any relative paths into absolute paths
DIR_SRC=$(cd ${DIR_SRC}; printf %s. "$PWD")
DIR_SRC=${DIR_SRC%?}

# Copy over the DIR source and remove the temporary variable
stack_vars[${#stack_vars[@]}]=${DIR_SRC}
unset DIR_SRC

# Add Functional Aliases
SOURCING_INVOCATION () { echo "${stack_vars[${#stack_vars[@]}-2]}"; }
DIR () { echo "${stack_vars[${#stack_vars[@]}-1]}"; }

################################################################################
#                               SCRIPT INCLUDES                                #
################################################################################
. "$(DIR)/../../Utility-Scripts/imaging/run_imaging.sh"

################################################################################
#                                  FUNCTIONS                                   #
################################################################################
#===============================================================================
# This function will begin a drive erase for a single drive.
#
# The following steps will be performed:
#   01) Pull drive info and display it
#   02a) If an HDD, perform the following steps (a)
#   02a1) Run a pass with a RANDOM pattern
#   02a2) Run a pass with a RANDOM pattern
#   02a3) Run a pass with a ZERO pattern
#   02b) If an SSD, perform the following steps (b)
#   02b1) Run a pass with a RANDOM pattern
#   02b2) Run a pass with a RANDOM pattern
#   02b3) Run a pass with a ZERO pattern
#   03) Pull drive info and display it
#
# GLOBALS / SIDE EFFECTS:
#   N_A - N/A
#
# OPTIONS:
#   [-na] N/A
#
# ARGUMENTS:
#   [1 - drive] The drive to erase
#
# OUTPUTS:
#   N/A - N/A
#
# RETURN:
#   0 - SUCCESS
#   Non-Zero - ERROR
#===============================================================================
erase_drive ()
{
  local drive=${1}

  local AUTOMATED_SKIP="auto_skip"
  local IMAGING_BS=1048576

  local BORDER_PC="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  local BORDER="${BORDER_PC}${BORDER_PC}${BORDER_PC}${BORDER_PC}"

  version="1.0.0"
  filename=$(echo "${drive}" | 
    sed \
      -e 's/\//_/g' \
  )
  filename="${filename}.txt"

  # Print a copyright/license header
  cat > ${filename} << EOF
Copyright © 2020 - 2021, Jack Thorp and associated contributors.
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under certain conditions.
See the GNU General Public License for more details.
EOF

  # Print a border
  echo ${BORDER} \
    >> ${filename} \
    2>&1

  # Print some disclaimer info
  cat >> ${filename} << EOF
This file was generated by running the erase scripts (Version ${version}) located at:
https://github.com/jhthorp/Drive-Scripts

For support, please create a GitHub Issue (https://github.com/jhthorp/Drive-Scripts/issues/new) 
or submit a Pull Request.

Run Options:
  Drive ID: ${drive}
EOF

  # Print a border
  echo ${BORDER} \
    >> ${filename} \
    2>&1

  # Print the Drive Info
  drive_info=$(smartctl \
    -a \
    ${drive} \
  )
  echo "${drive_info}" \
    >> ${filename} \
    2>&1

  # Print a border
  echo ${BORDER} \
    >> ${filename} \
    2>&1

  # Print the Drive Capabilities
  local drive_capabilities=$(smartctl \
    -c \
    ${drive} \
  )
  echo "${drive_capabilities}" \
    >> ${filename} \
    2>&1

  # Print a border
  echo ${BORDER} \
    >> ${filename} \
    2>&1

  # Determine the Drive's Rotational Rate
  drive_rotational_rate=$(echo "${drive_info}" | 
    grep \
      'Rotation Rate' \
  )
  drive_rotational_rate=${drive_rotational_rate//Rotation Rate:}

  # Trim leading spaces
  drive_rotational_rate=`echo ${drive_rotational_rate} | sed 's/^ *//g'`

  # Trim trailing spaces
  drive_rotational_rate=`echo ${drive_rotational_rate} | sed 's/ *$//g'`

  if [ "${drive_rotational_rate}" = "Solid State Device" ]
  then
      echo "Drive is a SSD..." \
        >> ${filename} \
        2>&1
      drive_medium="SSD"
  else
      echo "Drive is a HDD..." \
        >> ${filename} \
        2>&1
      drive_medium="HDD"
  fi

  # Print a border
  echo ${BORDER} \
    >> ${filename} \
    2>&1

  # Run the HDD/SSD steps
  if [ "${drive_medium}" = "SSD" ]
  then
      echo "Running SSD erase steps..." \
        >> ${filename} \
        2>&1

      # Run a first pass with a RANDOM pattern
      echo "Begin first pass (RANDOM pattern)..." \
        >> ${filename} \
        2>&1
      openssl \
        enc \
          -aes-256-ctr \
          -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" \
          -nosalt \
          < /dev/zero \
          > ${drive}

      # Run a second pass with a RANDOM pattern
      echo "Begin second pass (RANDOM pattern)..." \
        >> ${filename} \
        2>&1
      openssl \
        enc \
          -aes-256-ctr \
          -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" \
          -nosalt \
          < /dev/zero \
          > ${drive}

      # Run a third pass with a ZERO pattern
      echo "Begin third pass (ZERO pattern)..." \
        >> ${filename} \
        2>&1
      $(run_imaging \
        ${drive} \
        ${IMAGING_BS} \
        "write" \
        false \
        >> ${filename} \
        2>&1 \
      )
  else
      echo "Running HDD erase steps..." \
        >> ${filename} \
        2>&1

      # Run a first pass with a RANDOM pattern
      echo "Begin first pass (RANDOM pattern)..." \
        >> ${filename} \
        2>&1
      openssl \
        enc \
          -aes-256-ctr \
          -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" \
          -nosalt \
          < /dev/zero \
          > ${drive}

      # Run a second pass with a RANDOM pattern
      echo "Begin second pass (RANDOM pattern)..." \
        >> ${filename} \
        2>&1
      openssl \
        enc \
          -aes-256-ctr \
          -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" \
          -nosalt \
          < /dev/zero \
          > ${drive}

      # Run a third pass with a ZERO pattern
      echo "Begin third pass (ZERO pattern)..." \
        >> ${filename} \
        2>&1
      $(run_imaging \
        ${drive} \
        ${IMAGING_BS} \
        "write" \
        false \
        >> ${filename} \
        2>&1 \
      )
  fi

  # Print a border
  echo ${BORDER} \
    >> ${filename} \
    2>&1

  # Print the Drive Info
  drive_info=$(smartctl \
    -a \
    ${drive} \
  )
  echo "${drive_info}" \
    >> ${filename} \
    2>&1

  # Print a border
  echo ${BORDER} \
    >> ${filename} \
    2>&1

  # Add a COMPLETED message
  echo "Erase has completed..." \
    >> ${filename} \
    2>&1
}

################################################################################
#                               SCRIPT EXECUTION                               #
################################################################################
#===============================================================================
# This section will execute if the script is invoked from the terminal rather 
# than sourced into another script as a function.  If the first parameter is 
# "auto_skip" then any prompts will be bypassed.
#
# GLOBALS / SIDE EFFECTS:
#   N_A - N/A
#
# OPTIONS:
#   [-na] N/A
#
# ARGUMENTS:
#   [ALL] All arguments are passed into the script's function except the first 
#         if it is "auto_skip".
#
# OUTPUTS:
#   N/A - N/A
#
# RETURN:
#   0 - SUCCESS
#   Non-Zero - ERROR
#===============================================================================
if [ $(SOURCING_INVOCATION) = 0 ];
then
  # Print a copyright/license header
  cat << EOF
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| Copyright © 2020 - 2021, Jack Thorp and associated contributors.  |
|          This program comes with ABSOLUTELY NO WARRANTY.          |
|   This is free software, and you are welcome to redistribute it   |
|                     under certain conditions.                     |
|        See the GNU General Public License for more details.       |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EOF

  # Print a disclaimer
  cat << EOF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!                             WARNING                             !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!        BY PROCEEDING, ALL DATA ON DISK WILL BE DESTROYED        !!
!!       STOP AND DO NOT RUN IF DISK CONTAINS VALUABLE DATA        !!
!!                                                                 !!
!!  DEPENDING ON DISK SIZE, THE RUNTIME CAN EXCEED SEVERAL DAYS    !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF

  if [ "${1}" = "auto_skip" ]
  then
    # Remove the auto_skip parameter
    shift

    # Start the script
    erase_drive "${@}"
  else
    CONTINUE=false
    read -p "Would you like to continue (y/n)?" choice
    case "$choice" in 
      y|Y ) CONTINUE=true;;
      n|N ) CONTINUE=false;;
      * ) echo "Invalid Entry";;
    esac

    if [ "${CONTINUE}" = true ]
    then
        # Start the script
        unset CONTINUE
        erase_drive "${@}"
    fi
    unset CONTINUE
  fi
fi

################################################################################
#                                SCRIPT TEARDOWN                               #
################################################################################
#===============================================================================
# This section will remove the "Process Global" variables from the stack
#===============================================================================
unset stack_vars[${#stack_vars[@]}-1] # DIR
unset stack_vars[${#stack_vars[@]}-1] # SOURCING_INVOCATION