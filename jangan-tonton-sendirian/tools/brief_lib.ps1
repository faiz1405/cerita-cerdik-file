# Shared helpers untuk tooling Jangan Tonton Sendirian (dot-source file ini).
# Salinan dari cerita-cerdik/tools/brief_lib.ps1; JTS_ROOT = folder jangan-tonton-sendirian.
# Usage: . "$PSScriptRoot\brief_lib.ps1"

$JTS_ROOT = Split-Path -Parent $PSScriptRoot
# Kecepatan baca TTS CapCut pada speed 1.0, dikalibrasi dari suara narator Cerita Cerdik (eps 44-56).
# Bila suara narator horror berbeda, kalibrasi ulang setelah +-3 render (bandingkan durasi asli vs estimasi).
$JTS_BASE_WPM = 118

function Read-TextFile {
	param ([string] $Path)
	if (-not $Path -or -not (Test-Path $Path)) { return '' }
	return [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
}

# Ambil isi di antara '# [tag]' dan header '# [' berikutnya.
function Get-BriefSection {
	param ([string] $Text, [string] $Tag)
	$pattern = '(?s)#\s*\[' + [regex]::Escape($Tag) + '\][^\r\n]*\r?\n(.*?)(?=\r?\n#\s*\[|\z)'
	$match = [regex]::Match($Text, $pattern)
	if (-not $match.Success) { return $null }
	return $match.Groups[1].Value.Trim()
}

function Remove-BreakTags {
	param ([string] $Text)
	return ($Text -replace '<break[^>]*/>', ' ')
}

function Get-WordCount {
	param ([string] $Text)
	if (-not $Text) { return 0 }
	$clean = Remove-BreakTags $Text
	return @($clean -split '\s+' | Where-Object { $_ -match '\w' }).Count
}

function Get-BreakSeconds {
	param ([string] $Text)
	$total = 0.0
	foreach ($m in [regex]::Matches($Text, '<break time="([\d\.]+)s"\s*/>')) {
		$total += [double]::Parse($m.Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture)
	}
	return $total
}

function Get-EstimatedSeconds {
	param ([string] $Narration, [double] $Speed)
	if (-not $Narration) { return 0 }
	if ($Speed -le 0) { $Speed = 1.0 }
	$words = Get-WordCount $Narration
	$speech = $words / ($JTS_BASE_WPM * $Speed) * 60
	return [math]::Round($speech + (Get-BreakSeconds $Narration))
}

function Get-TtsSpeed {
	param ([string] $BriefText)
	$match = [regex]::Match($BriefText, '"speed"\s*:\s*([\d\.]+)')
	if (-not $match.Success) { return 1.0 }
	return [double]::Parse($match.Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture)
}

# Kembalikan array objek shot: Number, Body.
function Get-Shots {
	param ([string] $VideoContent)
	if (-not $VideoContent) { return @() }
	$parts = [regex]::Split($VideoContent, '(?m)^\s*-\s*\*\*Shot\s+(\d+)\*\*:?')
	$shots = @()
	for ($i = 1; $i -lt $parts.Count; $i += 2) {
		$shots += [pscustomobject]@{ Number = [int]$parts[$i]; Body = $parts[$i + 1] }
	}
	return $shots
}

function Get-ShotNarration {
	param ([string] $ShotBody)
	$match = [regex]::Match($ShotBody, '(?s)NARASI:\s*"(.*?)"\s*(\r?\n|$)')
	if (-not $match.Success) { return $null }
	return $match.Groups[1].Value
}

function Get-EpisodeNumber {
	param ([string] $Name)
	$match = [regex]::Match($Name, 'eps_?(\d+)')
	if (-not $match.Success) { return $null }
	return [int]$match.Groups[1].Value
}

# Data lengkap satu folder episode.
function Get-EpisodeFiles {
	param ([IO.DirectoryInfo] $EpisodeDir)
	$number = Get-EpisodeNumber $EpisodeDir.Name
	$padded = '{0:D2}' -f $number
	$brief = Get-ChildItem $EpisodeDir.FullName -Filter 'brief_*.txt' | Select-Object -First 1
	$hasil = Get-ChildItem $EpisodeDir.FullName -Filter 'hasil_*.txt' | Select-Object -First 1
	$prompt = Get-ChildItem "$JTS_ROOT\prompts_flow" -Recurse -Filter "prompt_eps_${padded}_*.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
	$shopee = Get-ChildItem "$JTS_ROOT\shopee_video" -Directory -Filter "eps_${padded}_*" -ErrorAction SilentlyContinue | Select-Object -First 1
	return [pscustomobject]@{
		Number = $number
		Season = [int]($EpisodeDir.Parent.Name -replace '\D', '')
		Slug = ($EpisodeDir.Name -replace '^eps_\d+_', '')
		BriefPath = $(if ($brief) { $brief.FullName } else { $null })
		HasilPath = $(if ($hasil) { $hasil.FullName } else { $null })
		PromptPath = $(if ($prompt) { $prompt.FullName } else { $null })
		ShopeeDir = $(if ($shopee) { $shopee.FullName } else { $null })
	}
}

# Folder briefs belum ada sebelum episode pertama: kembalikan kosong tanpa error.
function Get-AllEpisodeDirs {
	return Get-ChildItem "$JTS_ROOT\briefs" -Directory -Recurse -ErrorAction SilentlyContinue |
		Where-Object { $_.Name -match '^eps_\d+_' } |
		Sort-Object { Get-EpisodeNumber $_.Name }
}
