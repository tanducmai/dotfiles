#!/usr/bin/env sh

cat 1>&2 <<-EOF
  This script is not to run on any system.
  Anh K. Huynh adds this banner to prevent script from being used.

  The original script is here
    https://github.com/tj/n/blob/0895ea3e50cbad95ce67460a906323610f1f40a8/bin/n
EOF

exit 0

# Library version

VERSION="0.7.3"
N_PREFIX=${N_PREFIX-/usr/local}
VERSIONS_DIR=$N_PREFIX/n/versions

#
# Log the given <msg ...>
#

log() {
  printf "\033[90m...\033[0m $@\n"
}

#
# Exit with the given <msg ...>
#

abort() {
  printf "\033[31mError: $@\033[0m\n" && exit 1
}

# setup

test -d $VERSIONS_DIR || mkdir -p $VERSIONS_DIR

if ! test -d $VERSIONS_DIR; then
  abort "Failed to create versions directory ($VERSIONS_DIR), do you have permissions to do this?"
fi

# curl / wget support

GET=

# wget support (Added --no-check-certificate for Github downloads)
which wget > /dev/null && GET="wget --no-check-certificate -q -O-"

# curl support
which curl > /dev/null && GET="curl -# -L"

# Ensure we have curl or wget

test -z "$GET" && abort "curl or wget required"

#
# Output usage information.
#

display_help() {
  cat <<-help

  Usage: n [options] [COMMAND] [config]

  Commands:

    n                            Output versions installed
    n latest [config ...]        Install or activate the latest node release
    n stable [config ...]        Install or activate the latest stable node release
    n <version> [config ...]     Install and/or use node <version>
    n custom <version> <tarball> [config ...]  Install custom node <tarball> with [args ...]
    n use <version> [args ...]   Execute node <version> with [args ...]
    n npm <version> [args ...]   Execute npm <version> with [args ...]
    n bin <version>              Output bin path for <version>
    n rm <version ...>           Remove the given version(s)
    n --latest                   Output the latest node version available
    n --stable                   Output the latest stable node version available
    n ls                         Output the versions of node available

  Options:

    -V, --version   Output current version of n
    -h, --help      Display help information

  Aliases:

    -       rm
    which   bin
    use     as
    list    ls
    custom  c

help
  exit 0
}

#
# Output n version.
#

display_n_version() {
  echo $VERSION && exit 0
}

#
# Check for installed version, and populate $active
#

check_current_version() {
  which node &> /dev/null
  if test $? -eq 0; then
    active=`node --version`
    active=${active#v}
  fi
}

#
# Display current node --version
# and others installed.
#

display_versions() {
  check_current_version
  for dir in $VERSIONS_DIR/*; do
    local version=${dir##*/}
    local config=`test -f $dir/.config && cat $dir/.config`
    if test "$version" = "$active"; then
      printf "  \033[32m??\033[0m $version \033[90m$config\033[0m\n"
    else
      printf "    $version \033[90m$config\033[0m\n"
    fi
  done
}

#
# Install node <version> [config ...]
#

