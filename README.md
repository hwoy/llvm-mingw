# LLVM-MinGW Distro:https://github.com/hwoy/llvm-mingw.git

Here are the build scripts for my MinGW distro.

You'll need to run them in MSYS2, which you can set up without an installer:

* Go to: https://github.com/msys2/msys2-installer/releases/latest
* Download: `msys2-base-x86_64-<RELEASE_DATE>.tar.xz`
* Extract it to: `C:\Temp\` (any where you want)
* Run: `msys2_shell.cmd`
* Restart MSYS2 when you're instructed to.
* In MSYS2, repeatedly run `pacman -Syuu` until you see:
  ```
  :: Synchronizing package databases...
   mingw32 is up to date
   mingw64 is up to date
   ucrt64 is up to date
   clang64 is up to date
   msys is up to date
  :: Starting core system upgrade...
   there is nothing to do
  :: Starting full system upgrade...
   there is nothing to do
  ```
* In MSYS2, run: `pacman -Syy mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain`
* In MSYS2, run: `pacman -Syy mingw-w64-i686-cmake mingw-w64-i686-extra-cmake-modules mingw-w64-x86_64-cmake mingw-w64-x86_64-extra-cmake-modules`
* In MSYS2, run: `pacman -Syy mingw-w64-i686-ninja mingw-w64-x86_64-ninja`
* In MSYS2, run: `pacman -Syy mingw-w64-i686-autotools mingw-w64-x86_64-autotools`
* In MSYS2, run: `pacman -Syy autoconf autogen`
* In MSYS2, run: `pacman -Syy base-devel compression`
* In MSYS2, run: `pacman -Syy git` (Optional)
* In MSYS2, repeatedly run `pacman -Syuu` again. Answer `Y` if you're asked:
  ```
  :: Replace pkg-config with msys/pkgconf? [Y/n]
  ```

## Important Notes

The build scripts assume that:

* `C:\Temp\msys64\{mingw64 mingw32}` contains the compiler and dependecies.
  + This assumption is centralized in `0_append_distro_path{_32}.sh`, where it says `export X_DISTRO_ROOT=/c/Temp/msys64/{mingw64 mingw32}`.
* `C:\Temp\MinGW-Base` (any where you want) is a based directory.
  + `0_append_distro_path{_32}.sh`, where it says `export X_BASEDIR=/c/Temp`.
* `C:\Temp\MinGW-Base\Sources` is a working directory.
  + `0_append_distro_path{_32}.sh`, where it says `export X_SRCDIR=${X_BASEDIR}/Sources`.
* `C:\Temp\MinGW-Base\Builds` is an out put directory.
  + `0_append_distro_path{_32}.sh`, where it says `export X_BUILDDIR=${X_BASEDIR}/Builds`.
* Run `INITPROJECT.sh` create project directroy.
* Run `DOWNLOADALLPKG.sh` download source code packages.
* Enter `C:\Temp\MinGW-Base\Sources`, In MinGW32 run `32.BUILDALL.sh`
* Enter `C:\Temp\MinGW-Base\Sources`, In MinGW64 run `64.BUILDALL.sh`

Watthanachai Dueanklang - bosskillerz@gmail.com

# Thanks :[mstorsjo/llvm-mingw](https://github.com/mstorsjo/llvm-mingw)
# Thanks :[nuwen.net/mingw.html](https://nuwen.net/mingw.html)
# Thanks :[github.com/msys2/MINGW-packages](https://github.com/msys2/MINGW-packages)
