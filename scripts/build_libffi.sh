#!/usr/bin/env bash
# Build libffi for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/libffi.so ]; then
    echo "=== libffi already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d libffi-3.5.2 ]; then
    curl -fLO https://github.com/libffi/libffi/releases/download/v3.5.2/libffi-3.5.2.tar.gz
    tar -zxf libffi-3.5.2.tar.gz
    rm -rf libffi-3.5.2.tar.gz
fi

cd libffi-3.5.2
./configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu --prefix=$DEPS_DIR
make -j$(nproc)
make install

echo "=== libffi build complete ==="
