#!/bin/bash
set -e

BUILD_TOP="${ANDROID_BUILD_TOP:-$(pwd)}"
DEVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLANG_DIR="$BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r563880"
CLANG_REPO="https://github.com/Aeron-Aeron/linux-x86-clang-21.0.0-r563880"
CORE_DIR="$BUILD_TOP/system/core"
LIBUTILS_PATCH="$DEVICE_DIR/patches/libutils.patch"

if [ ! -d "$CLANG_DIR/bin" ]; then
    echo "[vendorsetup] Clang r563880 not found, cloning..."
    mkdir -p "$(dirname "$CLANG_DIR")"
    git clone --depth=1 "$CLANG_REPO" "$CLANG_DIR"
else
    echo "[vendorsetup] Clang r563880 found. Skipping cloning."
fi

if [ -d "$CORE_DIR" ] && [ -f "$LIBUTILS_PATCH" ]; then
    if git -C "$CORE_DIR" apply --reverse --check "$LIBUTILS_PATCH" >/dev/null 2>&1; then
        echo "[vendorsetup] libutils patch already applied. Skipping."
    elif git -C "$CORE_DIR" apply --check "$LIBUTILS_PATCH" >/dev/null 2>&1; then
        echo "[vendorsetup] Applying libutils patch in system/core..."
        git -C "$CORE_DIR" apply "$LIBUTILS_PATCH"
    else
        echo "[vendorsetup] libutils patch could not be applied cleanly."
    fi
else
    echo "[vendorsetup] Missing system/core or patches/libutils.patch. Skipping libutils patch."
fi

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
END="\033[0m"

STANDARD_BRANCH="bka"
MIUICAM_BRANCH="lineage-23.0"
RUBYXLABS_BRANCH="lineage-23.2"
MEDIATEK_BRANCH="lineage-23"

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${YELLOW}• $1 already exists. Skipping cloning...${END}"
        return 1
    fi
    return 0
}

if check_dir vendor/xiaomi/rubyx; then
    echo -e "${GREEN}Cloning vendor tree from Yograt's Playground (branch: ${YELLOW}$STANDARD_BRANCH${GREEN})...${END}"
    git clone https://github.com/yograts-playground/vendor_xiaomi_rubyx -b $STANDARD_BRANCH vendor/xiaomi/rubyx --depth=1
fi

if check_dir kernel/xiaomi/mt6877; then
    echo -e "${GREEN}Cloning kernel source from Yograt's Playground (branch: ${YELLOW}$STANDARD_BRANCH${GREEN})...${END}"
    git clone https://github.com/yograts-playground/kernel_xiaomi_mt6877 -b $STANDARD_BRANCH kernel/xiaomi/mt6877 --depth=1
fi

if check_dir device/xiaomi/miuicamera-rubyx; then
    echo -e "${GREEN}Cloning MiUI camera sources from Rubyx labs (branch: ${YELLOW}$MIUICAM_BRANCH${GREEN})...${END}"
    git clone https://github.com/RubyxLabs/device_xiaomi_miuicamera-rubyx -b $MIUICAM_BRANCH device/xiaomi/miuicamera-rubyx --depth=1
fi

if check_dir vendor/xiaomi/miuicamera-rubyx; then
    git clone https://github.com/RubyxLabs/vendor_xiaomi_miuicamera-rubyx -b lineage-23.1 vendor/xiaomi/miuicamera-rubyx --depth=1
fi

if check_dir hardware/xiaomi; then
    echo -e "${GREEN}Cloning xiaomi hardware source from Rubyx labs (branch: ${YELLOW}$RUBYXLABS_BRANCH${GREEN})...${END}"
    git clone https://github.com/RubyxLabs/hardware_xiaomi -b $MIUICAM_BRANCH hardware/xiaomi --depth=1
fi

if check_dir hardware/mediatek; then
    echo -e "${GREEN}Cloning mediatek hardware source from Rubyx labs (branch: ${YELLOW}$RUBYXLABS_BRANCH${GREEN})...${END}"
    git clone https://github.com/RubyxLabs/hardware_mediatek -b $MEDIATEK_BRANCH hardware/mediatek --depth=1
fi

rm -rf device/mediatek/sepolicy_vndr
if check_dir device/mediatek/sepolicy_vndr; then
    echo -e "${GREEN}Cloning sepolicy vendor repo from Rubyx labs (branch: ${YELLOW}$RUBYXLABS_BRANCH${GREEN})...${END}"
    git clone https://github.com/RubyxLabs/device_mediatek_sepolicy_vndr -b $RUBYXLABS_BRANCH device/mediatek/sepolicy_vndr --depth=1
fi

rm -rf vendor/mediatek/ims
if check_dir vendor/mediatek/ims; then
    echo -e "${GREEN}Cloning mediatek ims vendor repo from Rubyx labs (branch: ${YELLOW}$RUBYXLABS_BRANCH${GREEN})...${END}"
    git clone https://github.com/RubyxLabs/vendor_mediatek_ims -b $RUBYXLABS_BRANCH vendor/mediatek/ims --depth=1
fi

echo -e "${YELLOW}All sources have been successfully cloned!${END}"
