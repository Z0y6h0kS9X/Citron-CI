#!/bin/bash

set -e

echo "Generating changelog for release"

git clone 'https://git.citron-emu.org/Citron/Emulator.git' ./citron
cd ./citron

# Get current commit info
COUNT="$(git rev-list --count HEAD)"
DATE="$(date +"%Y-%m-%d")"
TAG="${DATE}-${COUNT}"
SOURCE_NAME="Citron-${COUNT}-Source-Code"
echo "$TAG" > ~/tag
echo "$COUNT" > ~/count

# Start to generate release info and changelog
CHANGELOG_FILE=~/changelog
BASE_COMMIT_URL="https://git.citron-emu.org/Citron/Emulator/commit"
BASE_COMPARE_URL="https://git.citron-emu.org/Citron/Emulator/compare"
BASE_DOWNLOAD_URL="https://github.com/Z0y6h0kS9X/Citron-CI/releases/download"

# Fallback if OLD_COUNT is empty or null
if [ -z "$OLD_COUNT" ] || [ "$OLD_COUNT" = "null" ]; then
  echo "OLD_COUNT is empty, falling back to current COUNT"
  OLD_COUNT="$COUNT"
fi
OLD_HASH=$(git rev-list --reverse HEAD | sed -n "${OLD_COUNT}p")
i=$((OLD_COUNT + 1))

# Add reminder and Release Overview link
echo ">[!WARNING]" > "$CHANGELOG_FILE"
echo "**This repository is not affiliated with the official Citron development team. It exists solely to provide an easy way for users to try out the latest features from recent commits.**" >> "$CHANGELOG_FILE"
echo "**These builds are experimental and may be unstable. Use them at your own risk, and please do not report issues from these builds to the official channels unless confirmed on official releases.**" >> "$CHANGELOG_FILE"
echo >> "$CHANGELOG_FILE"
echo "> [!IMPORTANT]" >> "$CHANGELOG_FILE"
echo "> See the **[Release Overview](https://github.com/Z0y6h0kS9X/Citron-CI?tab=readme-ov-file#release-overview)** section for detailed differences between builds." >> "$CHANGELOG_FILE"
echo ">" >> "$CHANGELOG_FILE"
echo  -e "> **PGO-optimized** builds are now available, can offer up to **5–10%** higher FPS in theory depending on games.\n>**But note that they are now extremely experimental with unstable performance boost across different builds even with the same game.**" >> "$CHANGELOG_FILE"
echo >> "$CHANGELOG_FILE"

# Add changelog section
echo "## Changelog:" >> "$CHANGELOG_FILE"
git log --reverse --pretty=format:"%H%x09%s%x09%an" "${OLD_HASH}..HEAD" |
while IFS=$'\t' read -r full_hash msg author || [ -n "$full_hash" ]; do
  short_hash="$(git rev-parse --short "$full_hash")"
  echo -e "- Merged commit: \`${i}\` [\`${short_hash}\`](${BASE_COMMIT_URL}/${full_hash}) by **${author}**\n  ${msg}" >> "$CHANGELOG_FILE"
  echo >> "$CHANGELOG_FILE"
  i=$((i + 1))
done

# Add full changelog from lastest official tag release
echo "Full Changelog: [\`v0.0.3...master\`](${BASE_COMPARE_URL}/v0.0.3...master)" >> "$CHANGELOG_FILE"
echo >> "$CHANGELOG_FILE"

