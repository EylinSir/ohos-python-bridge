#!/usr/bin/env bash
# Build gdbm for OHOS ARM64
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

if [ -f $DEPS_DIR/lib/libgdbm.so ]; then
    echo "=== gdbm already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d gdbm-1.26 ]; then
    curl -fLO https://ftp.gnu.org/gnu/gdbm/gdbm-1.26.tar.gz
    tar -zxf gdbm-1.26.tar.gz
    rm -rf gdbm-1.26.tar.gz
fi

cd gdbm-1.26
./configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu --prefix=$DEPS_DIR \
    --enable-libgdbm-compat
make -j$(nproc)
make install

# Create ndbm.h symlink
ln -sf gdbm/ndbm.h $DEPS_DIR/include/ndbm.h 2>/dev/null || true

echo "=== gdbm build complete ==="
