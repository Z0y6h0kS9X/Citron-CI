#!/bin/sh
set -ex
ARCH="${ARCH:-$(uname -m)}"

# The VERSION is now passed as an environment variable from the workflow
if [ -z "$APP_VERSION" ]; then
    echo "Error: APP_VERSION environment variable is not set."
    exit 1
fi

# --- Package Names ---
OUTNAME_BASE="citron_nightly-${APP_VERSION}-linux-${ARCH}${ARCH_SUFFIX}"
export OUTNAME_APPIMAGE="${OUTNAME_BASE}.AppImage"
export OUTNAME_TAR="${OUTNAME_BASE}.tar.zst"
OUTNAME_ROOM_SERVER="citron-room-server-${APP_VERSION}-linux-${ARCH}${ARCH_SUFFIX}.tar.gz"

# --- Create AppImage and Main Tarball ---
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

export DESKTOP=/usr/share/applications/org.citron_emu.citron.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/org.citron_emu.citron.svg
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PIPEWIRE=1

wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun

./quick-sharun /usr/bin/citron* /usr/lib/libgamemode.so* /usr/lib/libpulse.so*

echo "Copying Qt translation files..."
mkdir -p ./AppDir/usr/share/qt6
cp -r /usr/share/qt6/translations ./AppDir/usr/share/qt6/

if [ "$DEVEL" = 'true' ]; then
	sed -i 's|Name=citron|Name=citron nightly|' ./AppDir/*.desktop
fi

echo 'SHARUN_ALLOW_SYS_VK_ICD=1' > ./AppDir/.env

echo "Creating tar.zst archive..."
(cd AppDir && tar -c --zstd -f ../"$OUTNAME_TAR" usr)
echo "Successfully created $OUTNAME_TAR"

wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

echo "Renaming versioned AppImage to the final suffixed name: ${OUTNAME_APPIMAGE}..."
SOURCE_APPIMAGE="citron_nightly-${APP_VERSION}-${ARCH}.AppImage"
mv -v "${SOURCE_APPIMAGE}" "${OUTNAME_APPIMAGE}"
mv -v "${SOURCE_APPIMAGE}.zsync" "${OUTNAME_APPIMAGE}.zsync"

# --- Create citron-room Server Package ---
echo "Creating self-contained citron-room server package..."
mkdir -p ./room_server_pkg/lib

# Copy the main binaries into the package directory
cp /usr/bin/citron-room ./room_server_pkg/
cp /usr/bin/citron-cmd ./room_server_pkg/

# Find all non-system library dependencies for both binaries and copy them into the package
DEPS=$(ldd /usr/bin/citron-room /usr/bin/citron-cmd | grep '=> /usr/lib' | awk '{print $3}' | sort -u)
echo "Bundling required libraries:"
echo "$DEPS"
for DEP in $DEPS; do
    cp "$DEP" ./room_server_pkg/lib/
done

# Create a new start-server.sh that sets the library path before running
echo '#!/bin/sh' > ./room_server_pkg/start-server.sh
echo '# This script starts the citron-room server and ensures it can find its bundled libraries.' >> ./room_server_pkg/start-server.sh
echo 'DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"' >> ./room_server_pkg/start-server.sh
echo 'export LD_LIBRARY_PATH="$DIR/lib:$LD_LIBRARY_PATH"' >> ./room_server_pkg/start-server.sh
echo '"$DIR/citron-room" "$@"' >> ./room_server_pkg/start-server.sh
chmod +x ./room_server_pkg/start-server.sh

# Create the final tarball
tar -czvf "${OUTNAME_ROOM_SERVER}" -C ./room_server_pkg .
echo "Successfully created ${OUTNAME_ROOM_SERVER}"

# --- Move All Artifacts to dist/ ---
echo "Moving all artifacts to the dist directory..."
mkdir -p ./dist
mv -v ./*.AppImage* ./dist
mv -v ./*.tar.zst ./dist
mv -v ./*.tar.gz ./dist
