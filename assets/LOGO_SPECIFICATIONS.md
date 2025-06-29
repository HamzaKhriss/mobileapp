# 🎨 CasaWonders Logo Specifications

## 📱 **App Logo (In-App Usage)**

**Location:** `assets/images/app_logo.png`

- **Format:** PNG with transparent background
- **Size:** 512x512 pixels (high resolution for scaling)
- **Usage:** Welcome screen, splash screen, about page, headers
- **Design:** Should include text "CasaWonders" or just icon depending on usage

## 📲 **App Icons (Phone Home Screen)**

### Android Icons

**Location:** `android/app/src/main/res/mipmap-*/ic_launcher.png`

- `mipmap-mdpi/ic_launcher.png` → **48x48** pixels
- `mipmap-hdpi/ic_launcher.png` → **72x72** pixels
- `mipmap-xhdpi/ic_launcher.png` → **96x96** pixels
- `mipmap-xxhdpi/ic_launcher.png` → **144x144** pixels
- `mipmap-xxxhdpi/ic_launcher.png` → **192x192** pixels

**Requirements:**

- Format: PNG
- Background: Solid color (not transparent)
- Design: Simple, recognizable at small sizes
- Style: Android will automatically apply rounded corners

### iOS Icons (Future)

**Location:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

- Multiple sizes from 20x20 to 1024x1024 points
- Format: PNG without transparency
- Follow Apple's Human Interface Guidelines

## 🎯 **Splash Screen Logo**

**Location:** `assets/images/splash_logo.png`

- **Format:** PNG with transparent background
- **Size:** 256x256 pixels
- **Usage:** Loading screen while app initializes
- **Design:** Simple version of logo, works on both light/dark backgrounds

## 🔄 **Adaptive Icon (Android 8.0+)**

**Location:** `android/app/src/main/res/mipmap-anydpi-v26/`

- Foreground: 108x108dp with 72x72dp safe zone
- Background: Solid color or simple pattern
- Format: Vector drawable or PNG

## 📐 **Design Guidelines**

### Colors to Use:

- **Primary:** `#1ABC9C` (Mint Green)
- **Secondary:** `#68D8C5` (Light Mint)
- **Accent:** `#282B2B` (Dark Gray)
- **Background:** White or transparent

### Logo Variants Needed:

1. **Full Logo:** Icon + "CasaWonders" text
2. **Icon Only:** Just the symbol/mark
3. **Horizontal:** Logo arranged horizontally
4. **Stacked:** Logo arranged vertically
5. **Monochrome:** Single color version
6. **Inverted:** For dark backgrounds

## 📦 **Quick Start**

1. Create your logo design in **1024x1024** pixels
2. Export variants:
   - `app_logo.png` (512x512, transparent background)
   - `splash_logo.png` (256x256, transparent background)
   - Android icons (sizes above, solid background)
3. Replace the placeholder files
4. Run `flutter clean && flutter pub get`

## 🛠 **Tools Recommended**

- **Design:** Figma, Adobe Illustrator, Canva
- **Icon Generation:** [App Icon Generator](https://appicon.co/)
- **Android Assets:** Android Studio Asset Studio

---

**Note:** Current files are placeholders. Replace them with your actual logo files maintaining the same filenames and sizes.
