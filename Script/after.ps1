# 脚本在子目录的版本 From Github Copilot GPT5.1 & Gemini3.0Pro

# 当前目录
$ScriptDir = $PSScriptRoot

# 工作目录设为父目录（上级），因为脚本位于 Script 子目录
$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $ScriptDir '..') -ErrorAction SilentlyContinue).ProviderPath
if (-not $RepoRoot) { $RepoRoot = $ScriptDir }

# .uvprojx绝对路径
$mdkDir = Join-Path $RepoRoot 'MDK-ARM'
$UvprojxFull = $null
if (Test-Path $mdkDir) {
    $first = Get-ChildItem -Path $mdkDir -Filter '*.uvprojx' -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($first) {
        $UvprojxFull = $first.FullName
    }
}
if (-not $UvprojxFull) { exit 1 }

# 计算目标文件的绝对路径
$TargetFile = Join-Path $RepoRoot 'Core\Src\main.c'
$TargetFile = (Resolve-Path -LiteralPath $TargetFile -ErrorAction SilentlyContinue).ProviderPath

# 备份.uvprojx文件
Copy-Item -Path $UvprojxFull -Destination "$UvprojxFull.bak" -Force
# Write-Host "[INFO] 备份 .uvprojx 到 $UvprojxFull.bak"

# 读取.uvprojx内容
$content = Get-Content -LiteralPath $UvprojxFull -Raw -ErrorAction Stop

# 定义 File 块的正则
$blockPattern = '(?is)(<File\b[^>]*>.*?</File>)'

# 1. 删除已有的 main.cpp 块 (避免重复，因为我们要把 main.c 变成 main.cpp)
#    CubeMX 每次生成都会把 main.c 加回来，而 main.cpp 是上次留下的。
#    如果不删，最后会有两个 main.cpp (一个旧的，一个新的由 main.c 变来的)
$content = [regex]::Replace($content, $blockPattern, {
    param($match)
    $block = $match.Value
    if ($block -match '(?is)<FileName>\s*main\.cpp\s*</FileName>') {
        # Write-Host "[INFO] Removing existing main.cpp entry from .uvprojx"
        return "" 
    }
    return $block
})

# 2. 将 main.c 块修改为 main.cpp，并设置 FileType 为 8
$new = [regex]::Replace($content, $blockPattern, {
    param($match)
    $block = $match.Value
    if ($block -match '(?is)<FileName>\s*main\.c\s*</FileName>') {
        # Write-Host "[INFO] Converting main.c entry to main.cpp in .uvprojx"
        
        # 修改文件名 main.c -> main.cpp
        $newBlock = [regex]::Replace($block, '(?is)(<FileName>\s*)main\.c(\s*</FileName>)', '${1}main.cpp${2}')
        
        # 修改文件路径 main.c -> main.cpp
        $newBlock = [regex]::Replace($newBlock, '(?is)(<FilePath>.*?)main\.c(\s*</FilePath>)', '${1}main.cpp${2}')
        
        # 修改 FileType 1 -> 8 (C++)
        if ($newBlock -match '(?is)<FileType\s*>\s*1\s*</FileType>') {
            $newBlock = [regex]::Replace($newBlock, '(?is)(<FileType\s*>\s*)1(\s*</FileType>)', '${1}8${2}')
        } elseif ($newBlock -match '(?is)<FileType\s*>\s*8\s*</FileType>') {
            # 已经是 8 了，无需修改
        }
        return $newBlock
    }
    return $block
})

if ($new -ne $content) {
    # 保持原文件的换行风格：通过字节检测是否存在 CRLF（0x0D0A），否则使用 LF
    try {
        $bytes = [System.IO.File]::ReadAllBytes($UvprojxFull)
        $hasCRLF = $false
        for ($i = 0; $i -lt $bytes.Length - 1; $i++) {
            if ($bytes[$i] -eq 0x0D -and $bytes[$i + 1] -eq 0x0A) {
                $hasCRLF = $true
                break
            }
        }
        $origNewline = if ($hasCRLF) { "`r`n" } else { "`n" }
    } catch {
        # 无法读取字节时回退到文本检测
        $origNewline = if ($content -match "\r\n") { "`r`n" } else { "`n" }
    }

    # 将所有换行规范为原文件风格
    $new = $new -replace "\r?\n", $origNewline

    # 写回时使用 UTF-8 无 BOM
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($UvprojxFull, $new, $enc)

    # Write-Output "成功修改 .uvprojx"
}

# Read-Host -Prompt "按 Enter 键继续..."
exit 0