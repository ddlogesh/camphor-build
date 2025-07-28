#!/usr/bin/env bash
set -e

WORKDIR=$PWD
CAMPHOR_HOME=$HOME/.camphor
SYSROOT=$(emcc -v -c - 2>&1 | sed -n 's/.*--sysroot=\([^ ]*\).*/\1/p')

# zlib-ng
cd "$WORKDIR/zlib-ng"
rm -rf build
mkdir build && cd build

emcmake cmake .. \
  -DCMAKE_FIND_ROOT_PATH="$SYSROOT;$CAMPHOR_HOME" \
  -DCMAKE_INSTALL_PREFIX="$CAMPHOR_HOME" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DZLIB_COMPAT=ON \
  -DZLIB_ENABLE_TESTS=OFF \
  -DWITH_GTEST=OFF
emmake make -j8
emmake make install

# minizip-ng
cd "$WORKDIR/minizip-ng"
rm -rf build
mkdir build && cd build

emcmake cmake .. \
  -DCMAKE_FIND_ROOT_PATH="$SYSROOT;$CAMPHOR_HOME" \
  -DCMAKE_INSTALL_PREFIX="$CAMPHOR_HOME" \
  -DCMAKE_BUILD_TYPE=Release \
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
emmake make -j8
emmake make install

# expat
cd "$WORKDIR/libexpat/expat"
rm -rf build
mkdir build && cd build

emcmake cmake .. \
  -DCMAKE_FIND_ROOT_PATH="$SYSROOT;$CAMPHOR_HOME" \
  -DCMAKE_INSTALL_PREFIX="$CAMPHOR_HOME" \
  -DCMAKE_BUILD_TYPE=Release \
  -DEXPAT_BUILD_DOCS=OFF \
  -DEXPAT_BUILD_EXAMPLES=OFF \
  -DEXPAT_BUILD_TESTS=OFF \
  -DEXPAT_SHARED_LIBS=OFF
emmake make -j8
emmake make install

# xlsxio
cd "$WORKDIR/xlsxio"
rm -rf build
mkdir build && cd build

emcmake cmake .. \
  -DCMAKE_FIND_ROOT_PATH="$SYSROOT;$CAMPHOR_HOME" \
  -DCMAKE_INSTALL_PREFIX="$CAMPHOR_HOME" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_STATIC=ON \
  -DBUILD_SHARED=OFF \
  -DBUILD_TOOLS=OFF \
  -DBUILD_EXAMPLES=OFF
emmake make -j8
emmake make install

# sqlite
cd "$WORKDIR/sqlite"
rm -rf build
mkdir build && cd build

../configure
emmake make sqlite3.c
