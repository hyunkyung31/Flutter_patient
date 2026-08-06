#Requires -Version 5.1
<#
.SYNOPSIS
  Flutter_doctor PR #46 의 main 머지 충돌을 해결본 파일로 덮어쓰고 커밋·푸시합니다.
#>
param(
  [string]$DoctorAppRoot = 'D:\flutter\doctor_app'
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

if (-not (Test-Path -LiteralPath $DoctorAppRoot)) {
  throw "Doctor app path not found: $DoctorAppRoot"
}

Push-Location $DoctorAppRoot
try {
  git fetch origin
  git checkout cursor/doctor-appointment-list-6355
  git merge origin/main
  $mergeExit = $LASTEXITCODE

  Copy-Item -Force (Join-Path $here 'app.dart') 'lib\app.dart'
  Copy-Item -Force (Join-Path $here 'app_router.dart') 'lib\routes\app_router.dart'
  Copy-Item -Force (Join-Path $here 'home_view.dart') 'lib\features\home\view\home_view.dart'
  Copy-Item -Force (Join-Path $here 'api_endpoints.dart') 'lib\core\network\api_endpoints.dart'

  git add lib/app.dart lib/routes/app_router.dart lib/features/home/view/home_view.dart lib/core/network/api_endpoints.dart
  git add -u
  # stage any other merged files from main if merge had conflicts
  if ($mergeExit -ne 0) {
    git add -A
  }

  $pending = git diff --cached --name-only
  if (-not $pending) {
    Write-Host 'Nothing to commit (already resolved?)'
  } else {
    git commit -m "fix: resolve merge conflicts with main for appointment PR"
  }

  git push origin cursor/doctor-appointment-list-6355
  Write-Host 'Done. Merge https://github.com/hyunkyung31/Flutter_doctor/pull/46'
}
finally {
  Pop-Location
}
