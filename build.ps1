param(
    [ValidateSet('all', 'en', 'nl', 'clean')]
    [string]$Target = 'all'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildDir = Join-Path $root 'build'

function Assert-CommandExists([string]$CommandName) {
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        throw "Required command '$CommandName' was not found in PATH. Install TeX Live or MiKTeX (with latexmk + xelatex), then retry."
    }
}

function Build-Language([ValidateSet('en', 'nl')] [string]$Lang) {
    $srcDir = Join-Path $root ("src\\$Lang")
    $outDir = Join-Path $buildDir $Lang

    New-Item -ItemType Directory -Force $outDir | Out-Null

    Push-Location $srcDir
    try {
        latexmk -xelatex -interaction=nonstopmode -file-line-error ("-outdir=" + $outDir) main.tex
    }
    finally {
        Pop-Location
    }

    Copy-Item (Join-Path $outDir 'main.pdf') (Join-Path $buildDir ("cv-template-$Lang.pdf")) -Force
}

Assert-CommandExists 'latexmk'
Assert-CommandExists 'xelatex'

switch ($Target) {
    'clean' {
        if (Test-Path (Join-Path $buildDir 'en')) { Remove-Item -Recurse -Force (Join-Path $buildDir 'en') }
        if (Test-Path (Join-Path $buildDir 'nl')) { Remove-Item -Recurse -Force (Join-Path $buildDir 'nl') }
        if (Test-Path (Join-Path $buildDir 'cv-template-en.pdf')) { Remove-Item -Force (Join-Path $buildDir 'cv-template-en.pdf') }
        if (Test-Path (Join-Path $buildDir 'cv-template-nl.pdf')) { Remove-Item -Force (Join-Path $buildDir 'cv-template-nl.pdf') }

        New-Item -ItemType Directory -Force (Join-Path $buildDir 'en') | Out-Null
        New-Item -ItemType Directory -Force (Join-Path $buildDir 'nl') | Out-Null

        Write-Host 'Cleaned build artefacts.'
    }
    'en' { Build-Language 'en' }
    'nl' { Build-Language 'nl' }
    Default {
        Build-Language 'nl'
        Build-Language 'en'
    }
}
