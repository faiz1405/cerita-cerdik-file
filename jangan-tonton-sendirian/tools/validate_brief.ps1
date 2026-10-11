# Script untuk memvalidasi brief episode Jangan Tonton Sendirian
# Usage: powershell -ExecutionPolicy Bypass -File jangan-tonton-sendirian\tools\validate_brief.ps1 [-Eps <number>]

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

	# 1. Durasi & kata. Estimasi 160-178s karena CapCut merender 84-100% estimasi (data Cerita Cerdik eps 59-65),
	#    sehingga hasil render jatuh di +-150-160s.
	$narration = Get-BriefSection $briefText 'videoNarration'
	$speed = Get-TtsSpeed $briefText
	$words = Get-WordCount $narration
	$est = Get-EstimatedSeconds $narration $speed

	if ($speed -ne 1.0) { $errors += "TTS Speed bukan 1.0 (ditemukan $speed)" }
	if ($words -lt 290 -or $words -gt 330) {
		$errors += "Jumlah kata di luar batas aman (290-330). Ditemukan: $words kata"
	}
	if ($est -lt 160 -or $est -gt 178) {
		$errors += "Estimasi durasi melenceng. Ditemukan: ${est}s (Target estimasi: 160-178s agar render +-150-160s)"
	}

	$durationTag = Get-BriefSection $briefText 'duration'
	if ($durationTag -ne "160") { $errors += "Tag [duration] bukan 160 (ditemukan $durationTag)" }

	# Hanya jeda 1.0s yang sudah teruji di pipeline ini.
	foreach ($m in [regex]::Matches([string]$narration, '<break time="([\d\.]+)s"\s*/>')) {
		if ($m.Groups[1].Value -ne '1.0') {
			$warnings += "Jeda $($m.Groups[1].Value)s belum teruji (pakai <break time=`"1.0s`"/>)"
			break
		}
	}

	# 2. Shots & rincian per shot
	$shots = Get-Shots (Get-BriefSection $briefText 'videoContent')
	if ($shots.Count -lt 6 -or $shots.Count -gt 8) {
		$errors += "Jumlah shot di luar standar (6-8). Ditemukan: $($shots.Count) shot"
	}
	if (-not $hasilText -or $hasilText -notmatch 'PER SHOT') {
		$errors += "hasil_brief.txt tidak memuat 'RINCIAN VISUAL & AUDIO PER SHOT'"
	}

	# 3. Twist
	if ($hasilText -and $hasilText -notmatch '(?i)twist') {
		$warnings += "Tidak ada 'Kunci Twist' di hasil_brief (AGENTS bagian 2.3 & bagian 5.6)"
	}

	# 4. Etika: semua cerita fiksi (AGENTS bagian 5.4 no. 1)
	$allText = $briefText + "`n" + $hasilText
	if ($allText -match '(?i)((?<!bukan\s)(kisah nyata|kejadian nyata)|true story|kiriman penonton)') {
		$errors += "Mengklaim kisah nyata / kiriman penonton ('$($Matches[0])'). Semua cerita fiksi (AGENTS bagian 5.4)"
	}

	# 5. ID CapCut belum diisi
	if ($briefText -match '\[ISI') {
		$warnings += "Masih ada placeholder [ISI ...] (ID TTS/BGM/subtitle) - isi sebelum di-copy ke CapCut"
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
if (-not $dirs) {
	Write-Host "Belum ada folder episode di $JTS_ROOT\briefs" -ForegroundColor Yellow
}

foreach ($d in $dirs) {
	Validate-Episode $d
}
