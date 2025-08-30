#!/bin/bash

# Detect if script is being run via curl/wget pipe
if [[ "$0" == "bash" || "$0" == "sh" || "$0" == /dev/fd/* || ! -t 0 ]]; then
    echo "NOTICE: Script appears to be run via curl/wget pipe or process substitution."
    echo "These commands may persist after reopening the terminal,"
    echo "but it is recommended to put this installer inside your ~/.bashrc file."
    echo
fi

# Function to detect ChromeOS
check_chromeos() {
  if grep -qi "chrome" /etc/lsb-release >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Function to check adb/fastboot
check_tools() {
  missing=0
  command -v adb >/dev/null 2>&1 || { echo "ADB not found. Please install it first."; missing=1; }
  command -v fastboot >/dev/null 2>&1 || { echo "Fastboot not found. Please install it first."; missing=1; }
  return $missing
}

# Function to install all aliases/functions
install_quickroot() {
  # qrdevices
  alias qrdevices='
    echo "Checking ADB devices...";
    adb_out=$(adb devices | awk "NR>1");
    if [ -z "$adb_out" ]; then
      echo "No devices detected via ADB.";
    else
      echo "$adb_out";
    fi;

    echo "Checking Fastboot devices...";
    fb_out=$(fastboot devices);
    if [ -z "$fb_out" ]; then
      echo "No devices detected in Fastboot.";
    else
      echo "$fb_out";
    fi;
  '

  # qrunlock function
  qrunlock_func() {
    echo "Rebooting device into bootloader..."
    adb reboot bootloader
    echo
    echo "WARNING: Unlocking your bootloader may require a device-specific unlock code."
    echo "Unlocking will erase all data on your device!"
    read -p "Do you want to proceed with unlocking the bootloader? (yes/no) " confirm
    if [[ "$confirm" == "yes" ]]; then
      fastboot oem unlock
      echo "Unlock command sent. Follow device prompts."
    else
      echo "Bootloader unlock canceled."
    fi
  }
  alias qrunlock='qrunlock_func'

  # qrshell
  alias qrshell='adb shell'

  # qrinfo
  alias qrinfo='adb shell getprop ro.product.model; adb shell getprop ro.build.version.release'

  # qrver
  alias qrver='echo "Quick Root by KaisenTech. Version 1.00 '\''Soda'\''."'

  # qrsoda (custom soda can ASCII, hidden easter egg)
  alias qrsoda='
echo "                                                                                 "
echo "                             @@@@@@@@@@@@@@@@@@@@                                "
echo "                        @@@@@@@@@@@@@@@     @@@@@@@@@@                          "
echo "                      @@@@@@@         @@@@@@@@@@  @@@@@@                        "
echo "                      @@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@                        "
echo "                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                        "
echo "                     @@@@@@@    @@@@@@@@@@@@@@    @@@@@@@                       "
echo "                    @@     @@@@@@@@@@@@@@@@@@@@@@@@     @@                      "
echo "                    @                                    @@                     "
echo "                   @@                                    @@                     "
echo "                   @@@@@                               @@@@                     "
echo "                   @@   @@                               @@                     "
echo "                   @@@@        @@@@@@@@@@@@@@            @@                     "
echo "                   @@@@                                  @@                     "
echo "                   @@@@                                  @@                     "
echo "                   @@@@                                  @@                     "
echo "                   @@@@                                  @@                     "
echo "                   @@@@                                  @@                     "
echo "                   @@@@          @@@  @@@@@@@@@@@        @@                     "
echo "                   @@@@          @@@@@@@@@@@@@@@@        @@                     "
echo "                   @@@@         @@@@@@@  @@@@@         @ @@                     "
echo "                   @@@@        @@@@@@@   @@@@          @@@@                     "
echo "                   @@@@       @@@@@@@@@@@@@@           @@@@                     "
echo "                   @@@@       @@@   @@@@@@@            @@@@                     "
echo "                   @@                                  @@@@                     "
echo "                   @@                                  @@@@                     "
echo "                   @@                                  @@@@                     "
echo "                   @@                                  @@@@                     "
echo "                   @@                                  @@@@                     "
echo "                   @@                                  @@@@                     "
echo "                   @@                                  @@@@                     "
echo "                   @@                                  @@@@                     "
echo "                    @@                                  @@                      "
echo "                     @@@@                            @@@@                       "
echo "                      @@@@@@@@@@              @@@@@@@@@@                        "
echo "                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                         "
echo "                            @@@@@@@@@@@@@@@@@@@@@@                               "
echo "                                                                                 "
  '

  # qrkey: retrieves bootloader unlock key
  qrkey_func() {
    echo "Attempting to retrieve your device unlock key..."
    fb_out=$(fastboot devices)
    if [ -z "$fb_out" ]; then
      echo "No device detected in fastboot. Please boot device into fastboot mode first."
      return
    fi

    key=$(fastboot oem get_unlock_data 2>/dev/null | tr -d '\r\n ')
    if [ -n "$key" ]; then
      echo "Your device unlock key is:"
      echo "$key"
      echo "Use this key on your manufacturer unlock page if required."
    else
      echo "Could not retrieve unlock key automatically."
      echo "Check your device manufacturer instructions to obtain the code."
    fi
  }
  alias qrkey='qrkey_func'

  # qrhelp: shows help for all commands (except qrsoda)
  qrhelp_func() {
    echo "Quick Root Help:"
    echo "- qrdevices : Lists devices connected via ADB and Fastboot."
    echo "- qrunlock  : Reboots to bootloader and optionally unlocks bootloader."
    echo "- qrshell   : Opens ADB shell on connected device."
    echo "- qrinfo    : Shows device model and Android version."
    echo "- qrver     : Shows Quick Root version info."
    echo "- qrkey     : Retrieves bootloader unlock key if device requires it."
    echo "- qrhelp    : Shows this help message."
    echo "- qrsource  : Shows Quick Root GitHub repository."
    echo
    echo "NOTE: If your device has a key to unlock and you got it, please double check its correct, and do not use qrunlock's unlock feature to unlock the bootloader if it requires a key."
  }
  alias qrhelp='qrhelp_func'

  # qrsource: shows GitHub repo link
  alias qrsource='echo "Quick Root source: https://github.com/Kaisen-Tech/Quick-Root/"'

  echo "Quick Root commands installed for this session:"
  echo "- qrdevices"
  echo "- qrunlock"
  echo "- qrshell"
  echo "- qrinfo"
  echo "- qrver"
  echo "- qrkey"
  echo "- qrhelp"
  echo "- qrsource"
  echo
  echo "These commands may persist after reopening the terminal,"
  echo "but it is recommended to put this installer inside your ~/.bashrc file."
}

# Main prompt
if check_chromeos; then
  echo "NOTICE: You may need to enable Developer Mode on your Chromebook before using certain commands."
  echo "Enabling Developer Mode will remove all your local data."
  echo
  echo "Choose an option:"
  echo "1) Cancel"
  echo "2) Continue anyway"
  echo "3) I'm already in Developer Mode"
  read -p "Enter 1, 2, or 3: " choice

  case $choice in
    1)
      echo "Installation canceled."
      exit 0
      ;;
    2|3)
      if ! check_tools; then
        echo "ADB and/or Fastboot missing. Install them first."
        exit 1
      fi
      install_quickroot
      ;;
    *)
      echo "Invalid choice. Exiting."
      exit 1
      ;;
  esac
else
  # Not ChromeOS, just install normally if tools exist
  if ! check_tools; then
    echo "ADB and/or Fastboot missing. Install them first."
    exit 1
  fi
  install_quickroot
fi
