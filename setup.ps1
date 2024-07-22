$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$workspace = $currentPath
Set-Location $workspace

Write-Output "Current Path: $currentPath"

try {
    $gitVersion = & git --version 2>$null
    if ($gitVersion) {
        Write-Output "$gitVersion is installed"
    } else {
        Write-Output "Git is not installed, please install Git"
        exit
    }
} catch {
    Write-Output "Git is not installed, please install Git"
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
    Write-Output "This is not a git repository"
    Write-Output "Clone the repository using git clone"
    & git clone -b windows-dev https://github.com/clearsky-mio/iGibson.git
}

$workspace = "$currentPath\iGibson"
Set-Location $workspace

$requirementsExist = (Test-Path "$workspace\requirements-dev.txt")
$igibsonExist = (Test-Path "$workspace\igibson")
$testsExist = (Test-Path "$workspace\tests")

if ($requirementsExist -eq $false) {
    Write-Output "requirements-dev.txt does not exist"
    Write-Output "Please Check if you have cloned the repository correctly"
    exit
}

& git submodule update --init --recursive

$python38Path = & py -3.8 -c "import sys; print(sys.executable)" 2>$null
if ($python38Path) {
    $pythonPath = $python38Path
    Write-Output "use $python38Path"
} else {
    $pythonPath = & py -3 -c "import sys; print(sys.executable)" 2>$null
    if ($pythonPath) {
        Write-Output "Python 3.8 is not installed, use default python $pythonPath"
    } else {
        Write-Output "Python 3 is not installed, please install Python 3"
        exit
    }
}

python -m venv venv --system-site-packages
. "$workspace\venv\Scripts\Activate.ps1"

$env:HTTP_PROXY = ""
$env:HTTPS_PROXY = ""
python -m pip install -r requirements-dev.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

& build.ps1

& test.ps1