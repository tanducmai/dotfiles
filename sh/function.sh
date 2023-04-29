#!/bin/bash

# ======================================================================================
#
#         FILE:  function.sh
#       AUTHOR:  Henry Mai <henryfromvietnam@gmail.com>
#      COMPANY:  ---
#        USAGE:  Source this file in .bashrc
#  DESCRIPTION:  User-defined functions
#      CREATED:  May 26, 2022
#
# ======================================================================================

# """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#              _____ _   _ _   _  ____ _____ ___ ___  _   _ ____
#              |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___|
#              | |_  | | | |  \| | |     | |  | | | | |  \| \___ \
#              |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
#              |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/
#
# """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# ==== FUNCTION ========================================================================
#         NAME: gi
#  DESCRIPTION: Run gitignore.io from the command line with gi
#   PARAMETERS: Operating systems, programming languages and IDE input types
#     EXAMPLES: gi python >> .git/info/exclude
# ======================================================================================
gi () { curl -sL https://www.toptal.com/developers/gitignore/api/"$1" ; }


# ==== FUNCTION ========================================================================
#         NAME: py-browse
#  DESCRIPTION: Code browser
#   PARAMETERS: --- (defauts to `pwd`)
#     EXAMPLES: py-browse
# ======================================================================================
py-browse () { textual run ~/.files/py/code_browser/code_browser.py ; }


# ==== FUNCTION ========================================================================
#         NAME: py-calc
#  DESCRIPTION: Calculator stimulator
#   PARAMETERS: ---
#     EXAMPLES: py-calc
# ======================================================================================
py-calc () { textual run ~/.files/py/calculator/calculator.py ; }


# ==== FUNCTION ========================================================================
#         NAME: py-calendar
#  DESCRIPTION: Display calendar of a year
#   PARAMETERS: year
#     EXAMPLES: py-calendar
# ======================================================================================
py-calendar () { python3 ~/.files/py/print_calendar.py "$1" ; }


# ==== FUNCTION ========================================================================
#         NAME: py-dict
#  DESCRIPTION: Dictionary stimulator
#   PARAMETERS: ---
#     EXAMPLES: py-dict
# ======================================================================================
py-dict () { textual run ~/.files/py/dictionary/dictionary.py ; }


# ==== FUNCTION ========================================================================
#         NAME: py-download
#  DESCRIPTION: wget stimulator
#   PARAMETERS: URL(s)
#     EXAMPLES: py-download
# ======================================================================================
py-download () { python3 ~/.files/py/downloader.py "$@" ; }


# ==== FUNCTION ========================================================================
#         NAME: py-tree
#  DESCRIPTION: Tree stimulator
#   PARAMETERS: path/to/directory {defaulting to `pwd`}
#     EXAMPLES: py-tree
#               py-tree ~/.vim
# ======================================================================================
py-tree () { python3 ~/.files/py/tree.py "$1" ; }


# ==== FUNCTION ========================================================================
#         NAME: upgrade
#  DESCRIPTION: Upgrade linux, python, and pip packages.
#   PARAMETERS: ---
#     EXAMPLES: upgrade
# ======================================================================================
upgrade () {
  clear
  printf "Check for updates to the Operating System ...\n --------------------\n"
  sudo apt update
  yes | sudo apt full-upgrade
  yes | sudo apt autoremove
  yes | sudo apt autoclean
  printf " --------------------\nCheck for updates to vim plugins ...\n"
  git -C ~/.vim submodule update --init --recursive --remote
  printf " --------------------\nCheck for updates to submodules within ~/.files ...\n"
  git -C ~/.files submodule update --init --recursive --remote
  printf " --------------------\nCheck for updates to pip packages ...\n"
  python -m pip install --upgrade pip
  pip-review --local --auto
  cowsay You are up to date!
}


# ==== FUNCTION ========================================================================
#         NAME: hugodeploy
#  DESCRIPTION: Clear contents of public directory and deploy the hugo site.
#   PARAMETERS: ---
#     EXAMPLES: hugolive
# ======================================================================================
# hugodeploy () {
#   if [ -f ".hugo_build.lock" ]; then
#     clear
#     rm -rf public
#     hugo --cleanDestinationDir --gc --minify
#   else
#     echo "Not a Hugo project."
#   fi
# }


# ==== FUNCTION ========================================================================
#         NAME: hugolive
#  DESCRIPTION: Keep publishing preview hugo site.
#   PARAMETERS: ---
#     EXAMPLES: hugolive
# ======================================================================================
hugolive () {
  if [ -f ".hugo_build.lock" ]; then
    if lsof -i:1313 ; then
      echo ---------------
      echo "ERROR: Port 1313 is in use."
    else
      clear
      hugo server --disableFastRender --buildDrafts --buildExpired --buildFuture \
        --forceSyncStatic --navigateToChanged &
    fi
  else
    echo "Not a Hugo project."
  fi
}


# ==== FUNCTION ========================================================================
#         NAME: autopep8
#  DESCRIPTION: Format python file(s) according to PEP-8 style
#   PARAMETERS: Python file(s)
#     EXAMPLES: autopep8
# ======================================================================================
pep8 () { printf "Finish formatting ...\n" && autopep8 --in-place -r -a -a "$1" ; }


# ==== FUNCTION ========================================================================
#         NAME: gpull
#  DESCRIPTION: Print a message while performing a git pull.
#   PARAMETERS: ---
#     EXAMPLES: gpull
# ======================================================================================
gpull () {
  clear
  printf "Wait for remote content to be fetched from Github ...\n--------------------\n"
  git pull
}


# ==== FUNCTION ========================================================================
#         NAME: gpush
#  DESCRIPTION: Print a message while performing a git push.
#   PARAMETERS: ---
#     EXAMPLES: gpush
# ======================================================================================
gpush () {
  clear
  printf "Wait for the local commits to be pushed to GitHub ...\n--------------------\n"
  git push
}


# ==== FUNCTION ========================================================================
#         NAME: update_gpg_keys
#  DESCRIPTION: Update GPG keys
#   PARAMETERS: Commands
#     EXAMPLES: update_gpg_keys
# ======================================================================================
update_gpg_keys() {
  cd /tmp || exit
  git clone https://github.com/tanducmai/gpg-keys
  cd gpg-keys || exit
  uid="$(gpg --list-public-keys | tail -n 3 | head -n 1 | \
    grep -oP '(?<=<).*?(?=>)')"
  gpg --export --armor "$uid" > /tmp/gpg-keys/pubkey.asc
  gpg --export-secret-keys --armor "$uid" > /tmp/gpg-keys/privkey.asc
  if [[ "$(git status --porcelain --untracked-files=no)" ]]; then
    git add pubkey.asc privkey.asc
    git commit -m 'Update keys'
    git push -u origin master
  fi
  rm -frv /tmp/gpg-keys
}


# ==== FUNCTION ========================================================================
#         NAME: find_version
#  DESCRIPTION: Equivalent to `package --version`.
#   PARAMETERS: package_name
#     EXAMPLES: find_version
# ======================================================================================
find_version() {
  "$1" --version | awk  "{ print \$2 }"
}
