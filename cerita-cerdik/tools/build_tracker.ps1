# Bangun / perbarui cerita-cerdik/episode_tracker.csv dari folder briefs, prompts_flow, shopee_video, output.
# Kolom manual (tanggal posting, metrik, link) TIDAK pernah ditimpa saat dijalankan ulang.
# Usage: powershell -ExecutionPolicy Bypass -File cerita-cerdik\tools\build_tracker.ps1

. "$PSScriptRoot\brief_lib.ps1"

$TRACKER_PATH = "$CC_ROOT\episode_tracker.csv"
$OUTPUT_DIR = "$CC_ROOT\output"

# File output lama yang tidak memakai pola epsXX.mp4
$VIDEO_ALIASES = @{
	'kuali-beranak.mp4' = 1
	'angin-kentut.mp4' = 2
	'menghitung-bintang.mp4' = 3
	'eps4-fix.mp4' = 4
	'ayam-bertelur.mp4' = 5
}

$AUTO_COLUMNS = @(
	'eps', 'season', 'slug', 'judul', 'tipe', 'kata_vo', 'speed_tts', 'estimasi_detik',
	'durasi_asli_detik', 'jumlah_shot', 'file_video', 'ada_brief', 'ada_hasil',
	'ada_rincian_shot', 'ada_prompt', 'ada_shopee_video'
)
$MANUAL_COLUMNS = @(
	'tanggal_posting', 'hari', 'fb_reach', 'fb_views', 'thumbstop_pct', 'avg_watch_detik',
	'hold_1min_pct', 'rekomendasi_pct', 'female_25_34_pct', 'share', 'komen',
	'ig_views', 'tiktok_views', 'produk_shopee', 'link_shopee', 'catatan'
)
# Kolom auto yang boleh dikoreksi manual (nilai lama dipertahankan bila sudah terisi)
$STICKY_COLUMNS = @('judul', 'tipe', 'durasi_asli_detik')

function Get-VideoMap {
	$map = @{}
	foreach ($file in Get-ChildItem $OUTPUT_DIR -Filter '*.mp4' -ErrorAction SilentlyContinue) {
		$number = $null
		if ($VIDEO_ALIASES.ContainsKey($file.Name)) {
			$number = $VIDEO_ALIASES[$file.Name]
		} elseif ($file.Name -match '^eps(\d+)\.mp4$') {
			$number = [int]$Matches[1]
		}
		if ($null -eq $number) { continue }
		# eps4-fix.mp4 menang atas eps4.mp4
		if ($map.ContainsKey($number) -and $file.Name -notmatch 'fix') { continue }
		$map[$number] = $file
	}
	return $map
}

$shell = $null
function Get-VideoSeconds {
	param ([IO.FileInfo] $File)
	if (-not $script:shell) { $script:shell = New-Object -ComObject Shell.Application }
	$folder = $script:shell.Namespace($File.DirectoryName)
	$item = $folder.ParseName($File.Name)
	$raw = $folder.GetDetailsOf($item, 27) # kolom "Length" hh:mm:ss
	if (-not $raw) { return '' }
	return [int]([TimeSpan]::Parse($raw)).TotalSeconds
}

function Get-TitleAndType {
	param ([string] $HasilText)
	$title = ''
	$type = ''
	$match = [regex]::Match($HasilText, 'Judul Episode:\s*([^\r\n]+)')
	if ($match.Success) { $title = $match.Groups[1].Value.Trim() }
	$typeMatch = [regex]::Match($title, '\(((?:Tipe|Tema)[^)]*)\)')
	if ($typeMatch.Success) { $type = $typeMatch.Groups[1].Value.Trim() }
	if ($title -match 'Test Ombak') { $type = 'Misteri (Test Ombak)' }
	return @{ Title = $title; Type = $type }
}

function Get-ExistingRows {
	$rows = @{}
	if (-not (Test-Path $TRACKER_PATH)) { return $rows }
	foreach ($row in Import-Csv $TRACKER_PATH -Encoding UTF8) {
		$rows[[int]$row.eps] = $row
	}
	return $rows
}

function ConvertTo-Flag {
	param ($Value)
	if ($Value) { return 'ya' }
	return 'TIDAK'
}

$existingRows = Get-ExistingRows
$videoMap = Get-VideoMap
$result = @()

foreach ($dir in Get-AllEpisodeDirs) {
	$episode = Get-EpisodeFiles $dir
	$briefText = Read-TextFile $episode.BriefPath
	$hasilText = Read-TextFile $episode.HasilPath
	$narration = Get-BriefSection $briefText 'videoNarration'
	$speed = Get-TtsSpeed $briefText
	$shots = Get-Shots (Get-BriefSection $briefText 'videoContent')
	$meta = Get-TitleAndType $hasilText
	$video = $videoMap[$episode.Number]
	$old = $existingRows[$episode.Number]

	$row = [ordered]@{
		eps = $episode.Number
		season = $episode.Season
		slug = $episode.Slug
		judul = $meta.Title
		tipe = $meta.Type
		kata_vo = $(if ($narration) { Get-WordCount $narration } else { '' })
		speed_tts = $speed
		estimasi_detik = $(if ($narration) { Get-EstimatedSeconds $narration $speed } else { '' })
		durasi_asli_detik = ''
		jumlah_shot = @($shots).Count
		file_video = $(if ($video) { $video.Name } else { '' })
		ada_brief = ConvertTo-Flag $episode.BriefPath
		ada_hasil = ConvertTo-Flag $episode.HasilPath
		ada_rincian_shot = ConvertTo-Flag ($hasilText -match 'PER SHOT')
		ada_prompt = ConvertTo-Flag $episode.PromptPath
		ada_shopee_video = ConvertTo-Flag $episode.ShopeeDir
	}

	foreach ($column in $STICKY_COLUMNS) {
		if ($old -and $old.$column) { $row[$column] = $old.$column }
	}
	if (-not $row.durasi_asli_detik -and $video) {
		Write-Host "Membaca durasi $($video.Name)..."
		$row.durasi_asli_detik = Get-VideoSeconds $video
	}
	foreach ($column in $MANUAL_COLUMNS) {
		$row[$column] = $(if ($old) { $old.$column } else { '' })
	}
	$result += [pscustomobject]$row
}

$result | Export-Csv $TRACKER_PATH -NoTypeInformation -Encoding UTF8
Write-Host "Tracker diperbarui: $TRACKER_PATH ($($result.Count) episode)"
