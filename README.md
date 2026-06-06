# MCU 8051 IDE for Windows

MCU 8051 IDE is an integrated development environment for 8051 microcontrollers. This Windows port uses freewrap to create standalone executables.

## Project Structure

```
MCU8051IDE_win/
├── src/                    # Source code (14 MB)
│   ├── lib/               # Core IDE Tcl scripts
│   ├── data/              # Runtime data (tips, MCU database)
│   ├── demo/              # Demo projects
│   ├── icons/             # UI icons
│   ├── translations/      # Language files
│   └── pkgs/Windows/      # Windows packaging scripts
│
├── build/                 # Build output (gitignored, ~50 MB)
│   ├── mcu8051ide.exe     # Main executable
│   └── libraries/         # Copied dependencies
│
├── resources/             # Dependencies (gitignored, ~120 MB)
│   ├── freewrap/          # FreeWrap 6.61 tools
│   ├── lib_pkg_dir/       # Tcl library packages
│   └── ActiveTcl-master/  # ActiveTcl runtime (partial)
│
├── build_exe.bat          # Build the executable
├── build_installer.bat    # Build the installer
└── download_deps.bat      # Download dependencies
```

## Quick Start

### 1. Download Dependencies (First Time Only)

The required dependencies (~120 MB) are not included in the git repository to keep the download size small. Run the download script:

```batch
download_deps.bat
```

This will download and extract to `resources/`:
- **FreeWrap 6.61** (38 MB) - Tcl/Tk executable packager
- **lib_pkg_dir** (5.3 MB) - Tcl libraries (Itcl 3.4, tDOM, img_png, etc.)
- **ActiveTcl md5** (partial) - MD5 library

**Manual download links** (if automatic download fails):
- FreeWrap: https://sourceforge.net/projects/freewrap/files/freewrap/6.61/
- lib_pkg_dir: https://github.com/tjwei/MCU8051IDE_win/releases/download/deps/lib_pkg_dir.zip

### 2. Build the Executable

```batch
build_exe.bat
```

This will:
1. Copy source files to `build/`
2. Copy dependencies to `build/libraries/`
3. Generate wrap file list
4. Build `mcu8051ide.exe` using FreeWrap

Output: `build/mcu8051ide.exe` (13 MB)

### 3. Build the Installer (Optional)

```batch
build_installer.bat
```

This creates a Windows installer using Inno Setup 6.

Output: `build/mcu8051ide-1.4.9-setup.exe` (15 MB)

## Why Dependencies Are Separated

The git repository contains only the source code (~14 MB) instead of the full package (~154 MB). Benefits:

- **Faster cloning**: 14 MB vs 154 MB
- **Cleaner history**: Dependencies rarely change, no need to track them
- **Easier updates**: Dependencies can be updated independently
- **Bandwidth friendly**: Only download what you need

The dependencies are:
- **FreeWrap 6.61** (38 MB) - Stable release, rarely changes
- **Tcl libraries** (5.3 MB) - Itcl 3.4, tDOM 0.9.3, img_png 1.4.14, etc.
- **ActiveTcl md5** (partial) - Only the MD5 library is needed

All dependencies are 32-bit PE32 binaries compatible with Windows 7+.

## Technical Details

### Itcl 3.4 (Not 4.0.5)

The project uses **Itcl 3.4** instead of 4.0.5 because:
- MCU8051IDE relies on Itcl 3.4's `common` variable cross-class access pattern
- Itcl 4.0+ changed this API and breaks the IDE
- Itcl 3.4 is compatible with Tcl 8.6

### Portable Executable

The built executable uses `$argv0` to locate its directory, making it fully portable:
- Can run from any directory
- Can run from USB drives
- No hardcoded paths
- Works on any Windows machine

### 32-bit Application

MCU 8051 IDE is a **32-bit application**:
- All DLLs are PE32 (i386 architecture)
- Uses freewrap32.exe for packaging
- Installs to `C:\Program Files (x86)\MCU 8051 IDE` on 64-bit Windows
- Runs on both 32-bit and 64-bit Windows

## Requirements

- **Windows 7 or later** (32-bit or 64-bit)
- **No Tcl/Tk installation required** (bundled in executable)
- **SDCC compiler** (optional, for C language support)
  - Download: http://sdcc.sourceforge.net/

## Version History

- **1.4.9** (Current) - Moravia Microsystems release
- **1.4.7** - Original SourceForge release

## License

GNU General Public License v2.0 (GPL-2.0)

See `src/LICENSE` for details.

## Credits

- **Original Author**: Martin Osmera
- **Windows Port**: Community effort
- **Upstream**: https://sourceforge.net/projects/mcu8051ide/

## Troubleshooting

### "resources/ directory not found"

Run `download_deps.bat` to download required dependencies.

### "freewrapTCLSH32.exe not found"

Ensure `download_deps.bat` completed successfully. Check that `resources/freewrap/` exists.

### Build fails with "missing close-brace"

This was a known issue in older versions. Ensure you're using the latest code from the main branch.

### Installer installs to wrong directory

The installer should install to:
- 64-bit Windows: `C:\Program Files (x86)\MCU 8051 IDE`
- 32-bit Windows: `C:\Program Files\MCU 8051 IDE`

If it installs to the wrong location, the Inno Setup script may be outdated. Run `build_installer.bat` to regenerate.
