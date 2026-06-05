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
│   ├── freewrap661.zip         # freewrap 打包工具（含 win32 + win64 freewrap.exe）
│   ├── ActiveTcl-8.6.14...exe # ActiveTcl Tcl/Tk 8.6 运行环境安装器
│   ├── *.zip / *.tar.gz        # 依赖包原始下载压缩包
│   └── lib_pkg_dir/            # 已解压的依赖包（供 freewrap 打包引用）
│       ├── img_png/            # tkimg 图像支持（24 DLL + pkgIndex.tcl）
│       ├── tdom/               # tdom XML 解析（1 DLL + tdom.tcl + pkgIndex.tcl）
│       ├── bwidget/            # BWidget GUI 组件（纯 Tcl，46 .tcl + images）
│       ├── itcl/               # incr Tcl OO 扩展（.tcl 文件，DLL 待编译）
│       └── tclx8.4/            # TclX 扩展工具库（.tcl 文件，DLL 待编译）
├── docs/
│   └── BUILD.md                # 构建文档
└── README.md
```

## 运行依赖

| 组件 | 来源 | 说明 | DLL 状态 |
|------|------|------|----------|
| freewrap | `deps/freewrap661.zip` | 将 Tcl/Tk 脚本打包为独立 Windows exe | ✅ 已提取 |
| Tcl/Tk | `deps/ActiveTcl-8.6.14...exe` | Tcl/Tk 8.6 运行环境安装器 | ✅ 可安装 |
| tkimg | `deps/lib_pkg_dir/img_png/` | Tk 图像格式支持（PNG、JPEG 等） | ✅ 24 DLL 已提取 |
| tDOM | `deps/lib_pkg_dir/tdom/` | XML/DOM 解析扩展 | ✅ DLL 已提取 |
| BWidget | `deps/lib_pkg_dir/bwidget/` | 高级 GUI 组件（纯 Tcl） | ✅ 完整提取 |
| incr Tcl | `deps/lib_pkg_dir/itcl/` | Tcl 面向对象扩展 | ⚠️ .tcl 已提取，DLL 待编译 |
| TclX | `deps/lib_pkg_dir/tclx8.4/` | Tcl 扩展工具库（纯 Tcl .tcl） | ⚠️ .tcl 已提取，DLL 待编译 |

> ⚠️ **itcl** 和 **TclX** 的 C 核心需要编译为 Windows DLL（itcl424.dll、tclx84.dll），需 MinGW + Tcl 开发头文件。编译完成后放入对应目录，pkgIndex.tcl 即可生效。

## 构建

参见 [`docs/BUILD.md`](docs/BUILD.md)。