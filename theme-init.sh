#!/usr/bin/env bash

#-------------- GLOBALS VARS -----------#
# TODO: update this vars
DOCKER_CONTAINER_NAME="wordpress-backend"
ROOT_FOLDER=$(pwd)
BACKEND_WORKSPACE="${ROOT_FOLDER}/theme"
ENV_FILE=.env
STYLE_FILE="./style.css"
VERSION="2.0"
OPTION=""
ARGUMENT=""
#---------------------------------------#

log(){
    if [ $# -gt 1 ]; then
        if [[ $1 == *"-"* ]]; then
            echo $1 -e "\x1B[01;94m$2\x1B[0m"
        fi
    else
      echo -e "\x1B[01;94m$1\x1B[0m"
    fi
}
warning(){
    if [ $# -gt 1 ]; then
        if [[ $1 == *"-"* ]]; then
            echo $1 -e "\x1B[01;33m$2\x1B[0m"
        fi
    else
      echo -e "\x1B[01;33m$1\x1B[0m"
    fi
}
error(){
    if [ $# -gt 1 ]; then
        if [[ $1 == *"-"* ]]; then
            echo $1 -e "\x1B[01;31m$2\x1B[0m"
        fi
    else
      echo -e "\x1B[01;31m$1\x1B[0m"
    fi
}
success(){
    if [ $# -gt 1 ]; then
        if [[ $1 == *"-"* ]]; then
            echo $1 -e "\x1B[01;32m$2\x1B[0m"
        fi
    else
      echo -e "\x1B[01;32m$1\x1B[0m"
    fi
}
info(){
    if [ $# -gt 1 ]; then
        if [[ $1 == *"-"* ]]; then
            echo $1 -e "\x1B[38;5;82m$2\x1B[0m"
        fi
    else
      echo -e "\x1B[38;5;82m$1\x1B[0m"
    fi
}

check_env_file() {
# check if .env file exist
if [[ ! -f "$ENV_FILE" ]]; then
    warning "Environment file ($ENV_FILE) does not exist."

    read -p "Do you want import default environment file [Y/n]? " -n 1 -r choice
    echo    # (optional) move to a new line
    case "$choice" in
      y|Y|"" )
      log "Creating default environment file..."
      cp ${ROOT_FOLDER}/.env.sample .env
      success "Done"
      __init__
      ;;
      n|N ) exit;;
      * )
      echo "invalid command"
      check_env_file
      ;;
    esac
    exit
fi
}

upgrade_php_version() {
    version_to_update="7.4"

    # Checking if brew is installed
    which -s brew
    if [[ $? != 0 ]] ; then
        warning "You need Homebrew installed to work with this. Do you want to install it [y/N]?"
        read -p "" -n 1 -r choice
        echo
        case "$choice" in
          y|Y )
            # Install Homebrew
            log "Installing Homebrew... "
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            check_script
            success "\n\n\nHomebrew installed with success. Press any key to continue...\n\n"
            read -p "" -n 1
            ;;
          n|N|"" )
            exit 1
            ;;
          * )
            clear
            upgrade_php_version
            ;;
        esac
    fi

    log "\nUpdating PHP to version ${version_to_update}..."

    brew install php@${version_to_update}

    if [[ $? -ne 0 ]]; then
        error "\n\nSeems there is an error when we're trying to upgrade PHP.\nPlease try run the script again or try to setup by yourself following this link: https://stitcher.io/blog/php-8-upgrade-mac"
        exit 1
    else
        success "\nPHP v${version_to_update} installed with success!\n\n"
    fi

    log "Overwrite brew link.."
    brew link --overwrite --force php@${version_to_update}
    check_script

    log -n "Updating bash..."
    echo 'export PATH="/usr/local/opt/php@'.${version_to_update}.'/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="/usr/local/opt/php@'.${version_to_update}.'/sbin:$PATH"' >> ~/.bash_profile
    source ~/.bash_profile
    check_script

    success "\n\n\nPHP version updated with success. Press any key to continue...\n\n"
    read -p "" -n 1
    __init__
}

