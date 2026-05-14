@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo Установщик S-UI для Windows
echo ========================================

REM Проверка запуска от имени администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Ошибка: этот скрипт нужно запускать от имени администратора
    echo Щелкните файл правой кнопкой мыши и выберите "Запуск от имени администратора"
    pause
    exit /b 1
)

cd /d "%~dp0"
REM Каталог установки
set "INSTALL_DIR=C:\Program Files\s-ui"
set "SERVICE_NAME=s-ui"

echo Установка S-UI в каталог: %INSTALL_DIR%

REM Создание каталога установки
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%\db" mkdir "%INSTALL_DIR%\db"
if not exist "%INSTALL_DIR%\logs" mkdir "%INSTALL_DIR%\logs"
if not exist "%INSTALL_DIR%\cert" mkdir "%INSTALL_DIR%\cert"

REM Копирование файлов
echo Копирование файлов...
copy "sui.exe" "%INSTALL_DIR%\" >nul
copy "s-ui-windows.xml" "%INSTALL_DIR%\" >nul
copy "s-ui-windows.bat" "%INSTALL_DIR%\" >nul

REM Проверка наличия WinSW
set "WINSW_PATH=%INSTALL_DIR%\winsw.exe"
if not exist "%WINSW_PATH%" (
    echo Загрузка WinSW...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/winsw/winsw/releases/download/v2.12.0/WinSW-x64.exe' -OutFile '%WINSW_PATH%'}"
    if exist "%WINSW_PATH%" (
        echo WinSW успешно загружен
    ) else (
        echo Предупреждение: не удалось загрузить WinSW. Установка службы будет пропущена.
        echo Вы можете скачать WinSW вручную: https://github.com/winsw/winsw/releases
    )
)

REM Установка службы Windows
if exist "%WINSW_PATH%" (
    echo Установка службы Windows...
    cd /d "%INSTALL_DIR%"
    copy "winsw.exe" "s-ui-service.exe" >nul
    copy "s-ui-windows.xml" "s-ui-service.xml" >nul
        
    REM Установка службы
    s-ui-service.exe install
    if %errorLevel% equ 0 (
        echo Служба успешно установлена
    ) else (
        echo Предупреждение: не удалось установить службу. Ее можно установить вручную позже.
    )
)

REM Запуск миграции
echo Запуск миграции базы данных...
cd /d "%INSTALL_DIR%"
sui.exe migrate
if %errorLevel% equ 0 (
    echo Миграция успешно завершена
) else (
    echo Предупреждение: миграция не выполнена или база данных новая
)

REM Получение сетевой конфигурации
echo.
echo ========================================
echo Сетевая конфигурация
echo ========================================

REM Получение локальных IP-адресов
echo Доступные IP-адреса:
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    echo   %%i
)

REM Получение настроек панели
echo.
set /p panel_port="Введите порт панели (по умолчанию: 2095): "
if "%panel_port%"=="" set "panel_port=2095"

set /p panel_path="Введите путь панели (по умолчанию: /app/): "
if "%panel_path%"=="" set "panel_path=/app/"

set /p sub_port="Введите порт подписки (по умолчанию: 2096): "
if "%sub_port%"=="" set "sub_port=2096"

set /p sub_path="Введите путь подписки (по умолчанию: /sub/): "
if "%sub_path%"=="" set "sub_path=/sub/"

REM Применение настроек
echo.
echo Применение настроек...
cd /d "%INSTALL_DIR%"
sui.exe setting -port %panel_port% -path "%panel_path%" -subPort %sub_port% -subPath "%sub_path%"

REM Получение учетных данных администратора
echo.
echo ========================================
echo Настройка администратора
echo ========================================

set /p admin_username="Введите имя пользователя администратора (по умолчанию: admin): "
if "%admin_username%"=="" set "admin_username=admin"

set /p admin_password="Введите пароль администратора: "
if "%admin_password%"=="" (
    echo Ошибка: пароль не может быть пустым
    pause
    exit /b 1
)

REM Настройка учетных данных администратора
echo Настройка учетных данных администратора...
sui.exe admin -username "%admin_username%" -password "%admin_password%"

REM Запуск службы
echo Запуск службы S-UI...
net start %SERVICE_NAME%
if %errorLevel% equ 0 (
    echo Служба успешно запущена
) else (
    echo Предупреждение: не удалось запустить службу. Ее можно запустить вручную позже.
)

REM Создание ярлыка на рабочем столе
echo Создание ярлыка на рабочем столе...
set "DESKTOP=%USERPROFILE%\Desktop"
if exist "%DESKTOP%" (
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\S-UI.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\s-ui-windows.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Панель управления S-UI'; $Shortcut.Save()}"
    echo Ярлык на рабочем столе создан
)

REM Создание ярлыка в меню Пуск
echo Создание ярлыка в меню Пуск...
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"
if exist "%START_MENU%" (
    if not exist "%START_MENU%\S-UI" mkdir "%START_MENU%\S-UI"
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%START_MENU%\S-UI\Панель управления S-UI.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\s-ui-windows.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Панель управления S-UI'; $Shortcut.Save()}"
    echo Ярлык в меню Пуск создан
)

REM Настройка прав
echo Настройка прав доступа...
icacls "%INSTALL_DIR%" /grant "Users:(OI)(CI)RX" /T >nul
icacls "%INSTALL_DIR%\db" /grant "Users:(OI)(CI)F" /T >nul
icacls "%INSTALL_DIR%\logs" /grant "Users:(OI)(CI)F" /T >nul

REM Создание переменной окружения
echo Настройка переменной окружения...
setx SUI_HOME "%INSTALL_DIR%" /M >nul

REM Показ итоговой конфигурации
echo.
echo ========================================
echo Установка успешно завершена!
echo ========================================
echo.
echo S-UI установлен в каталог: %INSTALL_DIR%
echo.
echo Конфигурация:
echo   Порт панели: %panel_port%
echo   Путь панели: %panel_path%
echo   Порт подписки: %sub_port%
echo   Путь подписки: %sub_path%
echo   Имя пользователя администратора: %admin_username%
echo.
echo URL для доступа:
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set "ip=%%i"
    set "ip=!ip: =!"
    echo   Панель: http://!ip!:%panel_port%%panel_path%
    echo   Подписка: http://!ip!:%sub_port%%sub_path%
)
echo.
echo Имя службы: %SERVICE_NAME%
echo.
echo Полезные команды:
echo   net start %SERVICE_NAME%    - запустить службу
echo   net stop %SERVICE_NAME%     - остановить службу
echo   sc query %SERVICE_NAME%     - проверить состояние службы
echo.
echo Также можно использовать ярлык на рабочем столе или пункт меню Пуск.
echo.
pause
