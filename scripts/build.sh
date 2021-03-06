#!/usr/bin/env sh

set -xe

main() {
    ${CXX:-clang++} ${CXXFLAGS} -std=c++11 \
        -Wall -Wextra -Wpedantic -Wshadow -Werror -pedantic \
        -march=native -pipe \
        ./src/main.cpp -o "${DESTDIR}kos" $(pkg-config --cflags --libs libxcrypt) ${LDFLAGS}
}

main "$@"
