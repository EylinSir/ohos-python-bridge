#!/usr/bin/env bash
# Build OpenSSL for OHOS ARM64
# Usage: source build_env.sh && bash build_openssl.sh
set -ex

DEPS_DIR=/opt/deps
WORKDIR=/home/runner/work/ohos-python-builder/ohos-python-builder

# Skip if already built
if [ -f $DEPS_DIR/lib/libssl.so ] && [ -f $DEPS_DIR/lib/libcrypto.so ]; then
    echo "=== OpenSSL already built, skipping ==="
    exit 0
fi

cd $WORKDIR/deps 2>/dev/null || { mkdir -p $WORKDIR/deps && cd $WORKDIR/deps; }

if [ ! -d openssl-3.5.9 ]; then
    curl -fLO https://github.com/openssl/openssl/releases/download/openssl-3.5.9/openssl-3.5.9.tar.gz
    tar -zxf openssl-3.5.9.tar.gz
    rm -rf openssl-3.5.9.tar.gz
fi

cd openssl-3.5.9

# Configure
./Configure --prefix=$DEPS_DIR --openssldir=/etc/ssl linux-aarch64

# Fix private keyword (C++ mode issue)
sed -i "s/\bprivate\b/priv/g" apps/include/apps.h

# Build and install
make -j$(nproc)
make install_sw
make install_ssldirs

echo "=== OpenSSL build complete ==="
