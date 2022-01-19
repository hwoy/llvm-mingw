# Reject expansion of unset variables.
set -u

# Exit when a command fails.
if [ "${PS1:-}" == "" ]; then set -e; fi

source ../0_common_head.sh
PROJECTNAME=${PROJ}32-${_default_msvcrt}

export X_BUILD=i686-w64-mingw32
export X_HOST=${X_BUILD}
export X_TARGET=${X_BUILD}

export NEW_DISTRO_ROOT=/c/${PROJECTNAME}
export X_DISTRO_ROOT=/c/Temp/msys64/mingw32
#export X_DISTRO_ROOT=${NEW_DISTRO_ROOT}

export LDFLAGS=" -Wl,--large-address-aware"
export CFLAGS=" "
export CXXFLAGS=" "

source ../0_common.sh

# Print commands.
if [ "${PS1:-}" == "" ]; then set -x; fi

