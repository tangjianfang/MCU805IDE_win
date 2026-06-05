# MCU805IDE_win

MCU8051IDE 是一个 Tcl/Tk 编写的 8051 微控制器 IDE。本项目将其从 SourceForge 同步到 GitHub，并打包 Windows 运行依赖，用户 clone 下来即可构建运行，无需自行寻找第三方 Tcl 包。

> **SDCC 编译器**是外部工具，不在本仓库内打包，用户安装 IDE 时自行安装即可。

## 项目结构

```
MCU805IDE_win/
├── src/                        # MCU8051IDE 完整源码（来自 SourceForge master）
│   ├── lib/                    # IDE 核心 Tcl 源码
│   ├── icons/                  # 图标资源
│   ├── demo/                   # 示例项目
│   ├── doc/                    # 文档（handbook 等）
│   ├── data/                   # 运行数据（tips.xml）
│   ├── translations/           # 中文翻译（zh_CN.msg）
│   ├── hwplugins/              # 硬件插件模板
│   ├── pkgs/Windows/           # Windows 打包脚本（Inno Setup .iss）
│   ├── CMakeLists.txt          # CMake 构建配置
│   └── LICENSE                 # GPLv2 许可证
├── build/                      # 构建输出目录（freewrap 打包的文件 + exe）
│   ├── mcu8051ide.exe          # 构建产物 — 独立 Windows exe
│   ├── mcu8051ide_entry.tcl    # freewrap 入口脚本（设置 VFS 路径后 source main.tcl）
│   ├── lib/                    # IDE 源码（从 src/ 拷入，含对 Windows 的适配修改）
│   ├── libraries/              # 运行依赖包（itcl、tdom、img_png 等）
│   ├── icons/                  # 图标资源
│   ├── data/                   # MCU 数据、license
│   ├── translations/           # 翻译文件（languages.txt、zh_CN.msg）
│   └── list_of_files_to_wrap.txt  # freewrap 打包文件清单
├── deps/
│   ├── freewrap/               # freewrap 打包工具
│   │   ├── freewrap32.exe      # 32-bit (PE32) ← 用于打包 Tk GUI exe
│   │   ├── freewrap64.exe      # 64-bit (PE32+) ← 备用
│   │   ├── freewrapTCLSH32.exe # 32-bit TCLSH 版 ← 用于执行打包命令
│   │   └── freewrapTCLSH64.exe # 64-bit TCLSH 版 ← 备用
│   ├── ActiveTcl-master/       # ActiveTcl 完整发行版（提供 tclsh/wish 运行时）
│   ├── ActiveTcl-for-Windows-master/  # 另一 ActiveTcl 发行版（提供 Itcl 3.4）
│   └── lib_pkg_dir/            # 已解压的依赖包（供 freewrap 打包引用）
│       ├── img_png/            # tkimg 图像支持（24 DLL + pkgIndex.tcl）  1.6 MB
│       ├── tdom/               # tdom XML 解析（1 DLL + 2 .tcl）          1.9 MB
│       ├── bwidget/            # BWidget GUI 组件（纯 Tcl）               1.6 MB
│       ├── itcl/               # incr Tcl 4.0.5（源码级备用）
│       └── tclx8.4/            # TclX 8.4（1 DLL + 20 .tcl）              280 KB
├── docs/
│   └── download_urls.txt       # 依赖包下载地址记录
└── README.md
```

## 运行依赖

| 组件 | 路径 | 说明 | 版本 | DLL |
|------|------|------|------|-----|
| freewrap | `deps/freewrap/` | 将 Tcl/Tk 脚本打包为独立 exe | 6.61 | freewrap32.exe |
| Tcl/Tk | `deps/ActiveTcl-master/bin/` | tclsh + wish 运行时 | 8.6 (threaded) | ✅ |
| tkimg | `build/libraries/img_png/` | Tk 图像格式支持（PNG、JPEG 等） | 1.4.14 | ✅ 24 DLL |
| tDOM | `build/libraries/tdom/` | XML/DOM 解析扩展 | 0.9.3 | ✅ |
| BWidget | `build/libraries/bwidget/` | 高级 GUI 组件（树视图、笔记本等） | 1.9.16 | 纯 Tcl |
| incr Tcl | `build/libraries/itcl/` | Tcl 面向对象扩展 | **3.4** | ✅ itcl34.dll |
| TclX | `build/libraries/tclx8.4/` | Tcl 扩展工具库 | 8.4 | ✅ tclx84.dll |

> 所有 DLL 均为 **32-bit PE32**，与 `freewrap32.exe` 架构一致。DLL 来自 ActiveTcl 和预编译包，无需自行编译。

> **注意**：Itcl 使用 **3.4** 版本（而非 4.0.5），因为 MCU8051IDE 源码大量使用了 Itcl 3.4 的 `common` 变量跨类引用模式（`${ClassName::commonVar}`），该模式在 Itcl 4.0+ 中不再支持。Itcl 3.4 兼容 Tcl 8.6，来自 [ActiveTcl-for-Windows](https://github.com/LucidFusionLabs/ActiveTcl-for-Windows) 发行版。

## 构建

```bash
cd build

# 构建 mcu8051ide.exe（Tk GUI 版）
../deps/freewrap/freewrapTCLSH32.exe mcu8051ide_entry.tcl \
    -forcewrap \
    -f list_of_files_to_wrap.txt \
    -w ../deps/freewrap/freewrap32.exe \
    -o mcu8051ide.exe
```

构建产物为 `build/mcu8051ide.exe`，双击即可运行，无需安装 Tcl/Tk。

## 适配修改说明

以下修改在 `build/lib/` 中相对于原始源码（`src/lib/`）做了适配，不影响原始源码：

- **main.tcl**：添加 `if {![info exists ::LIB_DIRNAME]}` 保护，避免 freewrap 入口脚本设置的 VFS 路径被 `argv0` 计算覆盖；Windows 区段的 `LIB_DIRNAME_SPECIFIC_FOR_MS_WINDOWS` / `AUTO_PATH_FOR_MS_WINDOWS` 改为动态检测而非硬编码路径；tdom 版本改为 0.9（匹配实际 DLL）；Itcl fallback DLL 路径从 `lib/` 改为 `libraries/itcl/`。
- **environment.tcl**：Windows 下图标加载改用 `glob` fallback（`zvfs::list` 在 freewrapTCLSH 打包时返回空）。
- **mcu8051ide_entry.tcl**：新增 freewrap 入口脚本，设置 `ROOT_DIRNAME`、`LIB_DIRNAME`、`AUTO_PATH_FOR_MS_WINDOWS`、`ITCL_LIBRARY`、`TCLX_LIBRARY` 等 VFS 路径后 source `main.tcl`。

## 原始下载包归档

已解压的原始压缩包备份在 `MCU805IDE_win_archive/` 目录（项目外），不在仓库内跟踪。