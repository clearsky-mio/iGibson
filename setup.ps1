$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$workspace = $currentPath
Set-Location $workspace

$dataPath = "E:\project\Robot\data"
if (-not (Test-Path $dataPath)) {
    Write-Host "Data path does not exist" -ForegroundColor Yellow
    $dataPath = Read-Host "Enter the path to the data folder"
}

Write-Host "Current Path: $currentPath" -ForegroundColor Green

try {
    $gitVersion = & git --version 2>$null
    if ($gitVersion) {
        Write-Host "$gitVersion is installed" -ForegroundColor Green
    } else {
        Write-Host "Git is not installed, please install Git" -ForegroundColor Red
        exit
    }
} catch {
    Write-Host "Git is not installed, please install Git" -ForegroundColor Red
    exit
}

try {
    $isGitRepo = & git rev-parse --is-inside-work-tree $currentPath 2>$null
    if ($isGitRepo -eq "true") {
        $isGitRepo = $true
    } else {
        $isGitRepo = $false
    }
} catch {
    $isGitRepo = $false
}

if ($isGitRepo -eq $false) {
    Write-Host "This is not a git repository" -ForegroundColor Yellow
    Write-Host "Clone the repository using git clone" -ForegroundColor Yellow
    & git clone -b auto-setup https://github.com/clearsky-mio/iGibson.git
    $workspace = "$currentPath\iGibson"
    Set-Location $workspace
}

$requirementsExist = (Test-Path "$workspace\requirements-dev.txt")
$igibsonExist = (Test-Path "$workspace\igibson")
$testsExist = (Test-Path "$workspace\tests")

if ($requirementsExist -eq $false) {
    Write-Host "requirements-dev.txt does not exist" -ForegroundColor Red
    Write-Host "Please Check if you have cloned the repository correctly" -ForegroundColor Red
    exit
}

& git submodule update --init --recursive

$python38Path = & py -3.8 -c "import sys; print(sys.executable)" 2>$null
if ($python38Path) {
    $pythonPath = $python38Path
    Write-Host "use $python38Path" -ForegroundColor Green
} else {
    $pythonPath = & py -3 -c "import sys; print(sys.executable)" 2>$null
    if ($pythonPath) {
        Write-Host "Python 3.8 is not installed, use default python $pythonPath" -ForegroundColor Yellow
    } else {
        Write-Host "Python 3 is not installed, please install Python 3" -ForegroundColor Red
        exit
    }
}

& cmd /c "mklink /D igibson\data $dataPath"

& $pythonPath -m venv venv --system-site-packages
$venvPath = Join-Path $workspace "venv"
. "$venvPath\Scripts\Activate.ps1"

& $venvPath\Scripts\python -m pip install --upgrade pip  -i https://pypi.tuna.tsinghua.edu.cn/simple

try {
    & ./build.ps1
} catch {
    Write-Host "Error running build.ps1: $_" -ForegroundColor Red
    exit
}

try {
    & ./test.ps1
} catch {
    Write-Host "Error running test.ps1: $_" -ForegroundColor Red
    exit
}