# Generate release table
echo "## Release table:" >> "$CHANGELOG_FILE"
echo "| Platform | Normal builds | PGO optimized builds |" >> "$CHANGELOG_FILE"
echo "|--|--|--|" >> "$CHANGELOG_FILE"
echo "| Linux (AppImage) | [\`Common x86_64_v3\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Common-x86_64.AppImage)<br><br>\
[\`Legacy x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Legacy-x86_64.AppImage)<br><br>\
[\`Steamdeck x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Steamdeck-x86_64.AppImage)<br><br>\
[\`ROG-ALLY x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-ROG_ALLY-x86_64.AppImage)<br><br>\
[\`aarch64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Linux-aarch64.AppImage) | \
[\`Common-PGO x86_64_v3\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Common-PGO-x86_64.AppImage)<br><br>\
[\`Legacy-PGO x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Legacy-PGO-x86_64.AppImage)<br><br>\
[\`Steamdeck-PGO x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Steamdeck-PGO-x86_64.AppImage)<br><br>\
[\`ROG-ALLY-PGO x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-ROG_ALLY-PGO-x86_64.AppImage) |" >> "$CHANGELOG_FILE"
echo "| Linux (AppBundle) | [\`Common x86_64_v3\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Common-x86_64.dwfs.AppBundle)<br><br>\
[\`Legacy x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Legacy-x86_64.dwfs.AppBundle)<br><br>\
[\`Steamdeck x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Steamdeck-x86_64.dwfs.AppBundle)<br><br>\
[\`ROG-ALLY x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-ROG_ALLY-x86_64.dwfs.AppBundle)<br><br>\
[\`aarch64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Linux-aarch64.dwfs.AppBundle) | \
[\`Common-PGO x86_64_v3\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Common-PGO-x86_64.dwfs.AppBundle)<br><br>\
[\`Legacy-PGO x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Legacy-PGO-x86_64.dwfs.AppBundle)<br><br>\
[\`Steamdeck-PGO x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Steamdeck-PGO-x86_64.dwfs.AppBundle)<br><br>\
[\`ROG-ALLY-PGO x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-ROG_ALLY-PGO-x86_64.dwfs.AppBundle)" >> "$CHANGELOG_FILE"
echo "| Android | [\`Replace\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Android-Replace.apk)<br><br>\
[\`Coexist\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Android-Coexist.apk)<br><br>\
[\`Optimized\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Android-Optimized.apk)<br><br>\
[\`Legacy\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Android-Legacy.apk) |" >> "$CHANGELOG_FILE"
echo "| Windows (MSVC) | **7z**<br>────────────────<br>\
[\`x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-msvc-x86_64.7z)<br><br>\
[\`arm64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-msvc-arm64.7z)<br><br>\
**Installer**<br>────────────────<br>\
[\`x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-msvc-x86_64-Installer.exe)<br><br>\
[\`arm64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-msvc-arm64-Installer.exe) |" >> "$CHANGELOG_FILE"
echo "| Windows (CLANG) | **7z**<br>────────────────<br>\
[\`x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-clang-x86_64.7z)<br><br>\
**Installer**<br>────────────────<br>\
[\`x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-clang-x86_64-Installer.exe) | \
**7z**<br>────────────────<br>\
[\`x86_64-PGO\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-clang-PGO-x86_64.7z)<br><br>\
**Installer**<br>────────────────<br>\
[\`x86_64-PGO\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-clang-PGO-x86_64-Installer.exe) |" >> "$CHANGELOG_FILE"
echo "| Windows (MSYS2) | **7z**<br>────────────────<br>\
[\`x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-msys2-x86_64.7z)<br><br>\
**Installer**<br>────────────────<br>\
[\`x86_64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-msys2-x86_64-Installer.exe) | \
**7z**<br>────────────────<br>\
[\`x86_64-PGO\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-msys2-PGO-x86_64.7z)<br><br>\
**Installer**<br>────────────────<br>\
[\`x86_64-PGO\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Windows-msys2-PGO-x86_64-Installer.exe) |" >> "$CHANGELOG_FILE"
echo "| FreeBSD | [\`amd64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-FreeBSD-amd64.tar.gz) | " >> "$CHANGELOG_FILE"
echo "| Solaris | [\`amd64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Solaris-amd64.tar.gz) | " >> "$CHANGELOG_FILE"
echo "| MacOS | [\`arm64\`](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-MacOS-arm64.7z) |" >> "$CHANGELOG_FILE"
echo "| Source Code | [Source](${BASE_DOWNLOAD_URL}/${TAG}/Citron-${COUNT}-Source-Code.7z) | |" >> "$CHANGELOG_FILE"

# Fetch all repo history and cpm pakages
git fetch --all
chmod a+x tools/cpm-fetch-all.sh
tools/cpm-fetch-all.sh

# Pack up source for upload
cd ..
mkdir -p artifacts
mkdir "$SOURCE_NAME"
cp -a citron "$SOURCE_NAME"
ZIP_NAME="$SOURCE_NAME.7z"
7z a -t7z -mx=9 "$ZIP_NAME" "$SOURCE_NAME"
mv "$ZIP_NAME" artifacts/