check_php_version() {
  php_major_version=$(php -r 'echo PHP_MAJOR_VERSION;')
  php_minor_version=$(php -r 'echo PHP_MINOR_VERSION;')
  php_release_version=$(php -r 'echo PHP_RELEASE_VERSION;')

  if [[ ${php_major_version} -ne 7 ]] || [[ ${php_minor_version} -lt 4 ]]; then
        error "Your PHP version (${php_major_version}.${php_minor_version}.${php_release_version}) is lower than required (7.4.0 or above)\n"
        warning -n "Do you want to try upgrade PHP version to 7.4.0 [y/N]?"
        read -p "" -n 1 -r choice
        echo
        case "$choice" in
          y|Y )
            upgrade_php_version
            ;;
          n|N|"" )
            ;;
          * )
            clear
            check_php_version
            ;;
        esac
        exit 1
  fi
}

cli_help() {
  clear
  cli_name=${0##*/}
  info "
     __          _______    _____       _ _
     \ \        / /  __ \  |_   _|     (_) |
      \ \  /\  / /| |__) |   | |  _ __  _| |_
       \ \/  \/ / |  ___/    | | | '_ \| | __|
        \  /\  /  | |       _| |_| | | | | |_
         \/  \/   |_|      |_____|_| |_|_|\__|

      WordPress init local development
      Version: $VERSION
      Usage: $cli_name [option] [parameter]
      Options:
            all                  Run all commands
            fresh-install        Run 'clean' command then 'all' commands
            install-dependencies Install nodejs and php dependencies
            dummy-data           Add dummy data to WordPress
            frontend             Start frontend development
            clean                Clean all files created by wordpress including the containers
            *                    Help
      Parameters:
            --select-dummy-data  Allows to choose which dummy data you want to install
      "
      check_php_version
  exit 1
}

checkout_backend_develop() {
    warning -n "Do you want to do checkout of the developer branch [y/N]? "
    read -p "" -n 1 -r choice
    echo
    case "$choice" in
      y|Y )
        # switch to backend repo folder
        cd ${BACKEND_WORKSPACE}
        # Switch to developer branch
        log -n "Checkout develop branch... "
        git checkout develop
        check_script
        cd .. # Jump back to root folder
        ;;
      n|N|"" )
        ;;
        * )
        clear
        checkout_backend_develop
        ;;
    esac
}

checking_node_modules() {
  # Check if already exists node_modules folder and remove it
  if [[ -d "${BACKEND_WORKSPACE}/node_modules" ]]; then
    warning -n "Node_modules folder already exists. Do you want to remove it and reinstall it [y/N]? "
    read -p "" -n 1 -r choice
    echo
    case "$choice" in
      y|Y )
        remove_node_modules
        install_node_modules
        ;;
      n|N|"" )
        ;;
        * )
        clear
        checking_node_modules
        ;;
    esac
  else
    install_node_modules
  fi
}

remove_node_modules() {
    cd ${BACKEND_WORKSPACE}
    if [[ -f "$STYLE_FILE" ]]; then
        log -n "Remove old style file... "
        rm "$STYLE_FILE"
        check_script
    fi
    if [[ -d "./node_modules" ]]; then
        log -n "Removing old node_modules folder... "
        rm -rf ./node_modules
        check_script
    fi
    cd .. # Jump back to root folder
}

install_node_modules() {
    cd ${BACKEND_WORKSPACE}
    # Installing npm packages
    log "Running npm install..."
    npm i --quiet --silent
    check_script
    cd .. # Jump back to root folder
}

check_style_file() {
  if [[ -f "$BACKEND_WORKSPACE/$STYLE_FILE" ]]; then
    warning -n "Style file already exist! Do you want to build again [y/N]?"
    read -p "" -n 1 -r choice
    echo
    case "$choice" in
      y|Y )
        build_style_css
        ;;
      n|N|"" )
        ;;
        * )
        clear
        check_style_file
        ;;
    esac
  else
    build_style_css
  fi
}

