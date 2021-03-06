#!/bin/bash
set -e
set -o pipefail

S="$SHELL"

USAGE="run_all_tests.sh <path-to-encryptcli>"
if [ $# -lt 1 ]
then
    echo $USAGE
    exit 1
fi

BIN="$1"
TMP_DIR="./tmp"
OS=$(uname)

PLAIN_TEXT_FILE=$TMP_DIR/random.dat

export PLAIN_TEXT_FILE

rm -Rf $TMP_DIR
rm -Rf ./epd_encrypted_last
rm -Rf ./gpg_encrypted_last

mkdir -p $TMP_DIR
dd if=/dev/urandom of=$PLAIN_TEXT_FILE bs=1048576 count=15

# diffrent key file and passphrase combinations
$S ./epd_encryption_test.sh $BIN "$PLAIN_TEXT_FILE"

#encryption with an empty file
$S ./epd_encryption_test.sh $BIN empty.txt

# encrypt files with gpg
$S ./encrypt_with_gpg.sh

# decrypt gpg files with epd
$S ./decryption_test.sh $BIN ./gpg_encrypted_last
rm -R ./gpg_encrypted_last

# encrypt with epd
$S ./encrypt_with_epd.sh $BIN "$PLAIN_TEXT_FILE"

# decrypt the above with gpg
$S ./decryption_test.sh gpg ./epd_encrypted_last
rm -R ./epd_encrypted_last

# input output redirection and pipes
echo "Input / output redirection tests"
$S ./io_redir_test.sh $BIN
$S ./decryption_test.sh "$1" ./epd_encrypted_last

# backward compatibility tests
echo "Backward compatibility tests"
$S ./compat_test.sh $BIN
rm -Rf ./epd_encrypted_last
rm -Rf ./gpg_encrypted_last
rm -Rf ./tmp
