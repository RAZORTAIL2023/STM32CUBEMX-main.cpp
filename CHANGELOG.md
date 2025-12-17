# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-12-17

### Added
- Initial release of STM32CubeMX main.cpp generation scripts
- `pre_generate.bat` - Pre-generation script to rename main.cpp back to main.c
- `post_generate.bat` - Post-generation script to rename main.c to main.cpp and update Keil project files
- `update_keil_project.ps1` - PowerShell script to update Keil project files with precise regex patterns
- Comprehensive README.md with usage instructions in both Chinese and English
- PROJECT_STRUCTURE.md with detailed setup guide and troubleshooting
- example_main.cpp showing how to use C++ features with ST-HAL library
- test_scripts.sh for automated testing of script functionality
- MIT LICENSE
- .gitignore for project cleanliness

### Features
- Automatically renames main.c to main.cpp after CubeMX code generation
- Updates Keil project files (.uvprojx and .uvoptx) to reference main.cpp
- Uses precise regex patterns to only replace main.c (doesn't affect other .c files)
- Preserves user code between USER CODE BEGIN/END markers
- Supports subsequent code regenerations
- Provides clear console output for debugging
- Works with STM32CubeMX 6.12 and higher
- Modular design with separate PowerShell script for better maintainability

### Documentation
- Bilingual documentation (Chinese and English)
- Step-by-step usage guide
- Troubleshooting section
- FAQ section
- Example main.cpp file demonstrating C++ usage
- Workflow diagrams showing script behavior

### Testing
- Automated test script to verify functionality
- Tests for first generation scenario
- Tests for subsequent generation scenario
- Tests for Keil project file updates
- All tests passing on Linux environment (scripts designed for Windows)
