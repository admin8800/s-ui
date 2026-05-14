# Файлы Windows

Этот каталог содержит все файлы S-UI, относящиеся к Windows.

## Доступные файлы:

- **s-ui-windows.xml**: конфигурация службы Windows
- **install-windows.bat**: скрипт установки
- **s-ui-windows.bat**: панель управления
- **uninstall-windows.bat**: скрипт удаления
- **build-windows.bat**: простой скрипт сборки для CMD
- **build-windows.ps1**: расширенный скрипт сборки для PowerShell

## Использование:

Чтобы установить S-UI на Windows:
1. Запустите `install-windows.bat` от имени администратора
2. Следуйте инструкциям мастера установки
3. Используйте `s-ui-windows.bat` для управления

Чтобы собрать из исходного кода:
- Через CMD: `build-windows.bat`
- Через PowerShell: `.\build-windows.ps1`
