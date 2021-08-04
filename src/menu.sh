#!/bin/bash

require_octoprint_stopped() {
  systemctl is-active --quiet octoprint
  RET=$?
  if [ $RET -eq 0 ]; then
    whiptail --yesno "The OctoPrint service needs to be stopped before making changes. Continue?" 20 60 "" 3>&1 1>&2 2>&3
    RET=$?

    if [ $RET -eq 0 ]; then
      sudo systemctl stop octoprint
      RET=$?

      if [ $RET -eq 0 ]; then
        whiptail --msgbox "Successfully stopped service octoprint" 20 60 1
      else
        whiptail --msgbox "There was an error stopping service octoprint" 20 60 1
      fi
      return $RET
    else
      return 1
    fi
  fi
}

ask_start_octoprint() {
  whiptail --yesno "Would you like to start OctoPrint now?" 20 60 1
  RET=$?

  if [ $RET -eq 0 ]; then
    sudo systemctl start octoprint
    RET=$?

    if [ $RET -eq 0 ]; then
      whiptail --msgbox "Successfully started service octoprint" 20 60 1
    else
      whiptail --msgbox "There was an error starting service octoprint" 20 60 1
    fi
    return $RET
  else
    return
  fi
}

do_service_management() {
  CHOICE=$(whiptail --title "OctoPi System Menu" --menu "Service Management" --cancel-button "Back" 20 60 10 \
    "1" "OctoPrint:Stop" \
    "2" "OctoPrint:Start" \
    "3" "OctoPrint:Restart" \
    "" "" \
    "4" "OctoPrint:Start (Safe Mode)" \
    "5" "OctoPrint:Restart (Safe Mode)" \
    3>&1 1>&2 2>&3)
  RET=$?

  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case $CHOICE in
      "1")
        systemctl is-active --quiet octoprint
        RET=$?
        if [ $RET -ne 0 ]; then
          whiptail --msgbox "Service not running" 20 60 1
        fi

        sudo systemctl stop octoprint
        RET=$?
        
        if [ $RET -eq 0 ]; then
          whiptail --msgbox "Successfully stopped service octoprint" 20 60 1
        else
          whiptail --msgbox "There was an error stopping service octoprint" 20 60 1
        fi
        ;;
      "2")
        systemctl is-active --quiet octoprint
        RET=$?
        if [ $RET -eq 0 ]; then
          whiptail --msgbox "Service already running" 20 60 1
        fi

        sudo systemctl start octoprint
        RET=$?
        
        if [ $RET -eq 0 ]; then
          whiptail --msgbox "Successfully started service octoprint" 20 60 1
        else
          whiptail --msgbox "There was an error starting service octoprint" 20 60 1
        fi
        ;;
      "3")
        sudo systemctl restart octoprint
        RET=$?
        
        if [ $RET -eq 0 ]; then
          whiptail --msgbox "Successfully restarted service octoprint" 20 60 1
        else
          whiptail --msgbox "There was an error restarting service octoprint" 20 60 1
        fi
        ;;
      "4")
        systemctl is-active --quiet octoprint
        RET=$?
        if [ $RET -eq 0 ]; then
          whiptail --msgbox "Service already running" 20 60 1
        fi

        source ~/oprint/bin/activate
        ~/oprint/bin/octoprint safemode
        deactivate

        sudo systemctl start octoprint
        RET=$?
        
        if [ $RET -eq 0 ]; then
          whiptail --msgbox "Successfully started service octoprint in safe mode" 20 60 1
        else
          whiptail --msgbox "There was an error starting service octoprint" 20 60 1
        fi
        ;;
      "5")
        sudo systemctl stop octoprint

        source ~/oprint/bin/activate
        ~/oprint/bin/octoprint safemode
        deactivate

        sudo systemctl start octoprint
        RET=$?
        
        if [ $RET -eq 0 ]; then
          whiptail --msgbox "Successfully restarted service octoprint in safe mode" 20 60 1
        else
          whiptail --msgbox "There was an error starting service octoprint" 20 60 1
        fi
        ;;
    esac
  fi
  do_service_management
}

