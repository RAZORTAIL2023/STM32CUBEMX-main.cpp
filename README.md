# STM32CUBEMX-main.cpp

让 STM32CubeMX 生成 main.cpp 而非 main.c 的解决方案

[English](#english) | [中文](#中文)

---

## 中文

### 问题背景

STM32CubeMX 支持 Keil 生态，但不支持使用 ARM Compiler 6 (ARMCC6) 的 Keil 生态，确切地说不支持写 C++ 的 Keil 用户。而对于 C++ 代码编写者，一个 main.cpp 才能够上承 ST-HAL 库 C 代码，下接用户 C++ 代码。

### 解决方案

本仓库提供脚本，利用 STM32CubeMX 6.12+ 版本支持的代码生成前后脚本调用功能：

1. **pre_generate.bat** - 代码生成前执行，将上一次的 main.cpp 改回 main.c
2. **post_generate.bat** - 代码生成后执行，将新生成的 main.c 改为 main.cpp，并更新 Keil 项目文件
3. **update_keil_project.ps1** - PowerShell 脚本，用于更新 Keil 项目文件中的引用

### 使用方法

#### 步骤 1: 下载脚本

将 `pre_generate.bat`、`post_generate.bat` 和 `update_keil_project.ps1` 下载到您的 STM32 项目根目录。

#### 步骤 2: 在 STM32CubeMX 中配置脚本

1. 打开您的 STM32CubeMX 项目（.ioc 文件）
2. 进入 **Project Manager** 标签页
3. 在左侧选择 **Project Settings**
4. 在 **Advanced Settings** 区域找到脚本配置选项：
   - **Pre Code Generation Script**: 设置为 `pre_generate.bat`
   - **Post Code Generation Script**: 设置为 `post_generate.bat`

#### 步骤 3: 生成代码

点击 **GENERATE CODE** 按钮。脚本将自动执行：

1. 生成前：如果存在 main.cpp，将其重命名为 main.c
2. CubeMX 生成代码（生成 main.c）
3. 生成后：
   - 将 main.c 重命名为 main.cpp
   - 更新 Keil 项目文件（.uvprojx 和 .uvoptx）中的 main.c 引用为 main.cpp

#### 步骤 4: 在 Keil 中使用

1. 在 Keil MDK 中打开项目
2. 您现在可以在 main.cpp 中编写 C++ 代码
3. 确保 Keil 项目配置使用 ARMCC6 编译器

### 脚本说明

#### pre_generate.bat

- 在 CubeMX 重新生成代码前运行
- 将 `Core/Src/main.cpp` 重命名为 `main.c`
- 这样 CubeMX 可以正常生成和更新 main.c
- 如果没有找到 main.cpp（首次运行），脚本会正常退出

#### post_generate.bat

- 在 CubeMX 生成代码后运行
- 执行三个步骤：
  1. 将 `Core/Src/main.c` 重命名为 `main.cpp`
  2. 调用 `update_keil_project.ps1` 更新所有 `.uvprojx` 文件中的 main.c 引用
  3. 调用 `update_keil_project.ps1` 更新所有 `.uvoptx` 文件中的 main.c 引用

#### update_keil_project.ps1

- PowerShell 脚本，由 post_generate.bat 调用
- 使用精确的正则表达式仅替换 main.c 为 main.cpp
- 不会影响项目中的其他 .c 文件

### 注意事项

1. **需要 STM32CubeMX 6.12+**：脚本功能需要此版本及以上
2. **Windows 环境**：批处理脚本仅在 Windows 上运行
3. **PowerShell 依赖**：post_generate.bat 使用 PowerShell 更新 XML 文件，确保系统已安装
4. **PowerShell 执行策略**：脚本使用 `-ExecutionPolicy Bypass` 以确保兼容性。如果您的系统有更严格的安全要求，可以修改脚本使用 `-ExecutionPolicy RemoteSigned` 并对 PowerShell 脚本进行签名
5. **备份项目**：首次使用前建议备份项目
6. **Keil 项目**：脚本专门为 Keil MDK 设计，其他 IDE 可能需要手动配置

### 工作原理

```
┌─────────────────────────────────────────────┐
│  用户点击 "GENERATE CODE"                    │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  pre_generate.bat                           │
│  main.cpp → main.c （如果存在）              │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  STM32CubeMX 生成代码                       │
│  生成 main.c                                │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  post_generate.bat                          │
│  1. main.c → main.cpp                       │
│  2. 更新 .uvprojx 文件                      │
│  3. 更新 .uvoptx 文件                       │
└─────────────────────────────────────────────┘
```

### 常见问题

**Q: 为什么需要两个脚本？**  
A: pre_generate.bat 确保 CubeMX 每次都能找到 main.c 并正常更新。post_generate.bat 在生成后将其转换为 C++ 可用的 main.cpp。

**Q: 脚本会影响我的用户代码吗？**  
A: 不会。只要您的代码在 USER CODE BEGIN/END 标记之间，CubeMX 就会保留它们。

**Q: 可以用于其他 IDE（如 STM32CubeIDE）吗？**  
A: 脚本的第一部分（重命名 main.c）适用于所有 IDE。但 Keil 项目文件更新部分需要根据您的 IDE 调整。

**Q: 脚本失败了怎么办？**  
A: 检查控制台输出的错误信息。确保：
- 脚本在项目根目录
- 您有文件写入权限
- PowerShell 可用（Windows 7+）

### 许可证

MIT License - 自由使用和修改

---

## English

### Problem Background

STM32CubeMX supports the Keil ecosystem but doesn't support Keil with ARM Compiler 6 (ARMCC6), specifically for C++ developers. For C++ code writers, a main.cpp file is needed to bridge ST-HAL library C code with user C++ code.

### Solution

This repository provides scripts that leverage STM32CubeMX 6.12+ script execution feature:

1. **pre_generate.bat** - Runs before code generation, renames main.cpp back to main.c
2. **post_generate.bat** - Runs after code generation, renames main.c to main.cpp and updates Keil project files
3. **update_keil_project.ps1** - PowerShell script to update Keil project file references

### Usage

#### Step 1: Download Scripts

Download `pre_generate.bat`, `post_generate.bat`, and `update_keil_project.ps1` to your STM32 project root directory.

#### Step 2: Configure Scripts in STM32CubeMX

1. Open your STM32CubeMX project (.ioc file)
2. Go to **Project Manager** tab
3. Select **Project Settings** from the left menu
4. Find script configuration in **Advanced Settings**:
   - **Pre Code Generation Script**: Set to `pre_generate.bat`
   - **Post Code Generation Script**: Set to `post_generate.bat`

#### Step 3: Generate Code

Click the **GENERATE CODE** button. The scripts will automatically:

1. Pre-generation: Rename main.cpp to main.c if it exists
2. CubeMX generates code (creates main.c)
3. Post-generation:
   - Rename main.c to main.cpp
   - Update Keil project files (.uvprojx and .uvoptx) to reference main.cpp

#### Step 4: Use in Keil

1. Open the project in Keil MDK
2. You can now write C++ code in main.cpp
3. Make sure your Keil project is configured to use ARMCC6 compiler

### Script Details

#### pre_generate.bat

- Runs before CubeMX regenerates code
- Renames `Core/Src/main.cpp` to `main.c`
- Allows CubeMX to properly generate and update main.c
- Exits normally if main.cpp is not found (first run)

#### post_generate.bat

- Runs after CubeMX generates code
- Performs three operations:
  1. Renames `Core/Src/main.c` to `main.cpp`
  2. Calls `update_keil_project.ps1` to update all `.uvprojx` files to reference main.cpp
  3. Calls `update_keil_project.ps1` to update all `.uvoptx` files to reference main.cpp

#### update_keil_project.ps1

- PowerShell script called by post_generate.bat
- Uses precise regex patterns to replace only main.c with main.cpp
- Does not affect other .c files in your project

### Important Notes

1. **Requires STM32CubeMX 6.12+**: Script feature requires this version or higher
2. **Windows Only**: Batch scripts only run on Windows
3. **PowerShell Required**: post_generate.bat uses PowerShell to update XML files
4. **PowerShell Execution Policy**: Scripts use `-ExecutionPolicy Bypass` for compatibility. If your system has stricter security requirements, you can modify the scripts to use `-ExecutionPolicy RemoteSigned` and sign the PowerShell script
5. **Backup Projects**: Recommended to backup before first use
6. **Keil Projects**: Scripts are designed for Keil MDK, other IDEs may need manual configuration

### How It Works

```
┌─────────────────────────────────────────────┐
│  User clicks "GENERATE CODE"                │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  pre_generate.bat                           │
│  main.cpp → main.c (if exists)              │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  STM32CubeMX generates code                 │
│  Creates main.c                             │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  post_generate.bat                          │
│  1. main.c → main.cpp                       │
│  2. Update .uvprojx files                   │
│  3. Update .uvoptx files                    │
└─────────────────────────────────────────────┘
```

### FAQ

**Q: Why two scripts?**  
A: pre_generate.bat ensures CubeMX always finds main.c for updates. post_generate.bat converts it to main.cpp for C++ usage.

**Q: Will scripts affect my user code?**  
A: No. As long as your code is between USER CODE BEGIN/END markers, CubeMX will preserve it.

**Q: Can I use with other IDEs (like STM32CubeIDE)?**  
A: The first part (renaming main.c) works for all IDEs. The Keil project file updates need adaptation for your IDE.

**Q: What if scripts fail?**  
A: Check console output for errors. Ensure:
- Scripts are in project root directory
- You have file write permissions
- PowerShell is available (Windows 7+)

### License

MIT License - Free to use and modify
