#!/usr/bin/env bash
# Build util-linux (libuuid only) for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/libuuid.so ]; then
    echo "=== libuuid already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d util-linux-2.41.3 ]; then
    curl -fLO https://mirrors.kernel.org/pub/linux/utils/util-linux/v2.41/util-linux-2.41.3.tar.gz
    tar -zxf util-linux-2.41.3.tar.gz
    rm -rf util-linux-2.41.3.tar.gz
fi

cd util-linux-2.41.3
./configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu --prefix=$DEPS_DIR \
    --disable-all-programs --enable-libuuid
make -j$(nproc)
make install

echo "=== libuuid build complete ==="
