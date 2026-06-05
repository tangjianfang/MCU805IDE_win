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
├── deps/
│   ├── freewrap/               # freewrap 打包工具
│   │   ├── freewrap32.exe      # 32-bit (PE32) ← 用于打包（匹配 32-bit DLL）
│   │   └── freewrap64.exe      # 64-bit (PE32+) ← 备用
│   ├── ActiveTcl-master/       # ActiveTcl 完整发行版（提供 tclsh/wish 运行时）
│   └── lib_pkg_dir/            # 已解压的依赖包（供 freewrap 打包引用）
│       ├── img_png/            # tkimg 图像支持（24 DLL + pkgIndex.tcl）  1.6 MB
│       ├── tdom/               # tdom XML 解析（1 DLL + 2 .tcl）          1.9 MB
│       ├── bwidget/            # BWidget GUI 组件（纯 Tcl）               1.6 MB
│       ├── itcl/               # incr Tcl 4.0.5（1 DLL + 4 .tcl）         300 KB
│       └── tclx8.4/            # TclX 8.4（1 DLL + 20 .tcl）              280 KB
├── docs/
│   ├── BUILD.md                # 构建文档
│   └── download_urls.txt       # 依赖包下载地址记录
└── README.md
```

## 运行依赖

| 组件 | 路径 | 说明 | 版本 | DLL |
|------|------|------|------|-----|
| freewrap | `deps/freewrap/freewrap32.exe` | 将 Tcl/Tk 脚本打包为独立 exe | 6.6.1 | ✅ |
| Tcl/Tk | `deps/ActiveTcl-master/bin/` | tclsh + wish 运行时 | 8.6 (threaded) | ✅ |
| tkimg | `deps/lib_pkg_dir/img_png/` | Tk 图像格式支持（PNG、JPEG 等） | 1.4.14 | ✅ 24 DLL |
| tDOM | `deps/lib_pkg_dir/tdom/` | XML/DOM 解析扩展 | 0.9.3 | ✅ |
| BWidget | `deps/lib_pkg_dir/bwidget/` | 高级 GUI 组件（树视图、笔记本等） | 1.9.16 | 纯 Tcl |
| incr Tcl | `deps/lib_pkg_dir/itcl/` | Tcl 面向对象扩展 | 4.0.5 | ✅ itcl40t.dll |
| TclX | `deps/lib_pkg_dir/tclx8.4/` | Tcl 扩展工具库 | 8.4 | ✅ tclx84.dll |

> 所有 DLL（27 个）均为 **32-bit PE32**，与 `freewrap32.exe` 架构一致。DLL 来自 ActiveTcl 和预编译包，无需自行编译。

## 构建

参见 [`docs/BUILD.md`](docs/BUILD.md)。

## 原始下载包归档

已解压的原始压缩包备份在 `MCU805IDE_win_archive/` 目录（项目外），不在仓库内跟踪，包括：
- freewrap661.zip、ActiveTcl-master.zip、ActiveTcl 安装器 exe
- Img1.4.14-win32.zip、bwidget-1.9.16.zip、tdom 预编译/源码 zip
- itcl 源码 tar.gz、tclx 源码 tar.bz2、tcl 源码 tar.gz