#!/bin/bash
# logging the output
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/homerinstalllog.out 2>&1

# Single touch install Homer7.7 with DB on the box 
# Specifically with homer_data DB on a separate data disk and the homer_config DB on the OS disk
# Support for Ubuntu 20.04/22.04 as well as Debian 10, 11 & 12
sudo apt-get install -y libluajit-5.1-common libluajit-5.1-dev lsb-release wget curl git
[[ "$TRACE" ]] && { set -x; set -o functrace; }
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
logfile="/tmp/$(basename $0).$$.log"
exec > >(tee -ia $logfile)
exec 2> >(tee -ia $logfile >&2)
trap 'exit 1' TERM
my_pid=$$
# HOMER Options, defaults
# Change here for external DB and select no for postgres
DB_USER="homer_user"
DB_PASS=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64 | sed 's/[=\+//]//g')
DB_HOST="localhost"
LISTEN_PORT="9060"
CHRONOGRAF_LISTEN_PORT="8888"
INSTALL_INFLUXDB=""

OS=`uname -s`
HOME_DIR=$HOME
CURRENT_DIR=`pwd`
ARCH=`uname -m`

#### NO CHANGES BELOW THIS LINE! 
VERSION=7.7
SETUP_ENTRYPOINT=""
OS=""
DISTRO=""
DISTRO_VERSION=""
# Start of function definitions
is_root_user() {
  if [[ $EUID != 0 ]]; then
    return 1
  fi
  return 0
}
have_commands() {
  local cmd_list="$1"
  local -a not_found=() 
  
  for cmd in $cmd_list; do
    command -v $cmd >/dev/null 2>&1 || not_found+=("$cmd")
  done
  
  if [[ ${#not_found[@]} == 0 ]]; then
    # All commands found
    return 0
  else
    # Something not found
    return 1
  fi
}

locate_cmd() {
  local cmd="$1"
  local valid_cmd=""
  # valid_cmd=$(hash -t $cmd 2>/dev/null)
  valid_cmd=$(command -v $cmd 2>/dev/null)
  if [[ ! -z "$valid_cmd" ]]; then
    echo "$valid_cmd"
  else
    echo "HALT: Please install package for command '$cmd'"
    /bin/kill -s TERM $my_pid
  fi
  return 0
}
is_supported_os() {
  local os_type=$1

  case "$os_type" in
    linux* ) OS="Linux"
             minimal_command_list="lsb_release wget curl git"
             if ! have_commands "$minimal_command_list"; then
               echo "ERROR: You need the following minimal set of commands installed:"
               echo ""
               echo "       $minimal_command_list"
               echo ""
               exit 1
             fi
             detect_linux_distribution # Supported OS, Check if supported distro.
             return ;;  
    *      ) return 1 ;;               # Unsupported OS
  esac
}
detect_linux_distribution() {
  local cmd_lsb_release=$(locate_cmd "lsb_release")
  local distro_name=$($cmd_lsb_release -si)
  local distro_version=$($cmd_lsb_release -sr)
  DISTRO="$distro_name"
  DISTRO_VERSION="$distro_version"

  case "$distro_name" in
    Ubuntu ) case "$distro_version" in
               20.04* | 22.04* ) SETUP_ENTRYPOINT="setup_debian"
                    return 0 ;; # Suported Distribution
               *  ) return 1 ;; # Unsupported Distribution
             esac
             ;;
    Debian ) case "$distro_version" in
            10* | 11* | 12* ) SETUP_ENTRYPOINT="setup_debian"
                    return 0 ;; # Suported Distribution
               *  ) return 1 ;; # Unsupported Distribution
             esac
             ;;
    *      ) return 1 ;; # Unsupported Distribution
 esac
}
check_status() {
  local return_code="$1"
  if [[ $return_code != 0 ]]; then
    echo "HALT: Return code of command was '$return_code', aborting."
    echo "Please check the log above and correct the issue."
    exit 1
  fi
}
banner_start() {
  clear;
  echo "**************************************************************"
  echo "                                                              "
  echo "      ,;;;;;,       HOMER SIP CAPTURE (http://sipcapture.org) "
  echo "     ;;;;;;;;;.     Single-Node Auto-Installer (beta $VERSION)"
  echo "   ;;;;;;;;;;;;;                                              "
  echo "  ;;;;  ;;;  ;;;;   <--------------- INVITE ---------------   "
  echo "  ;;;;  ;;;  ;;;;    --------------- 200 OK --------------->  "
  echo "  ;;;;  ...  ;;;;                                             "
  echo "  ;;;;       ;;;;   WARNING: This installer is intended for   "
  echo "  ;;;;  ;;;  ;;;;   dedicated/vanilla OS setups without any   "
  echo "  ,;;;  ;;;  ;;;;   customization and with default settings   "
  echo "   ;;;;;;;;;;;;;                                              "
  echo "    :;;;;;;;;;;     THIS SCRIPT IS PROVIDED AS-IS, USE AT     "
  echo "     ^;;;;;;;^      YOUR *OWN* RISK, REVIEW LICENSE & DOCS    "
  echo "                                                              "
  echo "**************************************************************"
  echo;
}
banner_end() {
  local cmd_ip=$(locate_cmd "ip")
  local cmd_head=$(locate_cmd "head")
  local cmd_awk=$(locate_cmd "awk")

  local my_primary_ip=$($cmd_ip route get 8.8.8.8 | $cmd_head -1 | grep -Po '(\d+\.){3}\d+' | tail -n1)

  echo "*************************************************************"
  echo "      ,;;;;,                                                 "
  echo "     ;;;;;;;;.     Congratulations! HOMER has been installed!"
  echo "   ;;;;;;;;;;;;                                              "
  echo "  ;;;;  ;;  ;;;;   <--------------- INVITE ---------------   "
  echo "  ;;;;  ;;  ;;;;    --------------- 200 OK --------------->  "
  echo "  ;;;;  ..  ;;;;                                             "
  echo "  ;;;;      ;;;;   Your system should be now ready to rock!"
  echo "  ;;;;  ;;  ;;;;   Please verify/complete the configuration  "
  echo "  ,;;;  ;;  ;;;;   files generated by the installer below.   "
  echo "   ;;;;;;;;;;;;                                              "
  echo "    :;;;;;;;;;     THIS SCRIPT IS PROVIDED AS-IS, USE AT     "
  echo "     ;;;;;;;;      YOUR *OWN* RISK, REVIEW LICENSE & DOCS    "
  echo "                                                             "
  echo "*************************************************************"
  echo
  echo "     * Configuration Files:"
  echo "         '/usr/local/homer/etc/webapp_config.json'"
  echo "         '/etc/heplify-server.toml'"
  echo
  echo "     * Start/stop HOMER Application Server:"
  echo "         'systemctl start|stop homer-app'"
  echo
  echo "     * Start/stop HOMER SIP Capture Server:"
  echo "         'systemctl start|stop heplify-server'"
  echo
  echo "     * Start/stop HOMER SIP Capture Agent:"
  echo "         'systemctl start|stop heplify'"
  echo
  echo "     * Access HOMER UI:"
  echo "         http://$my_primary_ip:443"
  echo "         [default: admin/sipcapture]"
  echo
  echo "     * Send HEP/EEP Encapsulated Packets to:"
  echo "         hep://$my_primary_ip:$LISTEN_PORT"
  echo
  echo "     * Prometheus Metrics URL:"
  echo "         http://$my_primary_ip:9096/metrics"
  echo
  echo
  echo "**************************************************************"
  echo
  echo " IMPORTANT: Do not forget to send Homer node some traffic! ;) "
  echo " For our capture agents, visit http://github.com/sipcapture "
  echo " For more help and information visit: http://sipcapture.org "
  echo
  echo "**************************************************************"
  echo " Installer Log saved to: $logfile "
  echo
}
start_app() {
  banner_start
  if ! is_root_user; then
    echo "ERROR: You must be the root user. Exiting..." 2>&1
    echo  2>&1
    exit 1
  fi

  if ! is_supported_os "$OSTYPE"; then
    echo "ERROR:"
    echo "Sorry, this Installer does not support your OS yet!"
    echo "Please follow instructions in the HOW-TO for manual installation & setup"
    echo "available at http://sipcapture.org"
    echo
    exit 1
  else
    unalias cp 2>/dev/null
    $SETUP_ENTRYPOINT
    banner_end
  fi
  exit 0
}
create_postgres_user_database(){
  cwd=$(pwd)
  cd /tmp
  # Give ownership to postgres for the data disk
  sudo mkdir -p /pg
  sudo chown -R postgres:postgres /pg
  sudo chmod 700 /pg
  # use tablespace to put the homer_data database in the /pg path. 
  sudo -u postgres psql -c "CREATE TABLESPACE datadisk01 LOCATION '/pg';"
  sudo -u postgres psql -c "CREATE DATABASE homer_config;"
  sudo -u postgres psql -c "CREATE DATABASE homer_data TABLESPACE datadisk01;"
  sudo -u postgres psql -c "CREATE ROLE ${DB_USER} WITH SUPERUSER LOGIN PASSWORD '$DB_PASS';"
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE homer_config to homer_user;"
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE homer_data to homer_user;"
  cd $cwd
}
install_homer(){

  local cmd_curl=$(locate_cmd "curl")
  local cmd_sed=$(locate_cmd "sed")
  echo "Installing Homer-App"
  if [ -f /etc/debian_version ]; then
	  local cmd_apt_get=$(locate_cmd "apt-get")
	  $cmd_curl -s https://packagecloud.io/install/repositories/qxip/sipcapture/script.deb.sh?any=true | sudo bash
	  $cmd_apt_get install homer-app heplify-server -y
  fi
  
  $cmd_sed -i -e "s/homer_user/$DB_USER/g" /usr/local/homer/etc/webapp_config.json
  $cmd_sed -i -e "s/homer_password/$DB_PASS/g" /usr/local/homer/etc/webapp_config.json
  $cmd_sed -i "s/9080/443/g" /usr/local/homer/etc/webapp_config.json

  local cmd_homerapp=$(locate_cmd "homer-app")
  $cmd_homerapp -create-table-db-config 
  $cmd_homerapp -populate-table-db-config

  $cmd_sed -i -e "s/DBUser\s*=\s*\"postgres\"/DBUser          = \"$DB_USER\"/g" /etc/heplify-server.toml
  $cmd_sed -i -e "s/DBPass\s*=\s*\"\"/DBPass          = \"$DB_PASS\"/g" /etc/heplify-server.toml
  $cmd_sed -i -e "s/PromAddr\s*=\s*\"\"/PromAddr        = \"0.0.0.0:9096\"/g" /etc/heplify-server.toml
  $cmd_sed -i -e "s/HEPTLSAddr            = \"0.0.0.0:9060\"/HEPTLSAddr            = \"0.0.0.0:9061\"/g" /etc/heplify-server.toml
  $cmd_sed -i -e "s/HEPTCPAddr            = \"\"/HEPTCPAddr            = \"0.0.0.0:9060\"/g" /etc/heplify-server.toml

  sudo systemctl enable homer-app
  sudo systemctl restart homer-app
  sudo systemctl status homer-app

  sudo systemctl enable heplify-server
  sudo systemctl restart heplify-server
  sudo systemctl status heplify-server

}
setup_debian() {
  local base_pkg_list="software-properties-common make cmake gcc g++ dirmngr sudo python3-dev net-tools"
  local cmd_apt_get=$(locate_cmd "apt-get")
  local cmd_wget=$(locate_cmd "wget")
  local cmd_apt_key=$(locate_cmd "apt-key")
  local cmd_service=$(locate_cmd "systemctl")
  local cmd_curl=$(locate_cmd "curl")
  local cmd_wget=$(locate_cmd "wget")

  $cmd_apt_get update && $cmd_apt_get upgrade -y

  $cmd_apt_get install -y $base_pkg_list
  $cmd_apt_get update
  
  $cmd_apt_get install -y postgresql postgresql-contrib
  
  $cmd_service daemon-reload
  $cmd_service enable postgresql
  $cmd_service restart postgresql

  create_postgres_user_database

  install_homer
}
[[ "$0" == "$BASH_SOURCE" ]] && start_app