build_style_css() {
  cd ${BACKEND_WORKSPACE}
  # Start npm build to generate style.css file"
  log "Running npm run build..."
  npm run build 2>&1 >/dev/null
  if [ $? -eq 0 ]; then
    success "Build with success!\n\n"

    # check if style.css file exist
    log -n "Checking style file..."
    if [[ ! -f "$STYLE_FILE" ]]; then
        echo
        error "'$STYLE_FILE' file does not exist. Exiting..."
        exit
    else
        success "Everything seems okay!\n"
      fi
  else
    echo
    error "Error running command. Please check logs above."
    exit
  fi

  cd .. # Jump back to root folder
}

install_composer() {
  cd ${BACKEND_WORKSPACE}
  if ! $(composer -V &> /dev/null) ; then
    warning "Warning: Composer not installed. Installing..."
    log "(In order to install the Composer will be asked to input your user password)"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    check_script
    rm composer-setup.php
  fi

  if [[ -f "composer.lock" ]]; then
    log -n "Removing old composer.lock file..."
    rm composer.lock
    check_script
  fi

  log -n "Running composer install..."
#  composer install https://getcomposer.org/doc/01-basic-usage.md#installing-without-composer-lock
  composer update --quiet
  check_script

  cd .. # Jump back to root folder
}

start_wordpress() {
  # check if wordpress docker image is running
  WORDPRESS_CONTAINER=$(docker inspect -f '{{.State.Running}}' "${DOCKER_CONTAINER_NAME}")

  if [[ "$WORDPRESS_CONTAINER" != "true" ]]; then
      warning "Wordpress container not running."
      log "Starting WordPress container..."
      docker-compose up -d
      if [ $? -eq 0 ]; then
        success "Container started successfully"
      else
        echo
        error "Error running command. Please check logs above."
        exit
      fi
  else
      success "WordPress container is started"
  fi

  # Checking WP for handle connection
  log -n "Waiting for WP connections ready (can take several minutes on first setup)..."
  while :; do
    # 1. Execute a command and log the console output in a file
    log=$(docker logs ${DOCKER_CONTAINER_NAME} 2>&1 | grep "ready to handle connections")
    # Once I find the string I am looking for I want to exit the loop
    [[ -n "$log" ]] && { success "Done!"; break; }
    # 3. If the string is not present I want to execute the same command again until I find the String I am looking for
    # add ex. sleep 0.1 for the loop to delay a little bit, not to use 100% cpu
    sleep 1
    log -n "."
  done
}

check_script() {
    if [ $? -eq 0 ]; then
        success "Done!\n"
    else
        echo
        error "Error running command. Please check logs above."
        exit 1
    fi
}

