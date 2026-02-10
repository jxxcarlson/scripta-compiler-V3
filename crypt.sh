#!/bin/bash

usage() {
    echo "Usage:"
    echo "  crypt -e FILE        Encrypt FILE with passphrase (creates FILE.age)"
    echo "  crypt -d FILE.age    Decrypt FILE.age to FILE"
    echo "  crypt -s FILE.age    Decrypt FILE.age to stdout"
    exit 1
}

[ $# -lt 1 ] && usage

case "$1" in
    -e) [ -z "$2" ] && usage; age -p -e "$2" ;;
    -d) [ -z "$2" ] && usage; age -d -o "${2%.age}" "$2" ;;
    -s) [ -z "$2" ] && usage; age -d -o - "$2" ;;
    *)  usage ;;
esac
