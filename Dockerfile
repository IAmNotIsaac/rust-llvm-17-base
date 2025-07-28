FROM rust:1.88

# Clone LLVM. This takes awhile, so let's do this first
WORKDIR /opt
RUN apt-get update && apt-get install -y git \
    && git clone --branch llvmorg-17.0.6 https://github.com/llvm/llvm-project.git

# Dependencies for building LLVM
RUN apt-get update && apt-get install -y \
    cmake ninja-build curl build-essential lld \
    python3 libffi-dev zlib1g-dev libxml2-dev

# Build LLVM
WORKDIR /opt/llvm-project/build
RUN cmake -G Ninja ../llvm \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_PROJECTS="clang;polly" \
        -DLLVM_TARGETS_TO_BUILD="host" \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm-17 \
        -DBUILD_SHARED_LIBS=ON

# Install LLVM
RUN ninja && ninja install

# Project workdir
WORKDIR /usr/src/app

# Copy only Cargo.toml and lock file cuz we wanna cache dependencies
COPY Cargo.toml Cargo.lock ./
RUN mkdir src
RUN printf "fn main() {}" > src/main.rs

# Necessary env vars
ENV LLVM_SYS_170_PREFIX=/opt/llvm-17
ENV LD_LIBRARY_PATH=/opt/llvm-17/lib

# Build just to cache dependencies
RUN cargo build

# Now copy in full source
COPY . .

# Execute that bad boy
CMD ["cargo", "run"]

# This is an alternative way of building. idk maybe it's beneficial in some scenario. Just replace everything after line 40 with this.
# COPY . .
# RUN find src -type f -exec touch {} + && cargo build
# RUN cargo build
# CMD ["./target/debug/kaleidescope-rust"]