add_dummy_data_wordpress() {
  info "
     __          _______    _____       _ _
     \ \        / /  __ \  |_   _|     (_) |
      \ \  /\  / /| |__) |   | |  _ __  _| |_
       \ \/  \/ / |  ___/    | | | '_ \| | __|
        \  /\  /  | |       _| |_| | | | | |_
         \/  \/   |_|      |_____|_| |_|_|\__|

               Installing dummy data

      "

  # Export env variables
  export $(cat .env)
  log "Initiate WP setup... "

  # create uploads folder
  log -n "Create uploads folder... "
  docker exec ${DOCKER_CONTAINER_NAME} mkdir -p wp-content/uploads
  check_script

  dummy_uploads

  # install Core and add a new user admin
  log -n "Install WordPress Core... "
  docker exec ${DOCKER_CONTAINER_NAME} wp core install --title="sample" --url="http://app.local" --admin_user=${WORDPRESS_ADMIN_USER} --admin_password=${WORDPRESS_ADMIN_PASSWORD} --admin_email=${WORDPRESS_ADMIN_EMAIL} --skip-email 2>&1 >/dev/null
  check_script

  # remove unused plugins
  log " -- Remove unused plugins --"
  any_plugin_removed=0
  # Hello plugin
  docker exec ${DOCKER_CONTAINER_NAME} wp plugin is-installed hello 2>&1 >/dev/null
  if [[ $? -eq 0 ]]; then
        log -n "  * Removing Hello plugin... "
        docker exec ${DOCKER_CONTAINER_NAME} wp plugin uninstall hello 2>&1 >/dev/null
        check_script
        any_plugin_removed=1
  fi
  # Akismet plugin
  docker exec ${DOCKER_CONTAINER_NAME} wp plugin is-installed akismet 2>&1 >/dev/null
  if [[ $? -eq 0 ]]; then
        log -n "  * Removing Akismet plugin... "
        docker exec ${DOCKER_CONTAINER_NAME} wp plugin uninstall akismet 2>&1 >/dev/null
        check_script
        any_plugin_removed=1
  fi

  if [[ ${any_plugin_removed} -eq 0 ]]; then
    success "No plugins needs to be removed.\n"
  fi

  dummy_seo_plugin

  # activate theme
  log -n "Checking if theme is already active... "
  docker exec ${DOCKER_CONTAINER_NAME} wp theme is-active nc-theme 2>&1 >/dev/null
  if [[ $? -eq 0 ]]; then
      success "No activation needed!"
  else
      warning "Not activated!"
      log -n "Activating theme... "
      docker exec ${DOCKER_CONTAINER_NAME} wp theme activate nc-theme 2>&1 >/dev/null
      check_script
  fi

  # Remove unused themes
  log " -- Remove unused themes -- "
  any_theme_removed=0

  # twentyseventeen theme
  docker exec ${DOCKER_CONTAINER_NAME} wp theme is-installed twentyseventeen 2>&1 >/dev/null
  if [[ $? -eq 0 ]]; then
        log -n "  * Removing twentyseventeen theme... "
        docker exec ${DOCKER_CONTAINER_NAME} wp theme uninstall twentyseventeen 2>&1 >/dev/null
        check_script
        any_theme_removed=1
  fi

  # twentynineteen theme
  docker exec ${DOCKER_CONTAINER_NAME} wp theme is-installed twentynineteen 2>&1 >/dev/null
  if [[ $? -eq 0 ]]; then
        log -n "  * Removing twentynineteen theme... "
        docker exec ${DOCKER_CONTAINER_NAME} wp theme uninstall twentynineteen 2>&1 >/dev/null
        check_script
        any_theme_removed=1
  fi

  # twentytwenty theme
  docker exec ${DOCKER_CONTAINER_NAME} wp theme is-installed twentytwenty 2>&1 >/dev/null
  if [[ $? -eq 0 ]]; then
        log -n "  * Removing twentytwenty theme... "
        docker exec ${DOCKER_CONTAINER_NAME} wp theme uninstall twentytwenty 2>&1 >/dev/null
        check_script
        any_theme_removed=1
  fi

  if [[ ${any_theme_removed} -eq 0 ]]; then
    success "No themes needs to be removed.\n"
  fi

  dummy_db_content
}

dummy_uploads() {
if [[ -f "_dev/local.config/sample-data/uploads.zip" ]]; then
        if [[ ${ARGUMENT} == "--select-dummy-data" ]]; then
            warning -n "Do you want to install uploads dummy content [Y/n]?"
            read -p "" -n 1 -r choice
            echo
            case "$choice" in
              y|Y|"" )
                install_dummy_uploads
                ;;
              n|N )
                ;;
              * )
                clear
                dummy_uploads
                ;;
            esac
        else
            install_dummy_uploads
        fi
  fi
}

install_dummy_uploads() {
      # Copy uploads folder
      log -n "Copy uploads folder..."
      docker exec ${DOCKER_CONTAINER_NAME} cp /tmp/sample-data/uploads.zip wp-content/uploads
      check_script

      # Extract uploads folder
      log -n "Extract uploads folder..."
      docker exec ${DOCKER_CONTAINER_NAME} unzip  -qq -o wp-content/uploads/uploads.zip -d wp-content/uploads
      check_script

    #   Delete uploads.zip file
      log -n "Delete temporary uploads.zip file..."
      docker exec ${DOCKER_CONTAINER_NAME} rm wp-content/uploads/uploads.zip
      check_script
}

