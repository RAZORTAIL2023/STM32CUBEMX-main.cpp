# Project Structure Guide / 项目结构指南

## Expected Directory Structure / 预期的目录结构

Place the scripts in your STM32 project root directory, at the same level as your .ioc file:

将脚本放置在 STM32 项目根目录，与 .ioc 文件同级：

```
YourSTM32Project/
│
├── YourProject.ioc              # STM32CubeMX project file / CubeMX 项目文件
├── pre_generate.bat             # Pre-generation script / 生成前脚本
├── post_generate.bat            # Post-generation script / 生成后脚本
│
├── Core/
│   ├── Inc/
│   │   └── main.h
│   └── Src/
│       └── main.c               # Will become main.cpp / 将变成 main.cpp
│
├── Drivers/
│   └── STM32XXxx_HAL_Driver/
│
├── MDK-ARM/                     # Keil project directory / Keil 项目目录
│   ├── YourProject.uvprojx     # Will be updated / 将被更新
│   └── YourProject.uvoptx      # Will be updated / 将被更新
│
└── ... (other directories)
```

## First Time Setup / 首次设置

### Step by Step / 详细步骤

1. **Download Scripts / 下载脚本**
   - Download `pre_generate.bat` and `post_generate.bat`
   - 下载 `pre_generate.bat` 和 `post_generate.bat`

2. **Place Scripts / 放置脚本**
   - Copy both scripts to your project root (where .ioc file is located)
   - 将两个脚本复制到项目根目录（.ioc 文件所在位置）

3. **Configure in CubeMX / 在 CubeMX 中配置**
   ```
   Project Manager → Project Settings → Advanced Settings
   
   Pre Code Generation Script:  pre_generate.bat
   Post Code Generation Script: post_generate.bat
   ```

4. **Generate Code / 生成代码**
   - Click "GENERATE CODE" in STM32CubeMX
   - 在 STM32CubeMX 中点击 "GENERATE CODE"
   
5. **Verify / 验证**
   - Check that `Core/Src/main.cpp` exists (not main.c)
   - 检查 `Core/Src/main.cpp` 是否存在（而非 main.c）
   - Check that Keil project file references main.cpp
   - 检查 Keil 项目文件是否引用 main.cpp

## Script Behavior / 脚本行为

### First Generation / 首次生成
```
[User Action] Generate Code
     ↓
[pre_generate.bat] No main.cpp found → Do nothing
     ↓
[CubeMX] Generates main.c
     ↓
[post_generate.bat] 
     - Renames main.c → main.cpp
     - Updates .uvprojx
     - Updates .uvoptx
```

### Subsequent Generations / 后续生成
```
[User Action] Generate Code
     ↓
[pre_generate.bat] Found main.cpp → Rename to main.c
     ↓
[CubeMX] Updates main.c (preserves USER CODE)
     ↓
[post_generate.bat]
     - Renames main.c → main.cpp
     - Updates .uvprojx
     - Updates .uvoptx
```

## Troubleshooting / 故障排除

### Script Not Running / 脚本未运行

**Problem / 问题**: Scripts don't seem to execute
**Solution / 解决方案**:
- Verify STM32CubeMX version is 6.12 or higher
- 验证 STM32CubeMX 版本是 6.12 或更高
- Check script paths are correct (relative to .ioc file)
- 检查脚本路径是否正确（相对于 .ioc 文件）
- Look at CubeMX console output for script errors
- 查看 CubeMX 控制台输出的脚本错误

### main.cpp Not Created / main.cpp 未创建

**Problem / 问题**: main.c still exists after generation
**Solution / 解决方案**:
- Check post_generate.bat executed successfully
- 检查 post_generate.bat 是否成功执行
- Verify file permissions in project directory
- 验证项目目录中的文件权限
- Run post_generate.bat manually to test
- 手动运行 post_generate.bat 进行测试

### Keil Project Not Updated / Keil 项目未更新

**Problem / 问题**: Keil still shows main.c in project
**Solution / 解决方案**:
- Check if .uvprojx file exists
- 检查 .uvprojx 文件是否存在
- Verify PowerShell is available on your system
- 验证系统上是否有 PowerShell
- Close Keil before regenerating code
- 重新生成代码前关闭 Keil

### User Code Lost / 用户代码丢失

**Problem / 问题**: My code disappeared after regeneration
**Solution / 解决方案**:
- Ensure code is between USER CODE BEGIN/END comments
- 确保代码在 USER CODE BEGIN/END 注释之间
- This is a CubeMX behavior, not script-related
- 这是 CubeMX 的行为，与脚本无关
- Always keep backups of important changes
- 始终备份重要更改

## Tips / 提示

1. **Always backup before first use / 首次使用前始终备份**
   - Copy your project before running scripts for the first time
   - 首次运行脚本前复制您的项目

2. **Close Keil during regeneration / 重新生成期间关闭 Keil**
   - Keil may lock project files
   - Keil 可能锁定项目文件

3. **Check console output / 检查控制台输出**
   - CubeMX shows script output in its console
   - CubeMX 在其控制台中显示脚本输出

4. **Test scripts manually / 手动测试脚本**
   - You can run the .bat files from command line to test
   - 您可以从命令行运行 .bat 文件进行测试
   ```cmd
   cd YourProjectRoot
   post_generate.bat
   ```

## Support / 支持

For issues or questions, please create an issue on GitHub:
如有问题或疑问，请在 GitHub 上创建 issue：

https://github.com/RAZORTAIL2023/STM32CUBEMX-main.cpp/issues
