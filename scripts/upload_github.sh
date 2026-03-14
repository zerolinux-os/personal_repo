#!/bin/bash
# ============================================================
# ZeroLinux - GitHub Upload Script
# ============================================================
# رفع المستودع على GitHub بشكل احترافي
# ============================================================

set -euo pipefail

# ---- الإعدادات (عدّلها حسب بياناتك) ----
GITHUB_USER="zerolinux-os"
REPO_NAME_GH="personal_repo"
BRANCH="main"
COMMIT_MSG="chore: update ZeroLinux repository packages"

# مسارات محلية
LOCAL_REPO_DIR="${HOME}/personal_repo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "════════════════════════════════════════"
echo "  ZeroLinux → GitHub Upload"
echo "════════════════════════════════════════"

# التحقق من git
if ! command -v git &>/dev/null; then
    echo "❌ git غير مثبت"
    exit 1
fi

# التحقق من GitHub CLI أو SSH
echo "[1/6] التحقق من بيانات GitHub..."
if command -v gh &>/dev/null; then
    gh auth status || (echo "سجّل الدخول أولاً: gh auth login" && exit 1)
fi

# إنشاء ملف .gitignore
echo "[2/6] إنشاء .gitignore..."
cat > "${PROJECT_DIR}/.gitignore" << 'EOF'
# ملفات مؤقتة
*.tmp
*.bak
*.swp
*~

# مجلدات البناء
.cache/
build/
*.src.tar.gz

# سجلات
logs/
*.log

# ملفات حساسة
*.key
*.gpg
secrets/

# حزم كبيرة (استخدم Git LFS بدلاً منها)
*.pkg.tar.zst
*.pkg.tar.xz
*.pkg.tar.gz

# ملفات النظام
.DS_Store
Thumbs.db
EOF

# إنشاء .gitattributes لـ LFS (للحزم الكبيرة)
echo "[3/6] إعداد Git LFS..."
cat > "${PROJECT_DIR}/.gitattributes" << 'EOF'
# استخدام Git LFS للحزم الكبيرة
*.pkg.tar.zst filter=lfs diff=lfs merge=lfs -text
*.pkg.tar.xz  filter=lfs diff=lfs merge=lfs -text
*.pkg.tar.gz  filter=lfs diff=lfs merge=lfs -text
*.iso         filter=lfs diff=lfs merge=lfs -text
EOF

# تهيئة Git في مجلد المشروع
echo "[4/6] تهيئة Git..."
cd "$PROJECT_DIR"

if [[ ! -d ".git" ]]; then
    git init
    git checkout -b "$BRANCH"
fi

# إعداد git config المحلي
git config user.name "ZeroLinux Team"
git config user.email "team@zerolinux.org"

# ربط بـ GitHub
if ! git remote get-url origin &>/dev/null; then
    git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME_GH}.git"
    echo "تم إضافة remote: origin"
fi

# إضافة ونشر
echo "[5/6] إضافة الملفات..."
git add --all

# التحقق من وجود تغييرات
if git diff --staged --quiet; then
    echo "لا توجد تغييرات جديدة للرفع"
else
    git commit -m "$COMMIT_MSG"

    echo "[6/6] رفع على GitHub..."
    git push -u origin "$BRANCH"
    echo ""
    echo "════════════════════════════════════════"
    echo "  ✅ تم الرفع بنجاح!"
    echo "  https://github.com/${GITHUB_USER}/${REPO_NAME_GH}"
    echo "════════════════════════════════════════"
fi

# طباعة تعليمات إضافة المستودع عبر الإنترنت
echo ""
echo "لإضافة المستودع عبر الإنترنت لـ pacman.conf:"
echo "──────────────────────────────────────────"
echo "[zero]"
echo "SigLevel = Optional TrustAll"
echo "Server = https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME_GH}/main/x86_64"
echo "──────────────────────────────────────────"
