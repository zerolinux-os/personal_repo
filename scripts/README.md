# ZeroLinux — Personal Repository

<div align="center">

```
 _____              _     _
|__  /__ _ _ __ __| |   (_)_ __  _   ___  __
  / // _` | '__/ _` |   | | '_ \| | | \ \/ /
 / /| (_| | | | (_| |   | | | | | |_| |>  <
/____\__,_|_|  \__,_|   |_|_| |_|\__,_/_/\_\
```

**توزيعة لينكس مخصصة للمطورين وخبراء الأمن المعلوماتي**

![Arch Based](https://img.shields.io/badge/Based%20on-Arch%20Linux-1793d1?style=flat-square&logo=arch-linux)
![KDE Plasma](https://img.shields.io/badge/Desktop-KDE%20Plasma-1d99f3?style=flat-square&logo=kde)
![License](https://img.shields.io/badge/License-GPL%20v3-green?style=flat-square)
![Status](https://img.shields.io/badge/Status-In%20Development-orange?style=flat-square)

[📖 التوثيق الكامل](docs/README.md) | [🐛 الإبلاغ عن مشكلة](../../issues) | [💡 طلب ميزة](../../issues/new)

</div>

---

## ⚡ البداية السريعة

```bash
# استنساخ المستودع
git clone https://github.com/YOURUSERNAME/ZeroLinux.git
cd ZeroLinux

# إعداد بيئة العمل (مرة واحدة)
chmod +x scripts/setup_repo.sh && ./scripts/setup_repo.sh

# بناء المستودع الكامل
chmod +x scripts/build_repo.sh && ./scripts/build_repo.sh --all
```

## 📦 إضافة لـ pacman.conf

```ini
[zero]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/YOURUSERNAME/ZeroLinux/main/x86_64
```

---

للتوثيق الكامل راجع [docs/README.md](docs/README.md)
