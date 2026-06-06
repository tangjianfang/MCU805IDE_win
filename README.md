# MCU805IDE_win

MCU 8051 IDE 是一个 Tcl/Tk 编写的 8051 微控制器 IDE。本项目将其从 SourceForge 同步到 GitHub，并打包 Windows 运行依赖，用户 clone 下来即可构建运行，无需自行寻找第三方 Tcl 包。

> **SDCC 编译器**是外部工具，不在本仓库内打包，用户安装 IDE 时自行安装即可。

## 项目结构

```
MCU805IDE_win/
├── src/                        # MCU8051IDE 完整源码（1.4.9，来自 SourceForge）
│   ├── lib/                    # IDE 核心 Tcl 源码（含 Windows 适配修改）
│   ├── icons/                  # 图标资源
│   ├── demo/                   # 示例项目
│   ├── data/                   # 运行数据（mcus.xml、tips.xml 等）
│   ├── translations/           # 中文翻译（zh_CN.msg）
│   ├── hwplugins/              # 硬件插件模板
│   └── pkgs/Windows/           # Windows 打包相关文件
│       ├── mcu8051ide_entry.tcl    # freewrap 入口脚本
│       ├── gen_wrap_list.tcl       # 动态生成 wrap list
│       ├── mcu8051ide_win_setup.iss # Inno Setup 6 安装脚本
│       ├── mcu8051ide.ico          # 应用图标
│       └── readme.txt             # 安装说明
├── build/                      # 构建输出目录（由 build_exe.bat 自动生成）
│   ├── mcu8051ide.exe          # 独立 Windows exe（约 13MB）
│   ├── mcu8051ide-1.4.9-setup.exe  # Inno Setup 安装包（约 15MB）
│   ├── lib/ → src/lib/         # IDE 源码副本
│   ├── libraries/              # 运行依赖包
│   ├── icons/ → src/icons/     # 图标副本
│   └── ...                     # data、demo、translations 等副本
├── deps/
│   ├── freewrap/               # freewrap 打包工具（v6.61）
│   ├── ActiveTcl-master/       # ActiveTcl 完整发行版（提供 tclsh/wish 运行时）
│   ├── ActiveTcl-for-Windows-master/  # 另一 ActiveTcl 发行版（提供 Itcl 3.4 DLL）
│   └── lib_pkg_dir/            # 已解压的依赖包（itcl 4.0.5备用、tdom、img_png 等）
├── build_exe.bat               # 一键构建 exe（自动准备 build/ 目录）
├── build_installer.bat          # 一键构建安装包
└── README.md
```

## 快速构建

```cmd
:: 构建 exe（从空 build/ 目录也能完整构建）
build_exe.bat

:: 构建安装包（需要先运行 build_exe.bat）
build_installer.bat
```

`build_exe.bat` 会自动：
1. 创建 `build/` 目录并从 `src/`、`deps/` 复制所有运行时文件
2. 动态生成 freewrap 打包文件清单（`list_of_files_to_wrap.txt`）
3. 用 ImageMagick 生成 `.ico`（若无 ImageMagick 则用已有的 .ico）
4. 用 freewrap 构建 `mcu8051ide.exe`

构建产物 `build/mcu8051ide.exe`，双击即可运行，无需安装 Tcl/Tk。

## 运行依赖

| 组件 | 来源路径 | 说明 | 版本 | DLL |
|------|----------|------|------|-----|
| freewrap | `deps/freewrap/` | 将 Tcl/Tk 打包为独立 exe | 6.61 | freewrap32.exe |
| Tcl/Tk | freewrap 内嵌 | tclsh + wish 运行时 | 8.6.0 | 内嵌 |
| tkimg | `deps/lib_pkg_dir/img_png/` | Tk 图像格式（PNG 等） | 1.4.14 | ✅ 24 DLL |
| tDOM | `deps/lib_pkg_dir/tdom/` | XML/DOM 解析 | 0.9.3 | ✅ tdom093.dll |
| BWidget | `deps/lib_pkg_dir/bwidget/` | 高级 GUI 组件 | 1.9.16 | 纯 Tcl |
| incr Tcl | `deps/ActiveTcl-for-Windows-master/.../Itcl3.4/` | 面向对象扩展 | **3.4** | ✅ itcl34.dll |
| TclX | `deps/lib_pkg_dir/tclx8.4/` | 扩展工具库 | 8.4 | ✅ tclx84.dll |
| md5 | `deps/ActiveTcl-master/lib/tcllib1.18/md5/` | MD5 校验 | 2.0.7 | 纯 Tcl |

> 所有 DLL 均为 **32-bit PE32 (i386)**，与 `freewrap32.exe` 架构一致。

### 为什么必须用 Itcl 3.4（而非 4.0.5）

`deps/lib_pkg_dir/itcl/` 中有 Itcl 4.0.5 (`itcl40t.dll`)，**但不可用于本项目**：

1. **API 不兼容**：MCU8051IDE 源码大量使用 Itcl 3.4 的 `common` 变量跨类引用模式（`${ClassName::commonVar}`），该模式在 Itcl 4.0+ 中不再支持
2. **freewrap 加载失败**：Itcl 4.0 的 `package require` 需要 `ITCL_LIBRARY` 环境变量指向 `itcl.tcl`，在 freewrap VFS 环境下 `package require Itcl 3.4` 调用 Itcl 4.0 DLL 时会报 `Can't find a usable itcl.tcl`
3. **Itcl 3.4 兼容 Tcl 8.6**：来自 ActiveTcl-for-Windows 的 `itcl34.dll`（PE32 i386，90KB）在 freewrap 中加载正常

