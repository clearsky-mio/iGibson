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

pip install pytest~=6.2.3 pytest-cov>=3.0.0 -i https://pypi.tuna.tsinghua.edu.cn/simple

pytest --ignore benchmarks --cov=igibson --cov-report=html tests