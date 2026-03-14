#!/bin/bash
# ============================================================
# ZeroLinux - Initial Repository Setup
# ============================================================
# تشغيله مرة واحدة لإعداد بيئة العمل كاملة
# ============================================================

set -euo pipefail

REPO_DIR="${HOME}/personal_repo/x86_64"
REPO_NAME="zero"

echo "════════════════════════════════════════"
echo "  ZeroLinux Repository Setup"
echo "════════════════════════════════════════"

# 1. تثبيت الأدوات الأساسية
echo "[1/5] تثبيت أدوات البناء..."
sudo pacman -Syu --noconfirm --needed \
    base-devel \
    git \
    wget \
    curl \
    pacman-contrib \
    devtools \
    namcap \
    repo-add \
    asp 2>/dev/null || true

# 2. تثبيت yay (مساعد AUR)
if ! command -v yay &>/dev/null; then
    echo "[2/5] تثبيت yay (AUR helper)..."
    tmpdir=$(mktemp -d)
    git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmpdir"
    cd "$tmpdir"
    makepkg -si --noconfirm
    cd -
    rm -rf "$tmpdir"
else
    echo "[2/5] yay موجود مسبقاً ✓"
fi

# 3. إنشاء هيكل المستودع
echo "[3/5] إنشاء هيكل المستودع..."
mkdir -p "$REPO_DIR"
mkdir -p "${HOME}/personal_repo/logs"
mkdir -p "${HOME}/.cache/zerolinux-build"

# 4. إنشاء قاعدة البيانات
echo "[4/5] إنشاء قاعدة بيانات المستودع..."
cd "$REPO_DIR"
repo-add "${REPO_NAME}.db.tar.gz"

# إنشاء روابط رمزية
ln -sf "${REPO_NAME}.db.tar.gz" "${REPO_NAME}.db" 2>/dev/null || true
ln -sf "${REPO_NAME}.files.tar.gz" "${REPO_NAME}.files" 2>/dev/null || true

# 5. إضافة المستودع لـ pacman.conf
echo "[5/5] تهيئة pacman.conf..."
if ! grep -q "\[${REPO_NAME}\]" /etc/pacman.conf; then
    sudo tee -a /etc/pacman.conf > /dev/null << EOF

# ========== ZeroLinux Personal Repository ==========
[${REPO_NAME}]
SigLevel = Optional TrustAll
Server = file://${REPO_DIR}
# Server = https://raw.githubusercontent.com/YOURUSERNAME/ZeroLinux/main/x86_64
EOF
    echo "تمت إضافة المستودع لـ /etc/pacman.conf ✓"
else
    echo "المستودع مضاف مسبقاً ✓"
fi

# تحديث قاعدة البيانات
sudo pacman -Syy

echo ""
echo "════════════════════════════════════════"
echo "  تم الإعداد بنجاح!"
echo "  المستودع في: ${REPO_DIR}"
echo "  الخطوة التالية: cd ZeroLinux && ./scripts/build_repo.sh --all"
echo "════════════════════════════════════════"
