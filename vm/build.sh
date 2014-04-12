#!/bin/bash

SELF=$(basename $0)
BASE=$(cd $(dirname $0); pwd -P)
CLEAN=0
WORKERS=1
WIN=0

function usage {
  cat <<EOF
Usage: $SELF [options]
Options:
  --build=[release|debug] Specifies the build type. If not set both release and 
                          debug versions of the libraries will be built.
  --target=...            Specifies the target(s) to build for. Supported 
                          targets are macosx-x86, ios-x86, ios-thumbv7, 
                          linux-x86. Enclose multiple targets in quotes and 
                          seperate with spaces or specify --target multiple 
                          times. If not set the current host OS determines the
                          targets. macosx-x86, ios-x86 and ios-thumbv7 on MacOSX
                          and linux-x86 on Linux.
  --clean                 Cleans the build dir before starting the build.
  --help                  Displays this information and exits.
EOF
  exit $1
}

while [ "${1:0:2}" = '--' ]; do
  NAME=${1%%=*}
  VALUE=${1#*=}
  case $NAME in
    '--target') TARGETS="$TARGETS $VALUE" ;;
    '--clean') CLEAN=1 ;;
    '--build') BUILDS="$BUILDS $VALUE" ;;
    '--help')
      usage 0
      ;;
    *)
      echo "Unrecognized option or syntax error in option '$1'"
      usage 1
      ;;
  esac
  shift
done

OS=$(uname)

if [ "x$TARGETS" = 'x' ]; then
  case $OS in
  Darwin)
    TARGETS="macosx-x86 ios-x86 ios-thumbv7"
    ;;
  Linux)
    TARGETS="linux-x86"
    ;;
  Windows)
    TARGETS="windows-x86"
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
  esac
fi
if [ "x$BUILDS" = 'x' ]; then
  BUILDS="debug release"
fi

# Validate targets
for T in $TARGETS; do
  if [[ $T =~ (windows)-(x86) ]] ; then
    WIN=1
  fi
  if ! [[ $T =~ (macosx|ios|windows|linux)-(x86|thumbv7) ]] ; then
    echo "Unsupported target: $T"
    exit 1
  fi
done

# Validate build types
for B in $BUILDS; do
  if ! [[ $B =~ (debug|release) ]] ; then
    echo "Unsupported build type: $B"
    exit 1
  fi
done

mkdir -p "$BASE/target/build"
if [ "$CLEAN" = '1' ]; then
  for T in $TARGETS; do
    for B in $BUILDS; do
      rm -rf "$BASE/target/build/$T-$B"
    done
  done
fi

case $OS in
Darwin)
  if xcrun -f clang &> /dev/null; then
    CC=$(xcrun -f clang)
  else
    CC=$(which clang)
  fi
  if xcrun -f clang++ &> /dev/null; then
    CXX=$(xcrun -f clang++)
  else
    CXX=$(which clang++)
  fi
;;
Linux)
  if [ "$WIN" = '1' ]; then
    CC=$(which i686-w64-mingw32-gcc)
    CXX=$(which i686-w64-mingw32-g++)
    WORKERS=1
  else
    CC=$(which gcc)
    CXX=$(which g++)
  fi
;;
*)
  echo "Unsupported OS compiler: $OS"
  exit 1
  ;;
esac

for T in $TARGETS; do
  OS=${T%%-*}
  ARCH=${T#*-}
  for B in $BUILDS; do
    BUILD_TYPE=$B
    mkdir -p "$BASE/target/build/$T-$B"
    rm -rf "$BASE/binaries/$OS/$ARCH/$B"
	bash -c "cd '$BASE/target/build/$T-$B'; cmake -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DOS=$OS -DARCH=$ARCH '$BASE'; make -j $WORKERS install"
    R=$?
    if [[ $R != 0 ]]; then
      echo "$T-$B build failed"
      exit $R
    fi
  done
done
