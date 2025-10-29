# Ctrl + V Token Utility

A secure command-line utility to generate two-factor authentication tokens by combining a PIN with time-based OTP (TOTP).

## Purpose

Replace the process of opening mobile app → generating TOTP → typing PIN + TOTP code with a single command.

## Usage

```bash
tokgen
# Token copied to clipboard. Press Enter to clear clipboard after pasting.
```

## Prerequisites

⚠️ **Security Notice**: Ensure your organization permits command-line 2FA tools. Some organizations may consider this a security risk.

## Installation

### 1. Install Dependencies

**macOS:**
```bash
brew install oath-toolkit gnupg
# Optional: install zbar for QR code reading
brew install zbar
```

**Ubuntu/Debian:**
```bash
sudo apt install oathtool gnupg xclip
# Optional: for QR code reading
sudo apt install zbar-tools
```

### 2. Setup Repository
```bash
# Clone and setup directory
git clone <this-repo> ~/.oathtool
cd ~/.oathtool
```

### 3. Prepare Your Secrets

#### For PIN/Key:
Save your static PIN/key string (without spaces) to encrypt later.

#### For QR Code Secret:
**Option A: Extract from QR code image**
```bash
# If you have a QR code image
zbarimg your_qr_code.png
# Example output: QR-Code:otpauth://totp/YourService?secret=YOUR_SECRET_HERE&period=30...
# Copy the secret part after "secret="
```

**Option B: Manual entry**
If you can see the secret key in your 2FA setup, copy it directly (remove spaces).

### 4. Encrypt Your Secrets
```bash
# Encrypt your PIN/key
echo "YOUR_PIN_HERE" | gpg --batch --output key.gpg --passphrase "YOUR_KEY_PASSPHRASE" --symmetric

# Encrypt the TOTP secret (NOT the QR image file!)
echo "YOUR_TOTP_SECRET_HERE" | gpg --batch --output qrcode.gpg --passphrase "YOUR_QRCODE_PASSPHRASE" --symmetric
```

### 5. Configure Script
Edit `tokgen.sh` and replace the placeholder passphrases with the ones you used in step 4:
```bash
# Replace YOUR_KEY_PASSPHRASE and YOUR_QRCODE_PASSPHRASE in lines 23-24
gpg --batch --output ~/.oathtool/tempk --passphrase YOUR_KEY_PASSPHRASE --decrypt ~/.oathtool/key.gpg
gpg --batch --output ~/.oathtool/tempq --passphrase YOUR_QRCODE_PASSPHRASE --decrypt ~/.oathtool/qrcode.gpg
```

### 6. Set Permissions
```bash
chmod 700 key.gpg qrcode.gpg
chmod 750 tokgen.sh
```

### 7. Create Alias
Add to your `~/.bashrc` or `~/.zshrc`:
```bash
alias tokgen="bash ~/.oathtool/tokgen.sh"
```

Then reload: `source ~/.bashrc` or `source ~/.zshrc`

## Troubleshooting

### Common Issues

**"tr: Illegal byte sequence" error on macOS:**
- The script now includes `LC_ALL=C` to fix encoding issues
- If you still see this error, run: `LC_ALL=C tokgen`

**"command not found: zbarimg":**
- Install zbar: `brew install zbar` (macOS) or `sudo apt install zbar-tools` (Linux)

**Wrong token format:**
- Ensure you encrypted the **text secret** from QR code, not the image file
- Encrypt the secret string (e.g., `YOUR_SECRET_HERE`), not the image file name

**GPG decryption fails:**
- Check if passphrases in `tokgen.sh` match what you used during encryption
- Verify file permissions: `ls -la key.gpg qrcode.gpg`

## How It Works

The script generates a token by:

1. **Decrypts** `key.gpg` → extracts your PIN/static key
2. **Decrypts** `qrcode.gpg` → extracts TOTP secret
3. **Generates** current 6-digit TOTP code
4. **Concatenates** PIN + TOTP → copies to clipboard
5. **Waits** for user to paste → clears clipboard

**Token Format:** `[YOUR_PIN][6-digit-TOTP]` (no spaces)

## Security Features

- ✅ Secrets encrypted at rest with GPG
- ✅ Temporary files cleaned up automatically
- ✅ Clipboard cleared after use
- ✅ No plain text secrets
- ✅ Proper file permissions (700/750)

## Notes

- TOTP tokens expire every 30 seconds - run `tokgen` again if expired
- **Linux users**: Uncomment xclip lines in `tokgen.sh` and comment out macOS pbcopy lines
- **macOS users**: Uses `pbcopy` by default

