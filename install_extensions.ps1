# Script de Instalação de Extensões - Versão PowerShell Nativa
# Configurado para ambiente Windows puro

$ErrorActionPreference = "Continue"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   PREPARANDO AMBIENTE GOOGLE ANTIGRAVITY e VSCODE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. VERIFICAÇÃO DE REQUISITOS ---
Write-Host "[*] Verificando se os comandos estão disponíveis..." -ForegroundColor Yellow

$availableClis = New-Object System.Collections.Generic.List[string]
$possibleClis = @("antigravity", "code")

foreach ($cmd in $possibleClis) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-Host "[OK] $cmd detectado." -ForegroundColor Green
        $availableClis.Add($cmd)
    } else {
        Write-Host "[AVISO] O comando '$cmd' não foi encontrado no PATH." -ForegroundColor DarkYellow
    }
}

if ($availableClis.Count -eq 0) {
    Write-Host "`n[ERRO] Nenhum dos comandos (antigravity ou code) foi encontrado. Instalação abortada." -ForegroundColor Red
    Pause
    exit
}
Write-Host ""

# --- 2. LIMPEZA: DESINSTALAR EXTENSÕES EXISTENTES ---
Write-Host "[*] Removendo todas as extensões existentes para uma instalação limpa..." -ForegroundColor Yellow
Write-Host "Isso pode levar alguns momentos..." -ForegroundColor Gray

foreach ($cli in $availableClis) {
    Write-Host "[-] Limpando $cli..." -ForegroundColor Gray
    try {
        $extensions = & $cli --list-extensions
        foreach ($ext in $extensions) {
            if ($ext -match '^[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+$') {
                Write-Host "    Removendo: $ext" -ForegroundColor DarkGray
                & $cli --uninstall-extension $ext | Out-Null
            }
        }
    } catch {
        Write-Host "[!] Falha ao processar limpeza em $cli" -ForegroundColor DarkYellow
    }
}

Write-Host "[OK] Limpeza concluída." -ForegroundColor Green
Write-Host ""

# --- 3. INSTALAÇÃO DAS EXTENSÕES PREMIUM ---
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   INICIANDO INSTALAÇÃO DAS EXTENSÕES PREMIUM" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$extensionsToInstall = @(
    @{ ID = "ms-python.python"; Desc = "Python (Suporte principal)" },
    @{ ID = "ms-python.vscode-pylance"; Desc = "Pylance (Inteligência de linguagem Python)" },
    @{ ID = "charliermarsh.ruff"; Desc = "Ruff (Linter e formatador ultra-rápido)" },
    @{ ID = "batisteo.vscode-django"; Desc = "Django (Templates e snippets)" },
    @{ ID = "dsznajder.es7-react-js-snippets"; Desc = "ES7+ React Snippets" },
    @{ ID = "bradlc.vscode-tailwindcss"; Desc = "Tailwind CSS IntelliSense" },
    @{ ID = "esbenp.prettier-vscode"; Desc = "Prettier (Formatador universal)" },
    @{ ID = "formulahendry.auto-rename-tag"; Desc = "Auto Rename Tag" },
    @{ ID = "naumovs.color-highlight"; Desc = "Color Highlight" },
    @{ ID = "mechatroner.rainbow-csv"; Desc = "Rainbow CSV" },
    @{ ID = "eamodio.gitlens"; Desc = "GitLens" },
    @{ ID = "github.vscode-pull-request-github"; Desc = "GitHub Pull Requests" },
    @{ ID = "ms-vscode.powershell"; Desc = "PowerShell" },
    @{ ID = "PKief.material-icon-theme"; Desc = "Material Icon Theme" },
    @{ ID = "James-Yu.latex-workshop"; Desc = "LaTeX (Sintaxe e Visualização PDF)" }
)

$total = $extensionsToInstall.Count
$counter = 1

foreach ($ext in $extensionsToInstall) {
    Write-Host "[$counter/$total] Instalando: $($ext.Desc) ($($ext.ID))..." -ForegroundColor Yellow
    
    foreach ($cli in $availableClis) {
        # Evita tentar instalar Pylance no Antigravity pois não existe no marketplace deles
        if ($cli -eq "antigravity" -and $ext.ID -eq "ms-python.vscode-pylance") {
            continue
        }

        # Executa o comando e captura a saída
        $output = & $cli --install-extension $($ext.ID) --force 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] $cli" -ForegroundColor Green
        } else {
            if ($output -match "not found") {
                Write-Host "    [AVISO] $($ext.ID) não encontrado no Marketplace do $cli" -ForegroundColor DarkYellow
            } else {
                Write-Host "    [ERRO] Falha no $cli" -ForegroundColor Red
                Write-Host "    Motivo: $output" -ForegroundColor Gray
            }
        }
    }
    $counter++
}

# --- 4. CONFIGURAÇÃO DO SETTINGS.JSON ---
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   SINCRONIZANDO CONFIGURAÇÕES (settings.json)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$settingsSource = Join-Path $PSScriptRoot "settings.json"
if (Test-Path $settingsSource) {
    $paths = @(
        "$env:APPDATA\Antigravity\User\settings.json",
        "$env:APPDATA\Code\User\settings.json"
    )

    foreach ($dest in $paths) {
        $dir = Split-Path $dest
        if (Test-Path $dir) {
            Write-Host "[*] Aplicando configurações em: $dest" -ForegroundColor Yellow
            Copy-Item -Path $settingsSource -Destination $dest -Force
            Write-Host "    [OK]" -ForegroundColor Green
        }
    }
} else {
    Write-Host "[AVISO] Arquivo settings.json não encontrado na pasta do script." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "   PROCESSO CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
Write-Host "   Ambiente configurado com extensões e settings." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Green
Pause
