#!/usr/bin/env bash
# Build zlib for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/libz.so ]; then
    echo "=== zlib already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d zlib-1.3.1 ]; then
    curl -fLO https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz
    tar -zxf zlib-1.3.1.tar.gz
    rm -rf zlib-1.3.1.tar.gz
fi

cd zlib-1.3.1
./configure --prefix=$DEPS_DIR
make -j$(nproc)
make install

echo "=== zlib build complete ==="
