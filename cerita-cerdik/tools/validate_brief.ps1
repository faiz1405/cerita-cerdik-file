# Script untuk memvalidasi brief episode Cerita Cerdik
# Usage: powershell -ExecutionPolicy Bypass -File cerita-cerdik\tools\validate_brief.ps1 [-Eps <number>]

param ([int] $Eps = 0)

. "$PSScriptRoot\brief_lib.ps1"

function Validate-Episode {
	param ([IO.DirectoryInfo] $Dir)
	$episode = Get-EpisodeFiles $Dir
	if (-not $episode.BriefPath) {
		Write-Host "[!] Eps $($episode.Number): Tidak ada file brief_*.txt" -ForegroundColor Red
		return
	}
	
	$briefText = Read-TextFile $episode.BriefPath
	$hasilText = Read-TextFile $episode.HasilPath
	
	$errors = @()
	$warnings = @()
	
	# 1. Cek Durasi & Kata
	$narration = Get-BriefSection $briefText 'videoNarration'
	$speed = Get-TtsSpeed $briefText
	$words = Get-WordCount $narration
	$est = Get-EstimatedSeconds $narration $speed
	
	if ($speed -ne 1.0) { $errors += "TTS Speed bukan 1.0 (ditemukan $speed)" }
	if ($words -lt 290 -or $words -gt 330) {
		$errors += "Jumlah kata di luar batas aman (290-330). Ditemukan: $words kata"
	}
	if ($est -lt 150 -or $est -gt 175) {
		$errors += "Estimasi durasi melenceng. Ditemukan: ${est}s (Target: ~160s)"
	}
	
	$durationTag = Get-BriefSection $briefText 'duration'
	if ($durationTag -ne "160") { $errors += "Tag [duration] bukan 160 (ditemukan $durationTag)" }
	
	# 2. Cek Shots & Per Shot Rincian
	$content = Get-BriefSection $briefText 'videoContent'
	$shots = Get-Shots $content
	
	if ($shots.Count -lt 5 -or $shots.Count -gt 8) {
		$errors += "Jumlah shot di luar standar (5-8). Ditemukan: $($shots.Count) shot"
	}
	
	if (-not $hasilText -or $hasilText -notmatch 'PER SHOT') {
		$errors += "hasil_brief.txt tidak memuat 'RINCIAN VISUAL & AUDIO PER SHOT'"
	}
	
	# 3. Cek Trik "Jebakan / Uno Reverse"
	if ($hasilText -and $hasilText -notmatch '(?i)(jebakan|trik|akal|tertipu|syok|mustahil)') {
		$warnings += "Tidak terdeteksi elemen jebakan / trik pembalikan (Uno Reverse) di naskah."
	}
	
	# Output Report
	Write-Host "=== Episode $($episode.Number): $($episode.Slug) ===" -ForegroundColor Cyan
	Write-Host "Kata: $words | Estimasi: ${est}s | Speed: $speed | Shot: $($shots.Count)"
	
	if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
		Write-Host " [PASSED] Naskah memenuhi standar." -ForegroundColor Green
	} else {
		foreach ($e in $errors) { Write-Host " [ERROR] $e" -ForegroundColor Red }
		foreach ($w in $warnings) { Write-Host " [WARN]  $w" -ForegroundColor Yellow }
	}
	Write-Host ""
}

$dirs = Get-AllEpisodeDirs
if ($Eps -gt 0) {
	$padded = '{0:D2}' -f $Eps
	$dirs = $dirs | Where-Object { $_.Name -match "^eps_0*${Eps}_" -or $_.Name -match "^eps_${padded}_" }
}

foreach ($d in $dirs) {
	Validate-Episode $d
}
