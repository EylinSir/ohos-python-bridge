#!/usr/bin/env bash
# Build readline for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/libreadline.so ]; then
    echo "=== readline already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d readline-8.3 ]; then
    curl -fLO https://ftp.gnu.org/gnu/readline/readline-8.3.tar.gz
    tar -zxf readline-8.3.tar.gz
    rm -rf readline-8.3.tar.gz
fi

cd readline-8.3
./configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu --prefix=$DEPS_DIR \
    --with-curses
make -j$(nproc)
make install

echo "=== readline build complete ==="
