@echo off
REM ============================================================
REM AUTO-INSTALADOR PYTHON PARA AZURE
REM Execute com privilégios de Administrador
REM ============================================================

setlocal enabledelayedexpansion

cls
echo.
echo ============================================================
echo     🌐 AUTO-INSTALADOR PYTHON PARA AZURE VM
echo ============================================================
echo.

REM Verifica se é Admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERRO: Precisa executar como Administrador!
    echo.
    echo Clique direito neste arquivo → "Executar como administrador"
    echo.
    pause
    exit /b 1
)

echo ✅ Executando como Administrador
echo.

REM Passo 1: Verifica se Python já está instalado
echo [1/5] Verificando se Python já está instalado...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Python já está instalado!
    python --version
    goto :executar_protecao
)

echo ❌ Python não encontrado. Instalando...
echo.

REM Passo 2: Verifica se winget está disponível
echo [2/5] Verificando Windows Package Manager...
winget --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Windows Package Manager disponível
    goto :instalar_com_winget
)

echo ⚠️  winget não disponível. Tentando outro método...
goto :instalar_com_download

REM ============================================================
REM INSTALAÇÃO VIA WINGET
REM ============================================================

:instalar_com_winget
echo.
echo [3/5] Instalando Python 3.11 via winget...
echo.

winget install Python.Python.3.11 -y --accept-source-agreements

if %errorlevel% equ 0 (
    echo ✅ Python instalado com sucesso!
    echo.
    echo [4/5] Reiniciando PowerShell para recarregar PATH...
    REM Não precisa fazer nada, Python já está no PATH
    echo ✅ PATH atualizado
    echo.
    goto :testar_python
) else (
    echo ⚠️  Falha com winget. Tentando download direto...
    goto :instalar_com_download
)

REM ============================================================
REM INSTALAÇÃO VIA DOWNLOAD DIRETO
REM ============================================================

:instalar_com_download
echo.
echo [3/5] Baixando instalador Python 3.11...
echo.

set "python_installer=%temp%\python-3.11-installer.exe"

REM Baixa Python
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe' -OutFile '%python_installer%'"

if not exist "%python_installer%" (
    echo ❌ Falha ao baixar Python!
    echo.
    echo Tente instalação manual em: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo ✅ Instalador baixado
echo.

echo [4/5] Executando instalador (pode demorar 2-3 minutos)...
echo.

REM Instala silenciosamente
"%python_installer%" /quiet InstallAllUsers=1 PrependPath=1

REM Aguarda conclusão
timeout /t 3 /nobreak

REM Limpa instalador
del "%python_installer%"

REM ============================================================
REM TESTE E CONFIGURAÇÃO
REM ============================================================

:testar_python
echo.
echo [5/5] Testando instalação...
echo.

REM Pequeno delay para sistema atualizar
timeout /t 2 /nobreak

REM Tenta encontrar Python
set "python_path="

python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Python está funcionando!
    python --version
    goto :executar_protecao
)

REM Se não funcionar, procura manualmente
if exist "C:\Program Files\Python311\python.exe" (
    set "python_path=C:\Program Files\Python311\python.exe"
    echo ✅ Python encontrado em Program Files
    goto :executar_protecao
)

if exist "C:\Program Files (x86)\Python311\python.exe" (
    set "python_path=C:\Program Files (x86)\Python311\python.exe"
    echo ✅ Python encontrado em Program Files (x86)
    goto :executar_protecao
)

echo ⚠️  Python instalado mas PATH não atualizado
echo.
echo Solução: Reinicie a máquina
echo.
pause
exit /b 0

REM ============================================================
REM EXECUTAR PROTEÇÃO
REM ============================================================

:executar_protecao
echo.
echo ============================================================
echo     ✅ PYTHON ESTÁ PRONTO!
echo ============================================================
echo.

REM Verifica se arquivo de proteção existe
if not exist "protecao_maquina.py" (
    echo ⚠️  Arquivo 'protecao_maquina.py' não encontrado
    echo.
    echo Próximos passos:
    echo 1. Copie protecao_maquina.py para a mesma pasta
    echo 2. Execute este script novamente
    echo.
    pause
    exit /b 1
)

echo 🚀 Iniciando Sistema de Proteção...
echo.

if not "!python_path!"=="" (
    "!python_path!" protecao_maquina.py
) else (
    python protecao_maquina.py
)

echo.
echo ✅ Proteção encerrada
echo.
pause
exit /b 0