do_octoprint() {
  CHOICE=$(whiptail --title "OctoPi System Menu" --menu "OctoPrint Management" --cancel-button "Back" 20 60 10 \
    "1" "Logging" \
    "2" "User Management" \
    "3" "Configuration" \
    3>&1 1>&2 2>&3)
  RET=$?

  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case $CHOICE in
      "1")
        do_octoprint_logging
        ;;
      "2")
        do_octoprint_user_management
        ;;
      "3")
        do_octoprint_config
        ;;
    esac
  fi
  do_octoprint
}

do_octoprint_config() {
  CHOICE=$(whiptail --title "OctoPi System Menu" --menu "OctoPrint Management -> Configuration" --cancel-button "Back" 20 60 10 \
    "1" "View" \
    "2" "Edit" \
    "3" "Check" \
    3>&1 1>&2 2>&3)
  RET=$?

  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case $CHOICE in
      "1")
        nano -R -v ~/.octoprint/config.yaml
        ;;
      "2")
        do_octoprint_config_edit
        ;;
      "3")
        do_octoprint_config_check
        ;;
    esac
  fi
  do_octoprint_config
}

do_octoprint_logging() {
  CHOICE=$(whiptail --title "OctoPi System Menu" --menu "OctoPrint Management -> Logging" --cancel-button "Back" 20 60 10 \
    "1" "View Log" \
    "2" "Clear Logs" \
    3>&1 1>&2 2>&3)
  RET=$?

  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case $CHOICE in
      "1")
        nano -R -v ~/.octoprint/logs/octoprint.log
        ;;
      "2")
        #TODO: service should be stopped first
        find ~/.octoprint/logs/ -type -f -exec rm -f "{}" \;
        ;;
    esac
  fi
  do_octoprint_logging
}

do_octoprint_user_management() {
  CHOICE=$(whiptail --title "OctoPi System Menu" --menu "OctoPrint Management -> User Management" --cancel-button "Back" 20 60 10 \
    "1" "List Users" \
    "2" "Change Password" \
    "3" "Activate User" \
    3>&1 1>&2 2>&3)
  RET=$?

  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case $CHOICE in
      "1")
        clear
        source ~/oprint/bin/activate
        ~/oprint/bin/octoprint user list
        deactivate
        echo "Press ENTER to continue..."
        read
        clear
        ;;
      "2")
        require_octoprint_stopped
        RET=$?
        if [ $RET -ne 0 ];
        then
          return
        fi

        INPUT=$(whiptail --inputbox "Please enter a username" 20 60 "" 3>&1 1>&2 2>&3)
        clear
        source ~/oprint/bin/activate
        ~/oprint/bin/octoprint user password "${INPUT}"
        deactivate

        echo "Press ENTER to continue..."
        read

        ask_start_octoprint

        clear
        ;;
      "3")
        require_octoprint_stopped
        RET=$?
        if [ $RET -ne 0 ];
        then
          return
        fi

        INPUT=$(whiptail --inputbox "Please enter a username" 20 60 "" 3>&1 1>&2 2>&3)
        clear
        source ~/oprint/bin/activate
        ~/oprint/bin/octoprint user activate "${INPUT}"
        deactivate

        echo "Press ENTER to continue..."
        read

        ask_start_octoprint

        clear
        ;;
    esac
  fi
  do_octoprint_user_management
}

do_octoprint_config_edit() {
  require_octoprint_stopped
  RET=$?
  if [ $RET -ne 0 ];
  then
    return
  fi

  TMPFILE=$(mktemp)  
  cp ~/.octoprint/config.yaml $TMPFILE
  STAMP_BEFORE=$(stat -c %Y $TMPFILE)
  nano -R $TMPFILE
  STAMP_AFTER=$(stat -c %Y $TMPFILE)

  if [ $STAMP_AFTER -le $STAMP_BEFORE ]; then
    return
  fi

  CONFIG_GOOD=0
  while [ $CONFIG_GOOD -eq 0 ]; do
    source ~/oprint/bin/activate
    ~/oprint/bin/octoprint -c $TMPFILE config effective > /dev/null 2>&1
    RET=$?
    deactivate

    if [ $RET -eq 0 ]; then
      CONFIG_GOOD=1
    else
      whiptail --yesno "Errors were detected in the config. Would you like to review/fix?" 20 60 1
      RET=$?

      if [ $RET -eq 0 ]; then
        nano -R $TMPFILE
      else
        rm $TMPFILE
        return
      fi
    fi
  done

  cp ~/.octoprint/config.yaml ~/.octoprint/config.yaml.$(date +%s)
  cat $TMPFILE > ~/.octoprint/config.yaml
  rm $TMPFILE

  ask_start_octoprint

  do_octoprint_config
}

