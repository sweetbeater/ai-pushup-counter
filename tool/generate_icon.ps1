# 앱 아이콘/런치 이미지 생성 — 진행 링 모티프 (다크 배경 + 시그널 오렌지 아크)
Add-Type -AssemblyName System.Drawing

function New-RingImage([int]$size, [bool]$withBackground, [string]$path) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

  $s = $size / 1024.0

  if ($withBackground) {
    $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    $top = [System.Drawing.Color]::FromArgb(255, 22, 25, 32)
    $bottom = [System.Drawing.Color]::FromArgb(255, 10, 11, 13)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $top, $bottom, [single]90)
    $g.FillRectangle($brush, $rect)
    $brush.Dispose()
  }

  $cx = $size / 2.0
  $cy = $size / 2.0
  $radius = [single](320 * $s)
  $arcRect = New-Object System.Drawing.RectangleF(($cx - $radius), ($cy - $radius), (2 * $radius), (2 * $radius))

  # 트랙 (헤어라인 링)
  $trackPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(20, 255, 255, 255), [single](88 * $s))
  $g.DrawEllipse($trackPen, $arcRect)
  $trackPen.Dispose()

  # 글로우 2겹 + 메인 아크 (알파, 두께)
  $layers = @(
    @{ A = 16;  W = 210 },
    @{ A = 30;  W = 150 },
    @{ A = 255; W = 88 }
  )
  foreach ($layer in $layers) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb([int]$layer.A, 255, 92, 56), [single]($layer.W * $s))
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($pen, $arcRect, [single]-90, [single]270)
    $pen.Dispose()
  }

  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Output "saved: $path"
}

$base = $PSScriptRoot | Split-Path
New-RingImage 1024 $true  "$base\assets\icon\app_icon.png"
New-RingImage 120  $false "$base\ios\Runner\Assets.xcassets\LaunchImage.imageset\LaunchImage.png"
New-RingImage 240  $false "$base\ios\Runner\Assets.xcassets\LaunchImage.imageset\LaunchImage@2x.png"
New-RingImage 360  $false "$base\ios\Runner\Assets.xcassets\LaunchImage.imageset\LaunchImage@3x.png"
