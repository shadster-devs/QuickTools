# GitHub Releases Automation for QuickTools

## 🎯 **What This Setup Does**

✅ **Fully automated releases** triggered by git tags  
✅ **Automatic code signing** with your Developer ID  
✅ **Sparkle signature generation** for secure updates  
✅ **GitHub Release creation** with changelog  
✅ **Appcast.xml updates** hosted on GitHub  
✅ **Asset hosting** via GitHub Releases (free!)  

## 🔧 **Setup Steps**

### **1. Repository Setup**

```bash
# Push your code to GitHub
git remote add origin https://github.com/YOUR_USERNAME/QuickTools.git
git push -u origin main

# Create the directories
mkdir -p .github/workflows scripts
```

### **2. GitHub Secrets Configuration**

Go to your repository **Settings → Secrets and variables → Actions** and add:

#### **Code Signing Secrets:**
- `CERTIFICATES_P12`: Your Developer ID certificate (base64 encoded)
- `CERTIFICATES_P12_PASSWORD`: Password for your certificate
- `TEAM_ID`: Your Apple Developer Team ID
- `BUNDLE_ID`: Your app bundle ID (e.g., `com.yourname.quicktools`)

#### **Sparkle Secrets:**
- `SPARKLE_PRIVATE_KEY`: Your Sparkle private key (base64 encoded)

#### **Optional App Store Connect (if needed):**
- `APPSTORE_ISSUER_ID`: App Store Connect API issuer ID
- `APPSTORE_KEY_ID`: App Store Connect API key ID  
- `APPSTORE_PRIVATE_KEY`: App Store Connect API private key

### **3. Get Your Secrets**

#### **Export your Developer ID Certificate:**
```bash
# Open Keychain Access
# Find your "Developer ID Application" certificate
# Right-click → Export
# Save as .p12 file with password

# Convert to base64
base64 -i YourCert.p12 | pbcopy
# Paste this into CERTIFICATES_P12 secret
```

#### **Get your Sparkle Private Key:**
```bash
# Export from keychain (it was stored there when you ran generate_keys)
security find-generic-password -s "Sparkle Private Key" -w | base64 | pbcopy
# Paste this into SPARKLE_PRIVATE_KEY secret
```

#### **Find your Team ID:**
```bash
# Check your Apple Developer account
# Or look in Xcode project settings
```

### **4. Update Feed URL**

Replace `YOUR_USERNAME` in `QuickTools/Resources/Info.plist`:
```xml
<key>SUFeedURL</key>
<string>https://raw.githubusercontent.com/YOUR_USERNAME/QuickTools/main/appcast.xml</string>
```

### **5. Test the Automation**

#### **Method 1: Using the Script (Recommended)**
```bash
# Make sure you're on main branch with no uncommitted changes
git checkout main
git pull

# Create a release (this will trigger the automation)
./scripts/create-release.sh 1.0.1
```

#### **Method 2: Manual Git Tags**
```bash
# Update version in AppConstants.swift manually
# Update version in Info.plist manually
git add -A
git commit -m "Bump version to 1.0.1"

# Create and push tag
git tag v1.0.1
git push origin main
git push origin v1.0.1
```

## 🔄 **Release Workflow**

### **Automatic Process (triggered by tags):**
1. **Developer** creates tag `v1.0.1`
2. **GitHub Actions** builds and signs the app
3. **Sparkle** signs the update
4. **GitHub Release** is created with assets
5. **Appcast.xml** is updated automatically
6. **Users** get automatic update notifications

### **What Gets Created:**
- ✅ **GitHub Release** with changelog
- ✅ **QuickTools-1.0.1.zip** download
- ✅ **Updated appcast.xml** with signature
- ✅ **Release notes** from git commits

## 📦 **Gumroad Integration**

### **Option 1: Link to GitHub Releases**
- Set Gumroad download to GitHub release URL
- Customers get latest version automatically
- Updates come via Sparkle

### **Option 2: Hybrid Approach**
- Upload to Gumroad for initial purchase
- Updates come via Sparkle from GitHub
- Best of both worlds!

## 🐛 **Troubleshooting**

### **Build Fails:**
- Check code signing certificates are valid
- Verify Team ID and Bundle ID match
- Ensure Xcode project builds locally

### **Signing Fails:**
- Verify Sparkle private key is correct
- Check that key is base64 encoded properly
- Test signing locally first

### **Appcast Issues:**
- Verify feed URL is accessible
- Check XML syntax in generated appcast
- Test with lower version number

## 🎉 **Benefits**

✅ **Zero manual work** after setup  
✅ **Professional release process**  
✅ **Automatic update delivery**  
✅ **Free hosting** via GitHub  
✅ **Version control** for releases  
✅ **Rollback capability** if needed  

## 🚀 **Next Steps**

1. **Set up GitHub repository**
2. **Configure all secrets**
3. **Test with a patch release**
4. **Integrate with Gumroad**
5. **Enjoy automated releases!**

Your QuickTools app will now have a **professional, automated release pipeline** that handles everything from building to user notifications! 🎉 