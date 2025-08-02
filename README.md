# Camphor Build

Build script to clone the dependencies if not exist and install them into `~/.camphor` directory.

# Instructions

```shell
# Build WASM-compatible libraries of all projects 
./build-wasm.sh

# Build GCC-compatible (or native) libraries of all projects 
./build-wasm.sh --native

# Build sqlite amalgamation
./build-wasm.sh --sqlite

# Build WASM-compatible library of xlsxio and libexpat  
./build-wasm.sh --xlsxio --libexpat
```
