# STM32CUBEMX-main.cpp
STM32CUBEMX 生成main.cpp而非main.c

STM32CUBEMX 支持 Keil 生态，但不支持使用 ARMAC6 的 Keil 生态，确切的说不支持写 C++ 的 Keil 用户。
而对于 C++ 代码编写者，一个 main.cpp 才能够上乘 ST-HAL 库C代码，下接用户 C++ 代码。
那么，怎样才能让 CUBEMX 生成一个 main.cpp 而非 main.c 呢？

- STM32CUBEMX 在 6.12 版本之后支持在代码生成前后调用脚本。虽然更新发布说明并没有说明可调用的种类，但经过测试知道在 windows 环境下支持 .bat 但不支持 .ps1。
- 需要一个脚本，将 CUBEMX 生成的 main.c 找到并修改为 main.cpp
- 该脚本还应当找到新的 Keil 项目组织结构文件，将其中的 main.c 有关量改为 main.cpp 逻辑。
- 另需一个脚本，每次将上一次留存的 main.cpp 改为 main.c。
