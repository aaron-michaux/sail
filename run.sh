#!/bin/bash

set -e

PPWD="$(cd "$(dirname "$0")"; pwd)"

# ------------------------------------------------------------ Parse Commandline

CONFIG=asan
TARGET_FILE0=sail
TOOLCHAIN=gcc-11
FEEDBACK=0
NO_BUILD=0
GDB=0
BUILD_ONLY=0
BUILD_TESTS=0
BENCHMARK=0
BUILD_EXAMPLES=0
LTO=0
VALGRIND=0
PYTHON_BINDINGS=0
RULE=all

TARGET_FILE="$TARGET_FILE0"

while [ "$#" -gt "0" ] ; do
    
    # Compiler
    [ "$1" = "clang-9" ]   && TOOLCHAIN="clang-9.2.0" && shift && continue
    [ "$1" = "clang-10" ]  && TOOLCHAIN="clang-10.0.0" && shift && continue
    [ "$1" = "clang-11" ]  && TOOLCHAIN="clang-11.0.0" && shift && continue
    [ "$1" = "clang" ]     && TOOLCHAIN="clang-11.0.0" && shift && continue
    [ "$1" = "gcc-9" ]     && TOOLCHAIN="gcc-9"  && shift && continue
    [ "$1" = "gcc-10" ]    && TOOLCHAIN="gcc-10" && shift && continue
    [ "$1" = "gcc-11" ]    && TOOLCHAIN="gcc-11" && shift && continue
    [ "$1" = "gcc" ]       && TOOLCHAIN="gcc-11" && shift && continue
    [ "$1" = "emcc" ]      && TOOLCHAIN="emcc"   && shift && continue

    # Configuration
    [ "$1" = "asan" ]      && CONFIG=asan      && shift && continue
    [ "$1" = "usan" ]      && CONFIG=usan      && shift && continue
    [ "$1" = "tsan" ]      && CONFIG=tsan      && shift && continue
    [ "$1" = "debug" ]     && CONFIG=debug     && shift && continue
    [ "$1" = "valgrind" ]  && CONFIG=debug     && VALGRIND=1 && shift && continue
    [ "$1" = "gdb" ]       && CONFIG=debug     && GDB=1 && shift && continue
    [ "$1" = "release" ]   && CONFIG=release   && shift && continue
    
    # Other options
    [ "$1" = "clean" ]     && RULE="clean"     && shift && continue
    [ "$1" = "info" ]      && RULE="info"      && shift && continue
    [ "$1" = "verbose" ]   && FEEDBACK="1"     && shift && continue
    [ "$1" = "quiet" ]     && FEEDBACK="0"     && shift && continue
    [ "$1" = "lto" ]       && LTO="1"          && shift && continue
    [ "$1" = "no-lto" ]    && LTO="0"          && shift && continue
    [ "$1" = "build" ]     && BUILD_ONLY="1"   && shift && continue    
    [ "$1" = "test" ]      && BUILD_TESTS="1"  && BUILD_EXAMPLES=1 && shift && continue
    [ "$1" = "bench" ]     && BENCHMARK=1      && shift && continue
    [ "$1" = "examples" ]  && BUILD_EXAMPLES=1 && shift && continue

    [ "$1" = "--" ]        && break
    
    break
done

if [ "$TOOLCHAIN" = "emcc" ] ; then
    echo "emcc not supported... waiting for modules support" 1>&2
    exit 1
elif [ "${TOOLCHAIN:0:5}" = "clang" ] ; then
    echo "clang not supported... waiting for modules support" 1>&2
    exit 1
    export TOOL=clang
    export TOOL_VERSION="${TOOLCHAIN:6}"
elif [ "${toolchain:0:3}" = "gcc" ] ; then
    export TOOL=gcc
    export TOOL_VERSION="${TOOLCHAIN:4}"
fi

if [ "$BENCHMARK" = "1" ] && [ "$BUILD_TESTS" = "1" ] ; then
    echo "Cannot benchmark and build tests at the same time."
    exit 1
fi

# ---------------------------------------------------------------------- Execute

UNIQUE_DIR="${TOOL}-${TOOL_VERSION}-${CONFIG}"
[ "$BUILD_TESTS" = "1" ] && UNIQUE_DIR="test-${UNIQUE_DIR}"
[ "$LTO" = "1" ]         && UNIQUE_DIR="${UNIQUE_DIR}-lto"
[ "$BENCHMARK" = "1" ]   && UNIQUE_DIR="bench-${UNIQUE_DIR}"