dummy_seo_plugin() {
    if [[ ${ARGUMENT} == "--select-dummy-data" ]]; then
        warning -n "Do you want to install wordpress-seo plugin [Y/n]?"
        read -p "" -n 1 -r choice
        echo
        case "$choice" in
          y|Y|"" )
            install_dummy_seo_plugin
            ;;
          n|N )
            ;;
          * )
            clear
            dummy_seo_plugin
            ;;
        esac
    else
        install_dummy_seo_plugin
    fi
}

install_dummy_seo_plugin() {
  # install plugins
  log -n "Install WordPress-SEO plugin... "
  docker exec ${DOCKER_CONTAINER_NAME} wp plugin install wordpress-seo 2>&1 >/dev/null
  check_script

  # activate plugins
  log -n "Activate WordPress-SEO plugin... "
  docker exec ${DOCKER_CONTAINER_NAME} wp plugin activate wordpress-seo 2>&1 >/dev/null
  check_script
}

dummy_db_content() {
    if [[ -f "_dev/local.config/sample-data/content.sql" ]]; then
        if [[ ${ARGUMENT} = ="--select-dummy-data" ]]; then
            warning -n "Do you want to install database dummy content [Y/n]?"
            read -p "" -n 1 -r choice
            echo
            case "$choice" in
              y|Y|"" )
                install_dummy_db_content
                ;;
              n|N )
                ;;
              * )
                clear
                dummy_db_content
                ;;
            esac
        else
            install_dummy_db_content
        fi
  fi
}

install_dummy_db_content() {
  # Import content into site
  log -n "Import site content... "
  docker exec ${DOCKER_CONTAINER_NAME} wp db import /tmp/sample-data/content.sql
  check_script
}

clean_all() {
  clear
  info "
     __          _______    _____       _ _
     \ \        / /  __ \  |_   _|     (_) |
      \ \  /\  / /| |__) |   | |  _ __  _| |_
       \ \/  \/ / |  ___/    | | | '_ \| | __|
        \  /\  /  | |       _| |_| | | | | |_
         \/  \/   |_|      |_____|_| |_|_|\__|

                    Cleaning theme

      "
  log "Stopping docker and removing files..."
  ## Stop docker and remove all the files
  docker-compose down -v --rmi local
  check_script

  log -n "Removing wordpress folder..."
  ## delete wordpress folder
  rm -rf ./_dev/wordpress-root
  check_script
}

setup() {
    info "
     __          _______    _____       _ _
     \ \        / /  __ \  |_   _|     (_) |
      \ \  /\  / /| |__) |   | |  _ __  _| |_
       \ \/  \/ / |  ___/    | | | '_ \| | __|
        \  /\  /  | |       _| |_| | | | | |_
         \/  \/   |_|      |_____|_| |_|_|\__|

                     Setup theme
            WordPress init local development
                     Version: $VERSION
      "
    checkout_submodules
    checkout_backend_develop
    checking_node_modules
    install_composer # needs sudo permission
    check_style_file
    start_wordpress
    add_dummy_data_wordpress

    success "\n\nAll setup was completed with success!!!\n\n"
}

__init__() {
case "$OPTION" in
  all)
    clear
    setup
    ;;
  fresh-install)
    clean_all
    remove_node_modules
    setup
    ;;
  install-dependencies)
    checking_node_modules
    install_composer
    ;;
  dummy-data)
    clear
    add_dummy_data_wordpress
    success "\n\nDummy data was imported with success!!!\n\n"
    ;;
  clean)
    clean_all
    ;;
  frontend)
    run_frontend
    ;;
  *)
    cli_help
    ;;
esac
}

OPTION=$1
ARGUMENT=$2

check_env_file
check_php_version
__init__