## 为什么 exe 比原来大？

`mcu8051ide.exe` 约 **13MB**，Inno Setup 安装包约 **15MB**。相比原版 Linux 安装包，原因如下：

| 因素 | 大致占用 | 说明 |
|------|----------|------|
| freewrap Tcl/Tk 运行时 | ~5MB | freewrap32.exe 内嵌了完整的 Tcl 8.6 + Tk 8.6 运行时，这是独立 exe 的代价——无需用户安装 Tcl/Tk |
| img_png (tkimg) 24 DLL | ~1.6MB | tkimg 的 PNG、JPEG、TIFF、BMP 等 24 个编解码 DLL 全部打包，确保各种图像格式都能显示 |
| tdom DLL | ~1.9MB | XML 解析扩展 |
| BWidget 纯 Tcl | ~1.6MB | GUI 组件库源码 |
| Itcl/TclX DLL | ~0.4MB | itcl34.dll + tclx84.dll |
| IDE 源码（~100 个 .tcl） | ~0.5MB | 所有 IDE 功能模块 |
| icons（600+ PNG） | ~0.3MB | 16×16、22×22、32×32 三套图标 |
| data/demo/translations | ~0.5MB | MCU 定义、示例项目、中文翻译 |

**核心原因**：freewrap 将 Tcl/Tk 运行时 + 所有依赖 + IDE 代码 + 资源文件打包成单一 exe。用户双击即可运行，**零安装依赖**。这是"便携"的代价——用空间换便利。

> 如果只打包 IDE 代码（不含 Tcl/Tk 运行时和 DLL），体积可降至 ~3MB，但需要用户自行安装 ActiveTcl。

## 适配修改说明

以下修改在 `src/lib/` 中相对于原始上游源码做了 Windows freewrap 适配：

### src/lib/main.tcl

- **路径守卫**：`LIB_DIRNAME`、`INSTALLATION_DIR`、`ROOT_DIRNAME`（行 45-47）添加 `if {![info exists ...]}` 保护，避免 entry script 的 VFS 路径被 `argv0` 计算值覆盖
- **Windows 占位符守卫**：`LIB_DIRNAME_SPECIFIC_FOR_MS_WINDOWS` 和 `AUTO_PATH_FOR_MS_WINDOWS`（行 130-131）的 `<AIPCS:...>` 占位符改为动态检测——若 entry script 已设置则跳过，否则保留原占位符供 Linux 打包脚本替换
- **tdom 版本**：`tdom 0.8` → `tdom 0.9`（匹配实际 DLL 0.9.3）

### src/lib/environment.tcl

- **图标加载**：Windows 下不再使用 `zvfs::list`（freewrap 的打包文件不在 zvfs 中），改为 `glob` 优先 + `zvfs::list` fallback。`glob` 在 freewrap 中可搜索 VFS 和文件系统

### src/pkgs/Windows/mcu8051ide_entry.tcl（新增）

freewrap 入口脚本，在 `source main.tcl` 之前设置：
- `::ROOT_DIRNAME`、`::LIB_DIRNAME`、`::INSTALLATION_DIR`（VFS 路径）
- `::LIB_DIRNAME_SPECIFIC_FOR_MS_WINDOWS`、`::AUTO_PATH_FOR_MS_WINDOWS`
- `::auto_path`（追加 bwidget、md5、tdom、itcl、tclx8.4、img_png）
- `::env(ITCL_LIBRARY)`、`::env(TCLX_LIBRARY)`
- 错误诊断日志（`startup_log.txt`），安全读取变量（不崩溃）

### src/pkgs/Windows/gen_wrap_list.tcl（新增）

动态生成 `list_of_files_to_wrap.txt`：扫描 `build/` 目录，排除构建产物（exe、ico、log），输出相对路径列表。兼容 freewrap TCLSH（不用 `file relativename`）。

### build_exe.bat

从空 `build/` 目录也能完整构建：
1. 复制 `src/lib/`、`src/data/`、`src/demo/`、`src/icons/`、`src/translations/`、`src/hwplugins/` 到 `build/`
2. 复制 `deps/lib_pkg_dir/` 依赖包到 `build/libraries/`（**Itcl 3.4 来自 ActiveTcl-for-Windows**）
3. 复制 md5 从 ActiveTcl
4. 复制 entry script、图标 PNG
5. 生成 .ico（ImageMagick 或 fallback）
6. 生成 wrap list（`gen_wrap_list.tcl`）
7. 构建 `external_command.exe` + `mcu8051ide.exe`

### src/pkgs/Windows/mcu8051ide_win_setup.iss + build_installer.bat

Inno Setup 6 安装脚本（版本 1.4.9）：
- `SetupIconFile` = `mcu8051ide.ico`（从 PNG 转换）
- `WizardSmallImageFile` = `mcu8051ide.png`
- 注册 `.mcu8051ide` 文件关联
- LZMA2 压缩、现代向导风格