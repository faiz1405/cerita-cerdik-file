# Bangun / perbarui jangan-tonton-sendirian/episode_tracker.csv dari folder briefs, prompts_flow, shopee_video, output.
# Kolom manual (tanggal posting, metrik, link) TIDAK pernah ditimpa saat dijalankan ulang.
# Usage: powershell -ExecutionPolicy Bypass -File jangan-tonton-sendirian\tools\build_tracker.ps1

. "$PSScriptRoot\brief_lib.ps1"

$TRACKER_PATH = "$JTS_ROOT\episode_tracker.csv"
$OUTPUT_DIR = "$JTS_ROOT\output"

$AUTO_COLUMNS = @(
	'eps', 'season', 'slug', 'judul', 'tipe', 'kata_vo', 'speed_tts', 'estimasi_detik',
	'durasi_asli_detik', 'jumlah_shot', 'file_video', 'ada_brief', 'ada_hasil',
	'ada_rincian_shot', 'ada_prompt', 'ada_shopee_video'
)
# female_total_pct = metrik niche ibu muda (porsi semua penonton wanita), diisi meta-analytics-ingest.
$MANUAL_COLUMNS = @(
	'tanggal_posting', 'hari', 'fb_reach', 'fb_views', 'thumbstop_pct', 'avg_watch_detik',
	'hold_1min_pct', 'rekomendasi_pct', 'female_total_pct', 'female_25_34_pct', 'share', 'komen',
	'ig_views', 'tiktok_views', 'produk_shopee', 'link_shopee', 'catatan'
)
# Kolom auto yang boleh dikoreksi manual (nilai lama dipertahankan bila sudah terisi)
$STICKY_COLUMNS = @('judul', 'tipe', 'durasi_asli_detik')

function Get-VideoMap {
	$map = @{}
	foreach ($file in Get-ChildItem $OUTPUT_DIR -Filter '*.mp4' -ErrorAction SilentlyContinue) {
		if ($file.Name -match '^eps(\d+)\.mp4$') {
			$map[[int]$Matches[1]] = $file
		}
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
	$typeMatch = [regex]::Match($title, '\((Tipe[^)]*)\)')
	if ($typeMatch.Success) { $type = $typeMatch.Groups[1].Value.Trim() }
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

if ($result.Count -eq 0) {
	# Belum ada episode: tulis header saja (dibutuhkan meta-analytics-ingest), dari daftar kolom yang sama.
	$header = (($AUTO_COLUMNS + $MANUAL_COLUMNS) | ForEach-Object { '"' + $_ + '"' }) -join ','
	[IO.File]::WriteAllText($TRACKER_PATH, $header + "`r`n", (New-Object Text.UTF8Encoding $true))
	Write-Host "Tracker dibuat (header saja, belum ada episode): $TRACKER_PATH"
	return
}

$result | Export-Csv $TRACKER_PATH -NoTypeInformation -Encoding UTF8
Write-Host "Tracker diperbarui: $TRACKER_PATH ($($result.Count) episode)"
