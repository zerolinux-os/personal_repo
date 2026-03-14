#!/bin/bash
# ============================================================
# ZeroLinux - Repository Build Script
# ============================================================
# السكريبت الرئيسي لبناء المستودع الشخصي
# الاستخدام: ./build_repo.sh [--all | --category plasma|dev|security|browsers|themes|terminals|utils|calamares]
# ============================================================

set -euo pipefail

# ---- المتغيرات ----
REPO_NAME="zero"
REPO_DIR="${HOME}/personal_repo/x86_64"
PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/packages"
LOG_FILE="${HOME}/personal_repo/build.log"
FAILED_PKGS=()
SUCCESS_PKGS=()
COLORS=true

# ---- الألوان ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ---- دوال مساعدة ----
log()     { echo -e "${BLUE}[*]${NC} $*" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}[✓]${NC} $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*" | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}[✗]${NC} $*" | tee -a "$LOG_FILE"; }
header()  { echo -e "\n${BOLD}${CYAN}═══ $* ═══${NC}\n" | tee -a "$LOG_FILE"; }

# ---- طباعة البانر ----
print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
 _____              _     _
|__  /__ _ _ __ __| |   (_)_ __  _   ___  __
  / // _` | '__/ _` |   | | '_ \| | | \ \/ /
 / /| (_| | | | (_| |   | | | | | |_| |>  <
/____\__,_|_|  \__,_|   |_|_| |_|\__,_/_/\_\
                          Repository Builder v1.0
EOF
    echo -e "${NC}"
}

# ---- التحقق من المتطلبات ----
check_requirements() {
    header "التحقق من المتطلبات"
    local missing=()

    for cmd in pacman makepkg repo-add curl wget git; do
        if command -v "$cmd" &>/dev/null; then
            success "$cmd موجود"
        else
            error "$cmd غير موجود"
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "يرجى تثبيت: ${missing[*]}"
        exit 1
    fi
}

# ---- إعداد بيئة البناء ----
setup_repo() {
    header "إعداد بيئة المستودع"
    mkdir -p "$REPO_DIR"
    mkdir -p "${HOME}/personal_repo/logs"

    # إنشاء قاعدة بيانات فارغة إذا لم تكن موجودة
    if [[ ! -f "${REPO_DIR}/${REPO_NAME}.db.tar.gz" ]]; then
        cd "$REPO_DIR"
        repo-add "${REPO_NAME}.db.tar.gz"
        success "تم إنشاء قاعدة بيانات المستودع: ${REPO_NAME}.db.tar.gz"
    else
        success "قاعدة البيانات موجودة مسبقاً"
    fi
}

# ---- تحميل حزمة من المستودعات الرسمية ----
download_official_pkg() {
    local pkg="$1"
    log "تحميل حزمة: $pkg (رسمية)"

    # البحث عن الحزمة في pacman cache
    local cached
    cached=$(find /var/cache/pacman/pkg/ -name "${pkg}-*.pkg.tar.*" 2>/dev/null | head -1)

    if [[ -n "$cached" ]]; then
        cp "$cached" "$REPO_DIR/"
        success "$pkg (من الـ cache)"
        return 0
    fi

    # تحميل الحزمة مباشرة
    if pacman -Sw --noconfirm --cachedir "$REPO_DIR" "$pkg" 2>>"$LOG_FILE"; then
        success "$pkg"
        return 0
    else
        warn "لم يتم العثور على $pkg في المستودعات الرسمية"
        return 1
    fi
}

# ---- بناء حزمة من AUR ----
build_aur_pkg() {
    local pkg="$1"
    local build_dir="${HOME}/.cache/zerolinux-build/${pkg}"

    log "بناء حزمة من AUR: $pkg"
    mkdir -p "$build_dir"

    # استنساخ أو تحديث الحزمة
    if [[ -d "${build_dir}/.git" ]]; then
        git -C "$build_dir" pull --quiet 2>>"$LOG_FILE"
    else
        if git clone --depth=1 "https://aur.archlinux.org/${pkg}.git" "$build_dir" 2>>"$LOG_FILE"; then
            :
        else
            warn "لم يتم العثور على $pkg في AUR"
            return 1
        fi
    fi

    # البناء
    cd "$build_dir"
    if makepkg -sri --noconfirm --needed 2>>"$LOG_FILE"; then
        # نسخ الحزمة المبنية إلى المستودع
        find "$build_dir" -name "*.pkg.tar.*" -newer "${build_dir}/PKGBUILD" \
             -exec cp {} "$REPO_DIR/" \;
        success "$pkg (AUR)"
        return 0
    else
        error "فشل بناء $pkg"
        return 1
    fi
}

# ---- معالجة قائمة الحزم ----
process_package_list() {
    local list_file="$1"
    local category="$2"

    if [[ ! -f "$list_file" ]]; then
        warn "لا يوجد ملف: $list_file"
        return
    fi

    header "معالجة تصنيف: ${category}"
    local count=0
    local total
    total=$(grep -c '^[^#]' "$list_file" || true)

    while IFS= read -r line; do
        # تجاهل التعليقات والأسطر الفارغة
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        local pkg="${line// /}"  # إزالة المسافات
        [[ -z "$pkg" ]] && continue

        ((count++)) || true
        echo -e "${BOLD}[${count}/${total}]${NC} معالجة: ${pkg}"

        # محاولة التحميل من المستودعات الرسمية أولاً
        if download_official_pkg "$pkg"; then
            SUCCESS_PKGS+=("$pkg")
        # ثم محاولة AUR
        elif build_aur_pkg "$pkg"; then
            SUCCESS_PKGS+=("$pkg")
        else
            FAILED_PKGS+=("$pkg")
            error "فشل إضافة: $pkg"
        fi

    done < "$list_file"
}

# ---- إضافة الحزم لقاعدة البيانات ----
update_database() {
    header "تحديث قاعدة بيانات المستودع"
    cd "$REPO_DIR"

    local pkg_files
    pkg_files=$(find . -name "*.pkg.tar.*" ! -name "*.sig" 2>/dev/null)

    if [[ -z "$pkg_files" ]]; then
        warn "لا توجد حزم لإضافتها"
        return
    fi

    # إضافة كل الحزم لقاعدة البيانات
    if repo-add "${REPO_NAME}.db.tar.gz" $pkg_files 2>>"$LOG_FILE"; then
        success "تم تحديث قاعدة البيانات بنجاح"
    else
        error "فشل تحديث قاعدة البيانات"
    fi

    # إنشاء روابط رمزية للملفات
    for f in "${REPO_NAME}.db" "${REPO_NAME}.files"; do
        [[ -L "${f}" ]] || ln -sf "${f}.tar.gz" "${f}" 2>/dev/null || true
    done
}

# ---- بناء Calamares ----
build_calamares() {
    header "بناء Calamares - مثبّت ZeroLinux"

    local calamares_dir="${PACKAGES_DIR}/calamares"
    local build_dir="${HOME}/.cache/zerolinux-build/calamares-zerolinux"

    mkdir -p "$build_dir"
    cp -r "${calamares_dir}/." "$build_dir/"

    cd "$build_dir"
    if makepkg -sri --noconfirm 2>>"$LOG_FILE"; then
        find "$build_dir" -name "*.pkg.tar.*" -exec cp {} "$REPO_DIR/" \;
        success "تم بناء calamares-zerolinux بنجاح"
        SUCCESS_PKGS+=("calamares-zerolinux")
    else
        error "فشل بناء calamares-zerolinux"
        FAILED_PKGS+=("calamares-zerolinux")
    fi
}

# ---- طباعة التقرير النهائي ----
print_report() {
    header "تقرير البناء النهائي"

    echo -e "${GREEN}الحزم الناجحة (${#SUCCESS_PKGS[@]}):${NC}"
    for pkg in "${SUCCESS_PKGS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $pkg"
    done

    if [[ ${#FAILED_PKGS[@]} -gt 0 ]]; then
        echo ""
        echo -e "${RED}الحزم الفاشلة (${#FAILED_PKGS[@]}):${NC}"
        for pkg in "${FAILED_PKGS[@]}"; do
            echo -e "  ${RED}✗${NC} $pkg"
        done

        # حفظ الفاشلة في ملف
        printf '%s\n' "${FAILED_PKGS[@]}" > "${HOME}/personal_repo/failed_packages.txt"
        warn "تم حفظ قائمة الفاشلة في: ~/personal_repo/failed_packages.txt"
    fi

    echo ""
    echo -e "${BOLD}الإجمالي: ${GREEN}${#SUCCESS_PKGS[@]} ناجح${NC} | ${RED}${#FAILED_PKGS[@]} فاشل${NC}"
    echo -e "${BOLD}المستودع في: ${CYAN}${REPO_DIR}${NC}"
    echo ""
    success "انتهى البناء. راجع السجل في: $LOG_FILE"
}

# ---- الدالة الرئيسية ----
main() {
    print_banner

    # تهيئة ملف السجل
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "=== ZeroLinux Build Log - $(date) ===" > "$LOG_FILE"

    # معالجة المعاملات
    local category="${1:---all}"

    check_requirements
    setup_repo

    case "$category" in
        --all)
            process_package_list "${PACKAGES_DIR}/plasma/plasma_packages.txt"   "KDE Plasma"
            process_package_list "${PACKAGES_DIR}/dev/dev_packages.txt"          "التطوير"
            process_package_list "${PACKAGES_DIR}/security/security_packages.txt" "الأمن المعلوماتي"
            process_package_list "${PACKAGES_DIR}/browsers/browsers_packages.txt" "المتصفحات"
            process_package_list "${PACKAGES_DIR}/themes/themes_packages.txt"    "الثيمات"
            process_package_list "${PACKAGES_DIR}/terminals/terminals_packages.txt" "الطرفيات"
            process_package_list "${PACKAGES_DIR}/utils/utils_packages.txt"      "الأدوات المساعدة"
            build_calamares
            ;;
        --plasma)
            process_package_list "${PACKAGES_DIR}/plasma/plasma_packages.txt" "KDE Plasma"
            ;;
        --dev)
            process_package_list "${PACKAGES_DIR}/dev/dev_packages.txt" "التطوير"
            ;;
        --security)
            process_package_list "${PACKAGES_DIR}/security/security_packages.txt" "الأمن المعلوماتي"
            ;;
        --browsers)
            process_package_list "${PACKAGES_DIR}/browsers/browsers_packages.txt" "المتصفحات"
            ;;
        --themes)
            process_package_list "${PACKAGES_DIR}/themes/themes_packages.txt" "الثيمات"
            ;;
        --terminals)
            process_package_list "${PACKAGES_DIR}/terminals/terminals_packages.txt" "الطرفيات"
            ;;
        --utils)
            process_package_list "${PACKAGES_DIR}/utils/utils_packages.txt" "الأدوات المساعدة"
            ;;
        --calamares)
            build_calamares
            ;;
        *)
            echo "الاستخدام: $0 [--all | --plasma | --dev | --security | --browsers | --themes | --terminals | --utils | --calamares]"
            exit 1
            ;;
    esac

    update_database
    print_report
}

main "$@"
