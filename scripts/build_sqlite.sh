#!/usr/bin/env bash
# Build SQLite for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/libsqlite3.so ]; then
    echo "=== sqlite already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

SQLITE_VER=3450100
SQLITE_DIR=sqlite-autoconf-$SQLITE_VER

if [ ! -d $SQLITE_DIR ]; then
    curl -fLO https://www.sqlite.org/2024/$SQLITE_DIR.tar.gz
    tar -zxf $SQLITE_DIR.tar.gz
    rm -rf $SQLITE_DIR.tar.gz
fi

cd $SQLITE_DIR
./configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu --prefix=$DEPS_DIR \
    --disable-readline
make -j$(nproc)
make install

echo "=== sqlite build complete ==="
