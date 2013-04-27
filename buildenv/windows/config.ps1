# Configuration

if (-not $script:config) {
    $script:config = (Get-Content .\config.json | Out-String | ConvertFrom-Json)
}
$cfg = $script:config