do_octoprint_config_check() {
  source ~/oprint/bin/activate
  ~/oprint/bin/octoprint config effective > /dev/null 2>&1
  RET=$?
  deactivate

  if [ $RET -eq 0 ]; then
    whiptail --msgbox "Configuration contains no errors" 20 60 1
  else
    whiptail --msgbox "There were errors checking the configuration" 20 60 1
  fi
  do_octoprint
}

do_tools() {
  CHOICE=$(whiptail --title "OctoPi System Menu" --menu "Tools" --cancel-button "Back" 20 60 10 \
    "1" "Detect Printer USB Serial" \
    3>&1 1>&2 2>&3)
  RET=$?

  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case $CHOICE in
      "1")
        do_tools_detect_printer_usb_serial
        ;;
    esac
  fi
  do_octoprint
}

do_tools_detect_printer_usb_serial() {
  REPORT_FILE=$(mktemp)

  TMPFILE_UDEV_MONITOR=$(mktemp)
  TMPFILE_FIND_PRE=$(mktemp)
  TMPFILE_FIND_POST=$(mktemp)

  echo "Please remove your printers USB cable then press ENTER to continue..."
  read

  DMESG_LAST_MSG=$(dmesg | grep -E '^\[[0-9\.]+\]' | tail -n 1 | awk ' { print $1 } ')
  udevadm monitor -p > $TMPFILE_UDEV_MONITOR &
  UDEV_MONITOR_PID=$!

  find /dev/tty* /dev/serial -xdev > $TMPFILE_FIND_PRE

  echo "Now insert your printers USB cable then press ENTER to continue..."
  read

  sleep 5
  find /dev/tty* /dev/serial -xdev > $TMPFILE_FIND_POST
  kill $UDEV_MONITOR_PID > /dev/null 2>&1

  echo -e "---Generated - $(date)\n" > $REPORT_FILE

  echo "===DEV PATHS:" >> $REPORT_FILE
  diff $TMPFILE_FIND_PRE $TMPFILE_FIND_POST | grep '^>' | sed 's/> //g' >> $REPORT_FILE
  echo -e "\n\n" >> $REPORT_FILE

  echo "===DMESG:" >> $REPORT_FILE
  dmesg | grep -F "${DMESG_LAST_MSG}" -A $(dmesg | wc -l) | tail -n +2> >> $REPORT_FILE
  echo -e "\n\n" >> $REPORT_FILE

  echo "===UDEV MONITOR:" >> $REPORT_FILE
  cat $TMPFILE_UDEV_MONITOR >> $REPORT_FILE


  nano -R -v $REPORT_FILE
  echo "A copy of the report can be found at ${REPORT_FILE}"
  echo "Press ENTER to continue..."
  read
}

do_main() {
  CHOICE=$(whiptail --title "OctoPi System Menu" --menu "" --cancel-button "Quit" 20 60 10 \
    "1" "Service Management" \
    "2" "OctoPrint Management" \
    "3" "Tools" \
    "4" "Exit To Terminal" \
    3>&1 1>&2 2>&3)
  RET=$?

  if [ $RET -eq 1 ]; then
    exit 0
  elif [ $RET -eq 0 ]; then
    case $CHOICE in
      "1")
        do_service_management
        ;;
      "2")
        do_octoprint
        ;;
      "3")
        do_tools
        ;;
      "4")
        exit 0
        ;;
    esac
  fi
  do_main
}

do_main
