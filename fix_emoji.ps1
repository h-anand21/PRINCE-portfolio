# Read the file as UTF-8
$bytes = [System.IO.File]::ReadAllBytes('index.html')
$content = [System.Text.Encoding]::UTF8.GetString($bytes)

# The wave emoji 👋 as a proper .NET string
$waveEmoji = [System.Char]::ConvertFromUtf32(0x1F44B)

# The corrupted bytes C3 B0 C5 B8 E2 80 98 E2 80 B9 are the mangled emoji
# Decode them as UTF-8 to get the actual string we need to replace
$corruptedBytes = [byte[]](0xC3, 0xB0, 0xC5, 0xB8, 0xE2, 0x80, 0x98, 0xE2, 0x80, 0xB9)
$corruptedStr = [System.Text.Encoding]::UTF8.GetString($corruptedBytes)

Write-Output "Corrupted string decoded: '$corruptedStr'"
Write-Output "Wave emoji: '$waveEmoji'"

# Build the old and new strings
$oldFinalText = "const finalText = 'Hi there! $corruptedStr';"
$newFinalText  = "const finalText = 'Hi there! $waveEmoji';"

$oldCondition  = "if (char === ' ' || char === '$corruptedStr') {"
$newCondition  = "if (char === ' ' || char.codePointAt(0) > 127) {"

Write-Output "Old finalText: $oldFinalText"
Write-Output "New finalText: $newFinalText"

$newContent = $content.Replace($oldFinalText, $newFinalText)
$newContent = $newContent.Replace($oldCondition, $newCondition)

if ($newContent -ne $content) {
    [System.IO.File]::WriteAllText('index.html', $newContent, [System.Text.Encoding]::UTF8)
    Write-Output "SUCCESS: File updated and saved as UTF-8!"
} else {
    Write-Output "ERROR: Still no replacement. Dumping nearby content..."
    $idx = $content.IndexOf("finalText = 'Hi there!")
    Write-Output "Index: $idx"
    $snippet = $content.Substring($idx, 60)
    Write-Output "Snippet: '$snippet'"
}
