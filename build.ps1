$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$workspace = $currentPath
Set-Location $workspace

$venvPath = Join-Path $workspace "venv"
if (Test-Path $venvPath) {
    # activate venv
    . "$venvPath\Scripts\Activate.ps1"
} else {
    Write-Output "venv does not exist at $venvPath"
    Write-Output "Please run setup.ps1 to setup environment"
    exit
}

& ./clean.ps1

$env:HTTP_PROXY = ""
$env:HTTPS_PROXY = ""
pip install -e .
pip install -r requirements-dev.txt -i https://pypi.tuna.tsinghua.edu.cn/simple