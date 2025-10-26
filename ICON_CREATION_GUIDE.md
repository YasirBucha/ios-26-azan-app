# 🎨 App Icon & Splash Screen Creation Guide

## Your Beautiful Designs
- **Logo**: Mosque icon with glassmorphism effect in circular container
- **Splash Screen**: Elegant design with "My Azan" and "Prayer Times" text

## 📱 App Icon Sizes Required

**Location**: `MyAzan/Assets.xcassets/AppIcon.appiconset/`

| File Name | Size | Usage |
|-----------|------|-------|
| `Icon-20@2x.png` | 40x40 | Settings, Spotlight |
| `Icon-20@3x.png` | 60x60 | Settings, Spotlight |
| `Icon-29@2x.png` | 58x58 | Settings |
| `Icon-29@3x.png` | 87x87 | Settings |
| `Icon-40@2x.png` | 80x80 | Spotlight |
| `Icon-40@3x.png` | 120x120 | Spotlight |
| `Icon-60@2x.png` | 120x120 | Home Screen |
| `Icon-60@3x.png` | 180x180 | Home Screen |
| `Icon-76@2x.png` | 152x152 | iPad Home Screen |
| `Icon-83.5@2x.png` | 167x167 | iPad Pro Home Screen |
| `Icon-1024.png` | 1024x1024 | App Store |
| `Icon-App-20x20@2x.png` | 40x40 | General |

## 🌅 Splash Screen Sizes Required

**Location**: `MyAzan/Assets.xcassets/LaunchScreen.imageset/`

| File Name | Size | Device |
|-----------|------|--------|
| `LaunchScreen@1x.png` | 375x812 | iPhone X/11/12 mini |
| `LaunchScreen@2x.png` | 750x1624 | iPhone X/11/12 |
| `LaunchScreen@3x.png` | 1125x2436 | iPhone X/11/12 Pro Max |
| `LaunchScreen-ipad.png` | 1024x1366 | iPad |

## 🛠️ How to Create These Images

### Option 1: Using Online Tools
1. **App Icon Generator**: Use tools like:
   - https://appicon.co/
   - https://makeappicon.com/
   - Upload your logo and download all sizes

2. **Splash Screen Generator**: Use tools like:
   - https://launchscreen.co/
   - https://splashscreen.co/
   - Upload your splash screen and download all sizes

### Option 2: Using Design Software
1. **Photoshop/GIMP**: 
   - Open your logo/splash screen
   - Resize to each required dimension
   - Save as PNG with exact filename

2. **Sketch/Figma**:
   - Create artboards for each size
   - Export as PNG with exact filename

### Option 3: Using Command Line (if you have ImageMagick)
```bash
# For app icons (replace "your-logo.png" with your actual logo file)
convert your-logo.png -resize 40x40 Icon-20@2x.png
convert your-logo.png -resize 60x60 Icon-20@3x.png
convert your-logo.png -resize 58x58 Icon-29@2x.png
convert your-logo.png -resize 87x87 Icon-29@3x.png
convert your-logo.png -resize 80x80 Icon-40@2x.png
convert your-logo.png -resize 120x120 Icon-40@3x.png
convert your-logo.png -resize 120x120 Icon-60@2x.png
convert your-logo.png -resize 180x180 Icon-60@3x.png
convert your-logo.png -resize 152x152 Icon-76@2x.png
convert your-logo.png -resize 167x167 Icon-83.5@2x.png
convert your-logo.png -resize 1024x1024 Icon-1024.png
convert your-logo.png -resize 40x40 Icon-App-20x20@2x.png

# For splash screens (replace "your-splash.png" with your actual splash screen file)
convert your-splash.png -resize 375x812 LaunchScreen@1x.png
convert your-splash.png -resize 750x1624 LaunchScreen@2x.png
convert your-splash.png -resize 1125x2436 LaunchScreen@3x.png
convert your-splash.png -resize 1024x1366 LaunchScreen-ipad.png
```

## 📁 File Structure After Creation

```
MyAzan/Assets.xcassets/
├── AppIcon.appiconset/
│   ├── Contents.json
│   ├── Icon-20@2x.png (40x40)
│   ├── Icon-20@3x.png (60x60)
│   ├── Icon-29@2x.png (58x58)
│   ├── Icon-29@3x.png (87x87)
│   ├── Icon-40@2x.png (80x80)
│   ├── Icon-40@3x.png (120x120)
│   ├── Icon-60@2x.png (120x120)
│   ├── Icon-60@3x.png (180x180)
│   ├── Icon-76@2x.png (152x152)
│   ├── Icon-83.5@2x.png (167x167)
│   ├── Icon-1024.png (1024x1024)
│   └── Icon-App-20x20@2x.png (40x40)
└── LaunchScreen.imageset/
    ├── Contents.json
    ├── LaunchScreen@1x.png (375x812)
    ├── LaunchScreen@2x.png (750x1624)
    ├── LaunchScreen@3x.png (1125x2436)
    └── LaunchScreen-ipad.png (1024x1366)
```

## ✅ Verification Steps

1. **Place all files** in the correct folders with exact names
2. **Open Xcode** and check that icons appear in the asset catalog
3. **Build the app** (Cmd+R) to see your custom icons
4. **Test on device** to verify splash screen appears

## 🎯 Pro Tips

- **Use PNG format** for all images
- **Ensure filenames match exactly** (case-sensitive)
- **The 1024x1024 icon** is most important for App Store
- **Test on both light and dark modes**
- **Consider accessibility** - ensure good contrast

Your beautiful mosque icon with glassmorphism effect will look amazing as the app icon! 🕌✨
