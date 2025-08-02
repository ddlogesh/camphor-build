#!/usr/bin/env bash
set -e

WORKDIR=$PWD
CAMPHOR_HOME=$HOME/.camphor

BUILD_TYPE="wasm"
PROJECT_FLAGS=()
ALL_PROJECTS=(zlib-ng minizip-ng libexpat xlsxio sqlite)

for arg in "$@"; do
  case $arg in
    --native)
      BUILD_TYPE="native"
      ;;
    --*)
      PROJECT_FLAGS+=("${arg:2}")
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

if [ ${#PROJECT_FLAGS[@]} -eq 0 ]; then
  PROJECT_FLAGS=("${ALL_PROJECTS[@]}")
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

REPOS="
zlib-ng https://github.com/ddlogesh/zlib-ng.git
minizip-ng https://github.com/ddlogesh/minizip-ng.git
libexpat https://github.com/ddlogesh/libexpat.git
xlsxio https://github.com/ddlogesh/xlsxio.git
sqlite https://github.com/ddlogesh/sqlite.git
"

# Clone repositories if not exist
echo "$REPOS" | while read -r name url; do
  if [ ! -d "$WORKDIR/$name" ]; then
    echo "Cloning $name..."
    git clone "$url" "$WORKDIR/$name"
  fi
done

build_zlib_ng() {
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
}

build_minizip_ng() {
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
}

build_libexpat() {
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
}

build_xlsxio() {
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
}

build_sqlite() {
  cd "$WORKDIR/sqlite"
  rm -rf build
  mkdir build && cd build

  ../configure
  $MAKE_CMD sqlite3.c
}

for project in "${PROJECT_FLAGS[@]}"; do
  case "$project" in
    zlib-ng)      build_zlib_ng ;;
    minizip-ng)   build_minizip_ng ;;
    libexpat)     build_libexpat ;;
    xlsxio)       build_xlsxio ;;
    sqlite)       build_sqlite ;;
    *)
      echo "Warning: Unknown flag --$project (ignored)"
      ;;
  esac
done