export BUILDDIR="/tmp/build-${USER}/${TOOLCHAIN}-${CONFIG}/${TARGET_FILE}"
export TARGETDIR="build/${TOOLCHAIN}-${CONFIG}"

export TARGET="${TARGET_FILE}"
export TOOLCHAIN_NAME="${TOOLCHAIN}"
export TOOLCHAIN_CONFIG="${CONFIG}"
export STATIC_LIBCPP="0"
export VERBOSE="${FEEDBACK}"
export LTO="${LTO}"

export SRC_DIRECTORIES="src"

# if [ "$TOOLCHAIN" = "emcc" ] ; then
#     export SRC_DIRECTORIES="src/niggly/utils contrib"
#     export EXTRA_LINK="\$emcc_link_extra"
# else
#     export EXTRA_LINK="\$cli_link_extra"
# fi
# mkdir -p "$(dirname "$TARGET")"

if [ "$BUILD_TESTS" = "1" ] ; then
    export SRC_DIRECTORIES="${SRC_DIRECTORIES} testcases"
    export CFLAGS="${CFLAGS} -DCATCH_BUILD"
    export CXXFLAGS="${CXXFLAGS} -DCATCH_BUILD"
fi

if [ "$BUILD_EXAMPLES" = "1" ] ; then
    export SRC_DIRECTORIES="${SRC_DIRECTORIES} examples"
    export CFLAGS="$CFLAGS -Wno-unused-function "
    export CXXFLAGS="$CXXFLAGS -Wno-unused-function "
fi

if [ "$BENCHMARK" = "1" ] ; then
    export SRC_DIRECTORIES="${SRC_DIRECTORIES} benchmark"
    export CFLAGS="${CFLAGS} -DBENCHMARK_BUILD"
    export CXXFLAGS="${CXXFLAGS} -DBENCHMARK_BUILD"
    export LDFLAGS="-lpthread -L/usr/local/lib -lbenchmark ${LDFLAGS}"
fi

export VERSION_HASH="$(git log | grep commit | head -n 1 | awk '{ print $2 }')"
export VERSION_CRC32="$(echo -n $VERSION_HASH | gzip -c | tail -c8 | hexdump -n4 -e '"%u"')"
export VERSION_DEFINES="-DVERSION_HASH=\"\\\"$VERSION_HASH\"\\\" -DVERSION_CRC32=${VERSION_CRC32}u"
export CFLAGS="$CFLAGS $VERSION_DEFINES"
export CXXFLAGS="$CXXFLAGS $VERSION_DEFINES"

# ---- Run Mobius

[ "$TARGET_FILE" = "build.ninja" ] && exit 0

[ "$(uname)" = "Darwin" ] && NPROC="$(sysctl -n hw.ncpu)" || NPROC="$(nproc)"

cleanup_gcm()
{
    rm -f "$PPWD/gcm.cache"
}

do_make()
{
    cleanup_gcm
    trap cleanup_gcm EXIT   
    mkdir -p "$BUILDDIR/gcm.cache"
    ln -s "$BUILDDIR/gcm.cache" "$PPWD/gcm.cache"

    make -j $NPROC $RULE
    RET="$?"
    if [ "$RET" != "0" ] ; then exit $RET ; fi
}
do_make

[ "$RULE" = "clean" ] && exit 0 || true
[ "$RULE" = "info" ] && exit 0 || true
[ "$BUILD_ONLY" = "1" ] && exit 0 || true

# ---- If we're building the executable (TARGET_FILE0), then run it

if [ "$TARGET_FILE" = "$TARGET_FILE0" ] ; then

    export LSAN_OPTIONS="suppressions=$PPWD/project-config/lsan.supp"
    export ASAN_OPTIONS="protect_shadow_gap=0,detect_leaks=0"

    export TF_CPP_MIN_LOG_LEVEL="1"
    export AUTOGRAPH_VERBOSITY="1"

    export MallocNanoZone=0 
    PRODUCT="$TARGETDIR/$TARGET_FILE"
        
    if [ "$GDB" = "1" ] ; then        
        gdb -ex run -silent -return-child-result -statistics --args "$PRODUCT" "$@"
        exit $?
        
    elif [ "$VALGRIND" = "1" ] ; then        
        valgrind --tool=memcheck --leak-check=full --track-origins=yes --verbose --log-file=valgrind.log --gen-suppressions=all "$PRODUCT" "$@"
        exit $?

    else
        "$PRODUCT" "$@"
        exit $?
        
    fi
             
fi

