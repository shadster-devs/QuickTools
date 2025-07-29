# Setting up Sparkle Autoupdater for QuickTools

## 🎯 What We've Added

1. **Sparkle Integration** in the main app
2. **Check for Updates** button in Settings
3. **Info.plist** configuration
4. **Sample appcast.xml** for hosting updates

## 📋 Setup Steps

### 1. Add Sparkle to Xcode Project

1. Open `QuickTools.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies**
3. Enter: `https://github.com/sparkle-project/Sparkle`
4. Choose **Up to Next Major Version** and click **Add Package**
5. Add **Sparkle** to your target

### 2. Generate Signing Keys

```bash
# Install Sparkle tools
brew install sparkle

# Generate EdDSA key pair (use full path)
/opt/homebrew/Caskroom/sparkle/2.7.1/bin/generate_keys

# This creates:
# - Private key: Stored in macOS Keychain (keep this SECRET!)
# - Public key: Added to Info.plist for verification
```

### 3. Update Info.plist

Replace these placeholders in `QuickTools/Resources/Info.plist`:

```xml
<key>SUFeedURL</key>
<string>https://yourdomain.com/quicktools/appcast.xml</string>
<key>SUPublicEDKey</key>
<string>YOUR_ACTUAL_PUBLIC_KEY_HERE</string>
```

### 4. Set up Hosting for Updates

#### Option A: GitHub Pages (Free)
1. Create a repository: `quicktools-updates`
2. Enable GitHub Pages
3. Upload `appcast.xml` to the repo
4. Use URL: `https://yourusername.github.io/quicktools-updates/appcast.xml`

#### Option B: Your Own Domain
1. Upload `appcast.xml` to your web hosting
2. Ensure HTTPS is enabled
3. Use your domain URL

### 5. Building & Signing Releases

```bash
# Archive your app in Xcode
# Export as Developer ID signed app

# Sign the update with Sparkle (use full path)
/opt/homebrew/Caskroom/sparkle/2.7.1/bin/sign_update QuickTools.app

# This outputs a signature for your appcast.xml
```

### 6. Update appcast.xml for New Releases

For each new version:

1. **Archive** your app in Xcode
2. **Export** as Developer ID signed
3. **Zip** the .app file: `QuickTools-1.1.0.zip`
4. **Sign** with Sparkle: `/opt/homebrew/Caskroom/sparkle/2.7.1/bin/sign_update QuickTools.app`
5. **Upload** zip to your hosting
6. **Update** appcast.xml with new version info

### 7. Gumroad Integration

1. **Upload** new version zip to Gumroad
2. **Update** your product description with changelog
3. **Send update notification** to existing customers
4. **Host appcast.xml** separately (Gumroad can't host XML files)

## 🔧 Testing Updates

1. **Lower your app version** temporarily (e.g., 0.9.0)
2. **Build and run** 
3. **Click "Check for Updates"** in Settings
4. **Verify** update dialog appears

## 📦 Release Workflow

1. **Increment version** in Xcode project
2. **Update** `AppConstants.appVersion`
3. **Archive** and export app
4. **Sign** with Sparkle
5. **Upload** to hosting
6. **Update** appcast.xml
7. **Upload** to Gumroad
8. **Notify** customers

## 🔐 Security Notes

- **Keep private key secure** and backed up
- **Use HTTPS** for all update URLs
- **Code sign** your app with Developer ID
- **Test updates** before releasing

## 🎉 Benefits for Gumroad

- **Automatic updates** for customers
- **Better user experience** than manual downloads
- **Easy deployment** of bug fixes
- **Professional feel** for your app 