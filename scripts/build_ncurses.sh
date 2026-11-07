#!/usr/bin/env bash
# Build ncurses for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/libncursesw.so ]; then
    echo "=== ncurses already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d ncurses-6.5 ]; then
    curl -fLO https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz
    tar -zxf ncurses-6.5.tar.gz
    rm -rf ncurses-6.5.tar.gz
fi

cd ncurses-6.5
./configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu --prefix=$DEPS_DIR \
    --enable-widec --with-shared --without-debug \
    --with-terminfo-dirs=$DEPS_DIR/share/terminfo
make -j$(nproc)
make install

# Copy terminfo
cp -r misc/terminfo $DEPS_DIR/share/ 2>/dev/null || true

echo "=== ncurses build complete ==="
