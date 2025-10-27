#!/bin/bash

# Script to copy images from Assets/Images to Xcode imageset folders

IMAGES_DIR="MyAzan/Assets/Images"
ASSETS_DIR="MyAzan/Assets.xcassets"

echo "Setting up images for My Azan app..."

# Check if images directory exists
if [ ! -d "$IMAGES_DIR" ]; then
    echo "Error: Images directory not found at $IMAGES_DIR"
    exit 1
fi

# Process Circular Image (Mc.png)
if [ -f "$IMAGES_DIR/Mc.png" ] || [ -f "$IMAGES_DIR/Mc.jpg" ]; then
    echo "Found circular image (Mc)..."
    
    # Determine the file extension
    if [ -f "$IMAGES_DIR/Mc.png" ]; then
        EXT="png"
    else
        EXT="jpg"
    fi
    
    # Copy to imageset folder
    cp "$IMAGES_DIR/Mc.$EXT" "$ASSETS_DIR/CircularImage.imageset/CircularImage.png"
    cp "$IMAGES_DIR/Mc.$EXT" "$ASSETS_DIR/CircularImage.imageset/CircularImage@2x.png"
    cp "$IMAGES_DIR/Mc.$EXT" "$ASSETS_DIR/CircularImage.imageset/CircularImage@3x.png"
    
    echo "✓ Circular image (Mc) copied successfully"
else
    echo "⚠ No circular image found. Looking for 'Mc.png' or 'Mc.jpg'"
fi

# Process Rectangle Image (MA.png)
if [ -f "$IMAGES_DIR/MA.png" ] || [ -f "$IMAGES_DIR/MA.jpg" ]; then
    echo "Found rectangle image (MA)..."
    
    # Determine the file extension
    if [ -f "$IMAGES_DIR/MA.png" ]; then
        EXT="png"
    else
        EXT="jpg"
    fi
    
    # Copy to imageset folder
    cp "$IMAGES_DIR/MA.$EXT" "$ASSETS_DIR/RectangleImage.imageset/RectangleImage.png"
    cp "$IMAGES_DIR/MA.$EXT" "$ASSETS_DIR/RectangleImage.imageset/RectangleImage@2x.png"
    cp "$IMAGES_DIR/MA.$EXT" "$ASSETS_DIR/RectangleImage.imageset/RectangleImage@3x.png"
    
    echo "✓ Rectangle image (MA) copied successfully"
else
    echo "⚠ No rectangle image found. Looking for 'MA.png' or 'MA.jpg'"
fi

echo ""
echo "Done! You can now build and run your app."
echo ""
echo "If you want to update images in the future:"
echo "1. Replace the images in $IMAGES_DIR"
echo "2. Run this script again: ./setup_images.sh"
