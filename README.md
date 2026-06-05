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
│   ├── freewrapTK661.exe       # Tcl/Tk 打包工具，将脚本打包为独立 exe  (5.2 MB)
│   └── tcl/
│       ├── Tcl-3.2.0-amd64.msi       # Tcl/Tk 8.6 运行环境           (36.4 MB)
│       ├── BWidget-1.9.16.tar.gz      # GUI 组件库                     (0.3 MB)
│       ├── tdom-0.9.3.tar.gz          # XML 解析                       (1.1 MB)
│       ├── tkimg-1.4.14.tar.gz        # 图像支持                       (1.7 MB)
│       ├── itcl-4.2.4.tar.gz          # OO 扩展                        (0.6 MB)
│       └── tclx-8.4.tar.gz            # Tcl 扩展工具库                 (TclX)
├── docs/
│   └── BUILD.md                       # 构建文档
└── README.md
```

## 运行依赖

| 组件 | 文件 | 说明 |
|------|------|------|
| freewrapTK | `deps/freewrapTK661.exe` | 将 Tcl/Tk 脚本打包为独立 Windows exe |
| Tcl/Tk | `deps/tcl/Tcl-3.2.0-amd64.msi` | Tcl/Tk 8.6 运行环境 |
| BWidget | `deps/tcl/BWidget-1.9.16.tar.gz` | 高级 GUI 组件（树视图、笔记本等） |
| tDOM | `deps/tcl/tdom-0.9.3.tar.gz` | XML/DOM 解析扩展 |
| tkimg | `deps/tcl/tkimg-1.4.14.tar.gz` | Tk 图像格式支持（PNG 等） |
| incr Tcl | `deps/tcl/itcl-4.2.4.tar.gz` | Tcl 面向对象扩展 |
| TclX | `deps/tcl/tclx-8.4.tar.gz` | Tcl 扩展工具库（数组、文件等高级操作） |

> 以上依赖列表与源码仓库 `src/pkgs/README` 及官方安装包实际嵌入的包一致。

## 构建

参见 [`docs/BUILD.md`](docs/BUILD.md)。