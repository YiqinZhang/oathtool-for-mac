#!/bin/bash
# TOTP Token Generator
# Configuration: Replace YOUR_KEY_PASSPHRASE and YOUR_QRCODE_PASSPHRASE with your actual passphrases

# Set locale to avoid encoding issues with tr command on macOS
export LC_ALL=C

# Exit on any error
set -e

# Check dependencies
if ! command -v gpg &> /dev/null; then
    echo "Error: gpg not found. Please install GnuPG."
    exit 1
fi

if ! command -v oathtool &> /dev/null; then
    echo "Error: oathtool not found. Please install oath-toolkit."
    exit 1
fi

# Decrypt files (IMPORTANT: Replace the passphrases below with your actual passphrases)
gpg --batch --output ~/.oathtool/tempk --passphrase YOUR_KEY_PASSPHRASE --decrypt ~/.oathtool/key.gpg
gpg --batch --output ~/.oathtool/tempq --passphrase YOUR_QRCODE_PASSPHRASE --decrypt ~/.oathtool/qrcode.gpg

# Following should be adjusted for the token format expected in your auth. Here, the format is key+totp.
# Remove spaces from key, use qrcode content to generate TOTP
ORIGINAL_KEY=$(cat ~/.oathtool/tempk | tr -d ' ')
QRCODE_KEY=$(cat ~/.oathtool/tempq | tr -d ' \n\r')
TOTP=$(echo "$QRCODE_KEY" | oathtool --base32 --totp -)
echo "$ORIGINAL_KEY$TOTP" > ~/.oathtool/tmp

# For mac uncomment this, comment the linux block
pbcopy < ~/.oathtool/tmp
echo "Token pbcopied. Hit enter to clear clipboard when it is pasted."
read ip
pbcopy < /dev/null

# For linux, uncomment this, comment the mac block: pbcopy is a mac utility, other OSs will need to use cat and xclip
# cat ~/.oathtool/tmp | xclip -selection clipboard
# read ip
# xclip -sel clip < /dev/null


# Remove temp files
rm -f ~/.oathtool/tempq
rm -f ~/.oathtool/tempk
rm -f ~/.oathtool/tmp
