#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
export RUST_VERSION=stable

sudo useradd -ms /bin/bash tester
sudo apt-get update -qq

sudo apt-get -qq install --no-install-recommends --allow-unauthenticated -yy \
     autoconf \
     automake \
     binfmt-support \
     build-essential \
     clang \
     cppcheck \
     docbook-xml \
     eatmydata \
     gcc-aarch64-linux-gnu \
     gcc-arm-linux-gnueabihf \
     gcc-arm-none-eabi \
     gettext \
     git \
     gnupg \
     jq \
     libc6-dev-arm64-cross \
     libc6-dev-armhf-cross \
     libev-dev \
     libevent-dev \
     libffi-dev \
     libicu-dev \
     libpq-dev \
     libprotobuf-c-dev \
     libsqlite3-dev \
     libssl-dev \
     libtool \
     libxml2-utils \
     locales \
     net-tools \
     postgresql \
     python-pkg-resources \
     python3 \
     python3-dev \
     python3-pip \
     python3-setuptools \
     qemu \
     qemu-system-arm \
     qemu-user-static \
     shellcheck \
     software-properties-common \
     sudo \
     tcl \
     tclsh \
     unzip \
     valgrind \
     wget \
     xsltproc \
     systemtap-sdt-dev \
     zlib1g-dev

echo "tester ALL=(root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/tester
sudo chmod 0440 /etc/sudoers.d/tester

"$(dirname "$0")"/install-bitcoind.sh

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
     -y --default-toolchain ${RUST_VERSION}

# We also need a relatively recent protobuf-compiler, at least 3.12.0,
# in order to support the experimental `optional` flag.

# BUT WAIT!  Gentoo wants this to match the version from the Python protobuf,
# which comes from the same tree.  Makes sense!

# And
#   grpcio-tools-1.69.0` requires `protobuf = ">=5.26.1,<6.0dev"`

# Now, protoc changed to date-based releases, BUT Python protobuf
# didn't, so Python protobuf 4.21.12 (in Ubuntu 23.04) corresponds to
# protoc 21.12 (which, FYI, is packaged in Ubuntu as version 3.21.12).

# In general protobuf version x.y.z corresponds to protoc version y.z

# Honorable mention go to Matt Whitlock for spelunking this horror with me!

PROTOC_VERSION=29.4
PB_REL="https://github.com/protocolbuffers/protobuf/releases"
curl -LO $PB_REL/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
sudo unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local/
sudo chmod a+x /usr/local/bin/protoc
export PROTOC=/usr/local/bin/protoc
export PATH=$PATH:/usr/local/bin
env
ls -lha /usr/local/bin
