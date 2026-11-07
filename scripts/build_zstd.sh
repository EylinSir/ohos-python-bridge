#!/usr/bin/env bash
# Build zstd for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/libzstd.so ]; then
    echo "=== zstd already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d zstd-1.5.7 ]; then
    curl -fLO https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
    tar -zxf zstd-1.5.7.tar.gz
    rm -rf zstd-1.5.7.tar.gz
fi

cd zstd-1.5.7

# Fix: add __OHOS__ macro
sed -i 's/#ifdef __linux__/&\n|| defined(__OHOS__)/' lib/common/portability_macros.h 2>/dev/null || true

make -j$(nproc) CC="/bin/clang" CFLAGS="$CFLAGS" lib
make PREFIX=$DEPS_DIR install

echo "=== zstd build complete ==="
