@echo off
setlocal enabledelayedexpansion

:: 设置变量
set "TRON_DIR=%USERPROFILE%\tron"
set "JDK_VERSION=18.0.2.1"
set "JDK_BUILD=10"
set "JDK_URL=https://download.oracle.com/java/18/archive/jdk-%JDK_VERSION%_%JDK_BUILD%-windows-x64_bin.exe"
set "GIT_URL=https://github.com/tronprotocol/java-tron.git"
set "CONFIG_URL=https://raw.githubusercontent.com/tronprotocol/java-tron/master/main_net_config.conf"
set "JDK_INSTALLER=%TRON_DIR%\jdk_installer.exe"
set "GIT_INSTALLER=%TRON_DIR%\git_installer.exe"
set "JAVA_HOME=C:\Program Files\Java\jdk-%JDK_VERSION%"
set "GRADLE_VERSION=7.3.3"
set "GRADLE_ZIP=gradle-%GRADLE_VERSION%-bin.zip"
set "GRADLE_URL=https://services.gradle.org/distributions/%GRADLE_ZIP%"
set "GRADLE_HOME=%TRON_DIR%\gradle-%GRADLE_VERSION%"

:: 创建工作目录
mkdir "%TRON_DIR%"
cd /d "%TRON_DIR%"

:: 下载并安装 JDK
powershell -Command "Invoke-WebRequest -Uri %JDK_URL% -OutFile %JDK_INSTALLER%"
start /wait "" "%JDK_INSTALLER%" /s

:: 设置 JAVA_HOME 环境变量
setx JAVA_HOME "%JAVA_HOME%"
set "PATH=%JAVA_HOME%\bin;%PATH%"
setx PATH "%JAVA_HOME%\bin;%PATH%"

:: 下载并安装 Git
powershell -Command "Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe -OutFile %GIT_INSTALLER%"
start /wait "" "%GIT_INSTALLER%" /VERYSILENT

:: 等待 Git 安装完成并设置路径
set "GIT_PATH=C:\Program Files\Git\bin\git.exe"
:waitForGit
if not exist "!GIT_PATH!" (
    echo Waiting for Git installation to complete...
    timeout /t 5 /nobreak >nul
    goto waitForGit
)
setx PATH "%PATH%;C:\Program Files\Git\bin"

:: 克隆 java-tron 仓库
"!GIT_PATH!" clone %GIT_URL%

:: 下载并安装 Gradle
powershell -Command "Invoke-WebRequest -Uri %GRADLE_URL% -OutFile %GRADLE_ZIP%"
powershell -Command "Expand-Archive -Path %GRADLE_ZIP% -DestinationPath %TRON_DIR%"
setx GRADLE_HOME "%GRADLE_HOME%"
set "PATH=%GRADLE_HOME%\bin;%PATH%"
setx PATH "%GRADLE_HOME%\bin;%PATH%"

:: 构建项目
cd java-tron
gradle build -x test

:: 下载主网配置文件
powershell -Command "Invoke-WebRequest -Uri %CONFIG_URL% -OutFile main_net_config.conf"

:: 启动全节点
start "" java -Xmx16g -XX:+UseConcMarkSweepGC -jar build\libs\FullNode.jar -c main_net_config.conf

endlocal
