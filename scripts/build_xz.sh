#!/usr/bin/env bash
# Build xz (liblzma) for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/liblzma.so ]; then
    echo "=== liblzma already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d xz-5.8.1 ]; then
    curl -fLO https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.gz
    tar -zxf xz-5.8.1.tar.gz
    rm -rf xz-5.8.1.tar.gz
fi

cd xz-5.8.1
./configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu --prefix=$DEPS_DIR
make -j$(nproc)
make install

echo "=== liblzma build complete ==="
