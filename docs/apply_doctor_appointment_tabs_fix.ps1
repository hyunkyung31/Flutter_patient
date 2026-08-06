#Requires -Version 5.1
<#
.SYNOPSIS
  의사앱 appointment 탭 빌드 오류(_AppointmentFilter.scheduled not found) 수정
.EXAMPLE
  irm https://raw.githubusercontent.com/hyunkyung31/Flutter_patient/cursor/fix-appointment-filter-enum-61c8/docs/apply_doctor_appointment_tabs_fix.ps1 | iex

  .\docs\apply_doctor_appointment_tabs_fix.ps1 -DoctorAppRoot D:\flutter\doctor_app
#>
param(
  [string]$DoctorAppRoot = 'D:\flutter\doctor_app'
)

$ErrorActionPreference = 'Stop'
$target = Join-Path $DoctorAppRoot 'lib\features\appointment\view\appointment_list_view.dart'

if (-not (Test-Path -LiteralPath $target)) {
  throw "파일을 찾을 수 없습니다: $target`n-DoctorAppRoot 경로를 확인하세요."
}

$text = Get-Content -LiteralPath $target -Raw -Encoding UTF8
$original = $text

# 1) enum 만 깨진 경우 (이전 불완전 패치 적용 상태)
$oldEnum = 'enum _AppointmentFilter { active, requested, confirmed, all }'
$newEnum = 'enum _AppointmentFilter { scheduled, completed }'
$text = $text.Replace($oldEnum, $newEnum)

# 2) 아직 구탭이면 전체 파일로 교체
$needsFull = ($text -match '_AppointmentFilter\.active') -or ($text -match "label:\s*Text\('진행중'\)")

if ($needsFull) {
  $uri = 'https://raw.githubusercontent.com/hyunkyung31/Flutter_patient/cursor/fix-appointment-filter-enum-61c8/docs/flutter_doctor_appointment/features_appointment/view/appointment_list_view.dart'
  Write-Host "Downloading full fixed file..."
  $tmp = Join-Path $env:TEMP 'appointment_list_view_fixed.dart'
  Invoke-WebRequest -Uri $uri -OutFile $tmp -UseBasicParsing
  $text = Get-Content -LiteralPath $tmp -Raw -Encoding UTF8
}

if ($text -eq $original) {
  if ($text.Contains($newEnum)) {
    Write-Host "Already fixed: $target"
    exit 0
  }
  throw "자동 수정 패턴을 찾지 못했습니다. 파일 끝 enum 을 수동으로 scheduled, completed 로 바꿔주세요."
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($target, $text, $utf8NoBom)

Write-Host "Fixed: $target"
if ($text.Contains($newEnum)) {
  Write-Host "enum OK: scheduled, completed"
} else {
  Write-Warning "enum 확인 실패 — 파일 맨 아래 enum 을 확인하세요."
}
Write-Host "이제: flutter run -d R3CN30DKS2L"
