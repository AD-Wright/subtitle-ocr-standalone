#!/bin/bash

# Exit on error
set -e

# Create directory structure
APPDIR="SubtitleConverterApp"
mkdir -p $APPDIR/usr/bin
mkdir -p $APPDIR/usr/lib/mkvtoolnix
mkdir -p $APPDIR/usr/lib/tesseract
mkdir -p $APPDIR/usr/lib/subtile-ocr
mkdir -p $APPDIR/usr/share/applications
mkdir -p $APPDIR/usr/share/icons/hicolor/256x256/apps
mkdir -p $APPDIR/usr/share/tessdata

# Copy the main script
cp mkv-subtitle-converter.sh $APPDIR/usr/bin/mkv-subtitle-converter
cp wrapper.sh $APPDIR/AppRun
chmod +x $APPDIR/usr/bin/mkv-subtitle-converter
chmod +x $APPDIR/AppRun

# Build and install subtile-ocr
echo "Building subtile-ocr..."
rm -rfd /tmp/subtile-ocr
cd /tmp
git clone https://github.com/gwen-lg/subtile-ocr.git
cd subtile-ocr
echo `pwd`
cargo build --release
cd ../..
cp /tmp/subtile-ocr/target/release/subtile-ocr $APPDIR/usr/lib/subtile-ocr/

# Copy MKVToolNix binaries
echo "Copying MKVToolNix binaries..."
cp $(which mkvmerge) $APPDIR/usr/lib/mkvtoolnix/
cp $(which mkvextract) $APPDIR/usr/lib/mkvtoolnix/
# Copy required shared libraries
ldd $(which mkvmerge) | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' $APPDIR/usr/lib/

# Copy Tesseract binaries and data
echo "Copying Tesseract binaries and data..."
cp $(which tesseract) $APPDIR/usr/lib/tesseract/
# Copy common language data files
cp /usr/share/tesseract-ocr/5/tessdata/eng.traineddata $APPDIR/usr/share/tessdata/
cp /usr/share/tesseract-ocr/5/tessdata/osd.traineddata $APPDIR/usr/share/tessdata/
# Copy required shared libraries
ldd $(which tesseract) | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' $APPDIR/usr/lib/

# Create desktop file
cat > $APPDIR/usr/share/applications/subtitleconverter.desktop << EOF
[Desktop Entry]
Name=Subtitle Converter
Exec=AppRun %f
Icon=subtitleconverter
Type=Application
Categories=Utility;
Comment=Extract and convert image-based subtitles to text
MimeType=video/x-matroska;
EOF

# Download an icon (or create your own)
wget -O $APPDIR/usr/share/icons/hicolor/256x256/apps/subtitleconverter.png "https://icon-library.com/images/subtitle-icon/subtitle-icon-11.jpg" || echo "Icon download failed, please add an icon manually"

# Create symlinks needed for AppImage
ln -sf usr/share/applications/subtitleconverter.desktop $APPDIR/subtitleconverter.desktop
ln -sf usr/share/icons/hicolor/256x256/apps/subtitleconverter.png $APPDIR/subtitleconverter.png

cd $HOME
# Get AppImageTool
#wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod +x appimagetool-x86_64.AppImage

# Generate AppImage
./appimagetool-x86_64.AppImage $APPDIR SubtitleConverter-x86_64.AppImage

echo "AppImage created: SubtitleConverter-x86_64.AppImage"