install_node() {
  local version=$1; shift
  local config=$@
  check_current_version

  # remove "v"
  version=${version#v}

  # activate
  local dir=$VERSIONS_DIR/$version
  if test -d $dir; then
    # symlink everything, purge old copies or symlinks
    for d in bin lib share include; do
      rm -rf $N_PREFIX/$d
      ln -s $dir/$d $N_PREFIX/$d
    done
  # install
  else
    local tarball="node-v$version.tar.gz"
    local url="http://nodejs.org/dist/$tarball"

    # >= 0.5.x
    local minor=$(echo $version | cut -d '.' -f 2)
    test $minor -ge "5" && url="http://nodejs.org/dist/v$version/$tarball"

    install_tarball $version $url $config
  fi
}

#
# Install node <version> <tarball> [config ...]
#

install_tarball() {
  local version=$1
  local url=$2; shift 2
  local config=$@

  # remove "v"
  version=${version#v}

  local dir=$VERSIONS_DIR/$version
  local tarball="node-v$version.tar.gz"
  local logpath="/tmp/n.log"

  # create build directory
  mkdir -p $N_PREFIX/n/node-v$version

  # fetch and unpack
  cd $N_PREFIX/n/node-v$version \
    && $GET $url | tar xz --strip-components=1 > $logpath 2>&1

  # see if things are alright
  if test $? -gt 0; then
    rm $tarball
    echo "\033[31mError: installation failed\033[0m"
    echo "  node version $version does not exist,"
    echo "  n failed to fetch the tarball,"
    echo "  or tar failed. Try a different"
    echo "  version or view $logpath to view"
    echo "  error details."
    exit 1
  fi

  cd "$N_PREFIX/n/node-v$version" \
    && ./configure --prefix $VERSIONS_DIR/$version $config\
    && JOBS=4 make install \
    && cd .. \
    && cleanup $version \
    && mkdir -p $dir \
    && echo $config > "$dir/.config" \
    && n $version \
    && ln -s "$N_PREFIX/n/versions/$version" "$N_PREFIX/n/current"
}

#
# Cleanup after the given <version>
#

cleanup() {
  local version=$1
  local dir="node-v$version"

  if test -d $dir; then
    log "removing source"
    rm -fr $dir
  fi

  if test -f "$dir.tar.gz"; then
    log "removing tarball"
    rm -fr "$dir.tar.gz"
  fi
}

#
# Remove <version ...>
#

remove_version() {
  test -z $1 && abort "version(s) required"
  local version=${1#v}
  while test $# -ne 0; do
    rm -rf $VERSIONS_DIR/$version
    shift
  done
}

#
# Output bin path for <version>
#

display_bin_path_for_version() {
  test -z $1 && abort "version required"
  local version=${1#v}
  local bin=$VERSIONS_DIR/$version/bin/node
  if test -f $bin; then
    printf $bin
  else
    abort "$1 is not installed"
  fi
}

#
# Execute the given <version> of node
# with [args ...]
#

execute_with_version() {
  test -z $1 && abort "version required"
  local version=${1#v}
  local bin=$VERSIONS_DIR/$version/bin/node

  shift # remove version

  if test -f $bin; then
    $bin $@
  else
    abort "$version is not installed"
  fi
}

#
# Execute the given <version> of npm
# with [args ...]
#

execute_with_npm_version() {
  test -z $1 && abort "version required"
  local version=${1#v}
  local bin=$VERSIONS_DIR/$version/bin

  shift # remove version

  if test -f $bin/npm; then
    $bin/node $bin/npm $@
  else
    abort "npm is not installed, node.js version must be greater than or equal to 0.6.3"
  fi
}

#
# Display the latest node release version.
#

display_latest_version() {
  $GET 2> /dev/null http://nodejs.org/dist/ \
    | egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
    | sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
    | tail -n1
}

#
# Display the latest stable node release version.
#

display_latest_stable_version() {
  $GET 2> /dev/null http://nodejs.org/dist/ \
    | egrep -o '[0-9]+\.\d*[02468]\.[0-9]+' \
    | sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
    | tail -n1
}

#
# Display the versions of node available.
#

list_versions() {
  check_current_version
  local versions=""
  versions=`$GET 2> /dev/null http://nodejs.org/dist/ \
    | egrep -o '[0-9]+\.[0-9]+\.[0-9]+' \
    | sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
    | awk '{ print "  " $1 }'`

  for v in $versions; do
    if test "$active" = "$v"; then
      printf "  \033[32m??\033[0m $v \033[0m\n"
    else
      if test -d $VERSIONS_DIR/$v; then
        printf "  * $v \033[0m\n"
      else
        printf "    $v\n"
      fi
    fi
  done
}

# Handle arguments

if test $# -eq 0; then
  display_versions
else
  while test $# -ne 0; do
    case $1 in
      -V|--version) display_n_version ;;
      -h|--help|help) display_help ;;
      --latest) display_latest_version $2; exit ;;
      --stable) display_latest_stable_version $2; exit ;;
      bin|which) display_bin_path_for_version $2; exit ;;
      as|use) shift; execute_with_version $@; exit ;;
      npm) shift; execute_with_npm_version $@; exit ;;
      rm|-) remove_version $2; exit ;;
      latest) install_node `n --latest`; exit ;;
      stable) install_node `n --stable`; exit ;;
      ls|list) list_versions $2; exit ;;
      c|custom) shift; install_tarball $@; exit ;;
      *) install_node $@; exit ;;
    esac
    shift
  done
fi
