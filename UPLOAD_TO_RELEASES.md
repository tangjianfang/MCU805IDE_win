# 上传依赖文件到 GitHub Releases

本项目的依赖文件已精简并打包，需要上传到 GitHub Releases 以便 `download_deps.bat` 下载。

## 需要上传的文件

| 文件 | 大小 | 说明 |
|------|------|------|
| `freewrap.zip` | 9.9 MB | FreeWrap 打包工具 (32位版本) |
| `lib_pkg_dir.zip` | 1.7 MB | Tcl 库依赖包 |

## 上传步骤

### 方法一：使用 GitHub CLI (推荐)

```bash
# 1. 创建 deps release (如果不存在)
gh release create deps --title "Dependencies" --notes "构建依赖文件"

# 2. 上传文件
gh release upload deps freewrap.zip
gh release upload deps lib_pkg_dir.zip
```

### 方法二：使用 GitHub 网页

1. 访问: https://github.com/tjwei/MCU8051IDE_win/releases
2. 点击 "Draft a new release"
3. 创建新 tag: `deps`
4. Release title: `Dependencies`
5. 拖拽上传以下文件:
   - `freewrap.zip` (9.9 MB)
   - `lib_pkg_dir.zip` (1.7 MB)
6. 点击 "Publish release"

## 验证上传

上传完成后，验证文件可访问：

```bash
# 测试下载
curl -I https://github.com/tjwei/MCU8051IDE_win/releases/download/deps/freewrap.zip
curl -I https://github.com/tjwei/MCU8051IDE_win/releases/download/deps/lib_pkg_dir.zip
```

应返回 HTTP 200 或 302 重定向。

## 依赖文件说明

### freewrap.zip (9.9 MB)
包含 FreeWrap 6.61 的 32位版本：
- `freewrap32.exe` (7.9 MB) - 打包工具
- `freewrapTCLSH32.exe` (5.3 MB) - Tcl Shell

**精简内容** (从原始 30 MB 减少 67%):
- 删除 64位版本 (freewrap64.exe, freewrapTCLSH64.exe)
- 删除重复文件 (win32/, win64/ 目录)
- 删除文档 (docs/)

### lib_pkg_dir.zip (1.7 MB)
包含 Tcl 库依赖：
- `bwidget/` - BWidget GUI 组件库
- `img_png/` - PNG 图像支持
- `itcl/` - incr Tcl 3.4 (面向对象扩展)
- `tclx8.4/` - TclX 8.4 扩展
- `tdom/` - tDOM XML 解析器

## 使用方式

用户 clone 项目后运行：

```bash
# 首次使用，下载依赖
download_deps.bat

# 构建项目
build_exe.bat
```

`download_deps.bat` 会自动从 GitHub Releases 下载并解压这两个文件到 `resources/` 目录。

## 故障排除

### 下载失败
- 检查网络连接
- 确认 release tag 为 `deps` (小写)
- 验证文件名完全匹配 (区分大小写)

### 下载速度慢
GitHub Releases 在国内可能较慢，可以：
- 使用代理
- 手动下载后解压到 `resources/` 目录
- 使用国内镜像 (如果可用)

## 更新依赖

如果需要更新依赖文件：

1. 修改 `resources/freewrap/` 或 `resources/lib_pkg_dir/`
2. 重新打包：
   ```bash
   powershell -Command "Compress-Archive -Path 'resources/freewrap' -DestinationPath 'freewrap.zip' -CompressionLevel Optimal"
   powershell -Command "Compress-Archive -Path 'resources/lib_pkg_dir' -DestinationPath 'lib_pkg_dir.zip' -CompressionLevel Optimal"
   ```
3. 上传新版本到 GitHub Releases (覆盖或创建新版本)
4. 更新本文档中的文件大小信息

## 注意事项

- **不要**将这些 zip 文件提交到 git 仓库
- 这些文件**只**通过 GitHub Releases 分发
- 保持文件名和 tag 名称一致，否则 `download_deps.bat` 无法下载
- 定期验证下载链接是否有效
