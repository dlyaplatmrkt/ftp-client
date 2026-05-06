# FTP VPN Client

<p align="center">
  <img src="assets/images/logo.png" width="120" alt="FTP VPN Logo"/>
</p>

<p align="center">
  <b>Быстрый и безопасный VPN клиент для Windows, Linux и macOS</b><br>
  Поддержка VLESS • VMess • Shadowsocks • Trojan • Hysteria2
</p>

<p align="center">
  <a href="https://github.com/ftpvpn/ftp-client/releases/latest">
    <img src="https://img.shields.io/github/v/release/ftpvpn/ftp-client?style=for-the-badge&color=7B68EE" alt="Latest Release"/>
  </a>
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-7B68EE?style=for-the-badge" alt="Platform"/>
  <img src="https://img.shields.io/badge/Powered%20by-Xray--core-4169E1?style=for-the-badge" alt="Xray"/>
</p>

---

## Скачать

| Платформа | Тип | Ссылка |
|-----------|-----|--------|
| Windows 10/11 | Установщик (.exe) | [Releases](../../releases/latest) |
| Windows | Portable (.zip) | [Releases](../../releases/latest) |
| Linux | Архив (.tar.gz) | [Releases](../../releases/latest) |

## Возможности

- **Протоколы:** VLESS (включая Reality), VMess, Shadowsocks, Trojan, Hysteria2
- **Простое добавление конфигов:** вставьте URI и готово
- **Автонастройка прокси:** автоматически настраивает системный HTTP/SOCKS5 прокси
- **Мониторинг трафика:** реальное время — скорость, объём, время подключения
- **Логи:** детальные логи xray-core
- **Встроенный xray-core:** скачивается прямо из приложения

## Установка и использование

### Windows

1. Скачайте `FTPVPNClient-Setup-vX.X.X.exe` из [Releases](../../releases/latest)
2. Запустите установщик от имени **администратора**
3. Следуйте инструкциям установщика
4. Запустите **FTP VPN Client** с рабочего стола

### Первый запуск

1. Откройте **Settings** → нажмите **Download** рядом с "Xray Core"
2. Перейдите на вкладку **Configs**
3. Нажмите **Add** и вставьте VLESS/VMess URI
4. Вернитесь на **Home** и нажмите кнопку подключения

## Сборка из исходников

```bash
# Требуется Flutter 3.22+
flutter pub get
flutter build windows --release
```

## Стек

- **UI:** Flutter 3.22 (Dart)
- **Ядро VPN:** [Xray-core](https://github.com/XTLS/Xray-core)
- **State:** Provider
- **Storage:** shared_preferences

## Лицензия

MIT License — см. [LICENSE](LICENSE)

---

<p align="center">ftpvpn.lol • @ftpvpn_bot</p>
