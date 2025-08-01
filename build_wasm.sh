#!/usr/bin/env bash
set -e

WORKDIR=$PWD
CAMPHOR_HOME=$HOME/.camphor

BUILD_TYPE="wasm"
if [[ "$1" == "--native" ]]; then
  BUILD_TYPE="native"
fi

if [[ "$BUILD_TYPE" == "wasm" ]]; then
  SYSROOT=$(emcc -v -c - 2>&1 | sed -n 's/.*--sysroot=\([^ ]*\).*/\1/p')
  CMAKE_CMD="emcmake cmake"
  MAKE_CMD="emmake make"
else
  SYSROOT="/usr/local"
  CMAKE_CMD="cmake"
  MAKE_CMD="make"
fi

COMMON_CMAKE_FLAGS=(
  -DCMAKE_FIND_ROOT_PATH="$CAMPHOR_HOME/$BUILD_TYPE;$SYSROOT"
  -DCMAKE_INSTALL_PREFIX="$CAMPHOR_HOME/$BUILD_TYPE"
  -DCMAKE_BUILD_TYPE=Release
)

# zlib-ng
cd "$WORKDIR/zlib-ng"
rm -rf build
mkdir build && cd build

$CMAKE_CMD .. \
  "${COMMON_CMAKE_FLAGS[@]}" \
  -DBUILD_SHARED_LIBS=OFF \
  -DZLIB_COMPAT=ON \
  -DZLIB_ENABLE_TESTS=OFF \
  -DWITH_GTEST=OFF
$MAKE_CMD -j8
$MAKE_CMD install

# minizip-ng
cd "$WORKDIR/minizip-ng"
rm -rf build
mkdir build && cd build

$CMAKE_CMD .. \
  "${COMMON_CMAKE_FLAGS[@]}" \
  -DBUILD_SHARED_LIBS=OFF \
  -DMZ_COMPAT=ON \
  -DMZ_FETCH_LIBS=OFF \
  -DMZ_ZLIB=ON \
  -DMZ_BZIP2=OFF \
  -DMZ_LZMA=OFF \
  -DMZ_ZSTD=OFF \
  -DMZ_LIBCOMP=OFF \
  -DMZ_OPENSSL=OFF \
  -DMZ_PKCRYPT=OFF \
  -DMZ_WZAES=OFF \
  -DMZ_LIBBSD=OFF \
  -DMZ_ICONV=OFF
$MAKE_CMD -j8
$MAKE_CMD install

# expat
cd "$WORKDIR/libexpat/expat"
rm -rf build
mkdir build && cd build

$CMAKE_CMD .. \
  "${COMMON_CMAKE_FLAGS[@]}" \
  -DEXPAT_BUILD_DOCS=OFF \
  -DEXPAT_BUILD_EXAMPLES=OFF \
  -DEXPAT_BUILD_TESTS=OFF \
  -DEXPAT_SHARED_LIBS=OFF
$MAKE_CMD -j8
$MAKE_CMD install

# xlsxio
cd "$WORKDIR/xlsxio"
rm -rf build
mkdir build && cd build

$CMAKE_CMD .. \
  "${COMMON_CMAKE_FLAGS[@]}" \
  -DBUILD_STATIC=ON \
  -DBUILD_SHARED=OFF \
  -DBUILD_TOOLS=OFF \
  -DBUILD_EXAMPLES=OFF
$MAKE_CMD -j8
$MAKE_CMD install

# sqlite
cd "$WORKDIR/sqlite"
rm -rf build
mkdir build && cd build

../configure
$MAKE_CMD sqlite3.c
