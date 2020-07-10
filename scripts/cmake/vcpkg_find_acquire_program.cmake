## # vcpkg_find_acquire_program
##
## Download or find a well-known tool.
##
## ## Usage
## ```cmake
## vcpkg_find_acquire_program(<VAR>)
## ```
## ## Parameters
## ### VAR
## This variable specifies both the program to be acquired as well as the out parameter that will be set to the path of the program executable.
##
## ## Notes
## The current list of programs includes:
##
## - 7Z
## - ARIA2 (Downloader)
## - BISON
## - DARK
## - DOXYGEN
## - FLEX
## - GASPREPROCESSOR
## - GPERF
## - PERL
## - PYTHON2
## - PYTHON3
## - GIT
## - GN
## - GO
## - JOM
## - MESON
## - NASM
## - NINJA
## - NUGET
## - SCONS
## - YASM
##
## Note that msys2 has a dedicated helper function: [`vcpkg_acquire_msys`](vcpkg_acquire_msys.md).
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
## * [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)
include(FindPackageHandleStandardArgs)
Include(CMakeParseArguments)
function(vcpkg_find_acquire_program VAR)
  set(EXPANDED_VAR ${${VAR}})
  if(EXPANDED_VAR)
    return()
  endif()

#  cmake_parse_arguments(
#    _vfa
#    ""
#    "REQUIRED_LIBRARY_PATH_VAR;REQUIRED_BINARY_PATH_VAR;VERSION_VAR"
#    ""
#    ${ARGN}
#  )

  unset(NOEXTRACT)
  unset(_vfa_RENAME)
  unset(SUBDIR)
  unset(REQUIRED_INTERPRETER)
  unset(_vfa_SUPPORTED)
  unset(POST_INSTALL_COMMAND)

  vcpkg_get_program_files_platform_bitness(PROGRAM_FILES_PLATFORM_BITNESS)
  set(PROGRAM_FILES_32_BIT $ENV{ProgramFiles\(X86\)})
  if (NOT DEFINED PROGRAM_FILES_32_BIT)
      set(PROGRAM_FILES_32_BIT $ENV{PROGRAMFILES})
  endif()

  if(VAR MATCHES "PERL")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME perl)
      if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(SUBDIR "x86")
        set(URL 
#          "https://strawberry.perl.bot/download/5.30.0.1/strawberry-perl-5.30.0.1-32bit.zip"
#          "http://strawberryperl.com/download/5.30.0.1/strawberry-perl-5.30.0.1-32bit.zip"
          "http://strawberryperl.com/download/5.30.2.1/strawberry-perl-5.30.2.1-32bit-PDL.zip"
          )
        set(ARCHIVE "strawberry-perl-32bit.zip")
        set(HASH d353d3dc743ebdc6d1e9f6f2b7a6db3c387c1ce6c890bae8adc8ae5deae8404f4c5e3cf249d1e151e7256d4c5ee9cd317e6c41f3b6f244340de18a24b938e0c4)
      else()
        set(SUBDIR "x64")
        set(URL 
#          "https://strawberry.perl.bot/download/5.30.0.1/strawberry-perl-5.30.0.1-32bit.zip"
#          "http://strawberryperl.com/download/5.30.0.1/strawberry-perl-5.30.0.1-32bit.zip"
          "http://strawberryperl.com/download/5.30.2.1/strawberry-perl-5.30.2.1-64bit-PDL.zip"
          )
        set(ARCHIVE "strawberry-perl-64bit.zip")
        set(HASH d353d3dc743ebdc6d1e9f6f2b7a6db3c387c1ce6c890bae8adc8ae5deae8404f4c5e3cf249d1e151e7256d4c5ee9cd317e6c41f3b6f244340de18a24b938e0c4)
      endif()
      set(PATHS ${DOWNLOADS}/tools/perl/${SUBDIR}/perl/bin)
    else()
      set(PROGNAME perl)
      set(BREW_PACKAGE_NAME "perl")
      set(APT_PACKAGE_NAME "perl")
    endif()
  elseif(VAR MATCHES "NASM")
    set(PROGNAME nasm)
    set(PATHS ${DOWNLOADS}/tools/nasm/nasm-2.14.02)
    set(BREW_PACKAGE_NAME "nasm")
    set(APT_PACKAGE_NAME "nasm")
    set(URL
      "http://www.nasm.us/pub/nasm/releasebuilds/2.14.02/win32/nasm-2.14.02-win32.zip"
      "http://fossies.org/windows/misc/nasm-2.14.02-win32.zip"
    )
    set(ARCHIVE "nasm-2.14.02-win32.zip")
    set(HASH a0f16a9f3b668b086e3c4e23a33ff725998e120f2e3ccac8c28293fd4faeae6fc59398919e1b89eed7461685d2730de02f2eb83e321f73609f35bf6b17a23d1e)
  elseif(VAR MATCHES "YASM")
    set(PROGNAME yasm)
    set(BREW_PACKAGE_NAME "yasm")
    set(APT_PACKAGE_NAME "yasm")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(SUBDIR 1.3.0/x86/)
        set(PATHS ${DOWNLOADS}/tools/yasm/${SUBDIR}/)
        set(URL "https://www.tortall.net/projects/yasm/snapshots/v1.3.0.6.g1962/yasm-1.3.0.6.g1962.exe")
        set(ARCHIVE "yasm-1.3.0.6-win32.exe")
        set(_vfa_RENAME "yasm.exe")
        set(NOEXTRACT ON)
        set(HASH c1945669d983b632a10c5ff31e86d6ecbff143c3d8b2c433c0d3d18f84356d2b351f71ac05fd44e5403651b00c31db0d14615d7f9a6ecce5750438d37105c55b)
    else(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
        set(SUBDIR 1.3.0/x64/)
        set(PATHS ${DOWNLOADS}/tools/yasm/${SUBDIR}/)
        set(URL "https://github.com/yasm/yasm/releases/download/v1.3.0/yasm-1.3.0-win64.exe")
        set(ARCHIVE "yasm-1.3.0-win64.exe")
        set(_vfa_RENAME "yasm.exe")
        set(NOEXTRACT ON)
        set(HASH 73dfd4ccf93972bb6e4794c071b712de0dbffe6d10345fd9d0b0a9c2472d87cd06f6ac32770af9ba2abb715ad0f80e2a55cf02284f44627dc5e303d66065336f)
    endif()
    get_filename_component(YASM_DIR "${PATHS}/${SUBDIR}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${YASM_DIR}")
    set(YASMPATH "${YASM_DIR}")

      find_program(YASM_EXECUTABLE NAMES yasm vsyasm HINTS "${PATHS}" NO_DEFAULT_PATH)

      if(YASM_EXECUTABLE)
          _execute_process(COMMAND ${YASM_EXECUTABLE} --version
          OUTPUT_VARIABLE YASM_VERSION_STRING ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
          string(REGEX REPLACE "Python " "" YASM_VERSION_STRING "${YASM_VERSION_STRING}")
#          list(GET YASM_VERSION_STRING 0 YASM_VERSION_STRING)
      endif(YASM_EXECUTABLE)
      find_package_handle_standard_args(YASM REQUIRED_VARS YASM_EXECUTABLE VERSION_VAR YASM_VERSION_STRING)
	  mark_as_advanced(FORCE YASM_EXECUTABLE)
	  
	  message(STATUS YASM DIR: "${YASM_DIR}")
#	  message(STATUS YASM PATH: "${YasmPath}")
	
  elseif(VAR MATCHES "GIT")
    set(PROGNAME git)
    if(CMAKE_HOST_WIN32)
      set(SUBDIR "git-2.26.2-1-windows")
      set(URL "https://github.com/git-for-windows/git/releases/download/v2.26.2.windows.1/PortableGit-2.26.2-32-bit.7z.exe")
      set(ARCHIVE "PortableGit-2.26.2-32-bit.7z.exe")
      set(HASH d3cb60d62ca7b5d05ab7fbed0fa7567bec951984568a6c1646842a798c4aaff74bf534cf79414a6275c1927081a11b541d09931c017bf304579746e24fe57b36)
      set(PATHS 
        "${DOWNLOADS}/tools/${SUBDIR}/mingw32/bin"
        "${DOWNLOADS}/tools/git/${SUBDIR}/mingw32/bin")
    else()
      set(BREW_PACKAGE_NAME "git")
      set(APT_PACKAGE_NAME "git")
    endif()
  elseif(VAR MATCHES "GN")
    set(PROGNAME gn)
    set(_vfa_RENAME "gn")
    set(CIPD_DOWNLOAD_GN "https://chrome-infra-packages.appspot.com/dl/gn/gn")
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      set(_vfa_SUPPORTED ON)
      set(GN_VERSION "xus7xtaPhpv5vCmKFOnsBVoB-PKmhZvRsSTjbQAuF0MC")
      set(GN_PLATFORM "linux-amd64")
      set(HASH "871e75d7f3597b74fb99e36bb41fe5a9f8ce8a4d9f167f4729fc6e444807a59f35ec8aca70c2274a99c79d70a1108272be1ad991678a8ceb39e30f77abb13135")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(_vfa_SUPPORTED ON)
      set(GN_VERSION "qhxILDNcJ2H44HfHmfiU-XIY3E_SIXvFqLd2wvbIgOoC")
      set(GN_PLATFORM "mac-amd64")
      set(HASH "03ee64cb15bae7fceb412900d470601090bce147cfd45eb9b46683ac1a5dca848465a5d74c55a47df7f0e334d708151249a6d37bb021de74dd48b97ed4a07937")
    else()
      set(GN_VERSION "qUkAhy9J0P7c5racy-9wB6AHNK_btS18im8S06_ehhwC")
      set(GN_PLATFORM "windows-amd64")
      set(HASH "263e02bd79eee0cb7b664831b7898565c5656a046328d8f187ef7ae2a4d766991d477b190c9b425fcc960ab76f381cd3e396afb85cba7408ca9e74eb32c175db")
    endif()
    set(SUBDIR "${GN_VERSION}")
    set(PATHS "${DOWNLOADS}/tools/gn/${SUBDIR}")
    set(URL "${CIPD_DOWNLOAD_GN}/${GN_PLATFORM}/+/${GN_VERSION}")
    set(ARCHIVE "gn-${GN_PLATFORM}.zip")
  elseif(VAR MATCHES "GO")
    set(PROGNAME go)
    set(PATHS ${DOWNLOADS}/tools/go/go/bin)
    set(BREW_PACKAGE_NAME "go")
    set(APT_PACKAGE_NAME "golang-go")
    set(URL "https://dl.google.com/go/go1.13.1.windows-386.zip")
    set(ARCHIVE "go1.13.1.windows-386.zip")
    set(HASH 2ab0f07e876ad98d592351a8808c2de42351ab387217e088bc4c5fa51d6a835694c501e2350802323b55a27dc0157f8b70045597f789f9e50f5ceae50dea3027)
  elseif(VAR MATCHES "PYTHON3")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME python)
#      set(VERSION "3.7.3")
      if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(SUBDIR "python-3.8.3-x86")
        set(URL "https://www.python.org/ftp/python/3.8.3/python-3.8.3-embed-win32.zip")
        set(ARCHIVE "python-3.8.3-embed-win32.zip")
        set(HASH 8c9078f55b1b5d694e0e809eee6ccf8a6e15810dd4649e8ae1209bff30e102d49546ce970a5d519349ca7759d93146f459c316dc440737171f018600255dcd0a)
#        set(URL "https://globalcdn.nuget.org/packages/pythonx86.3.7.3.nupkg")
#        set(ARCHIVE "pythonx86.3.7.3.nupkg")
#        set(NUPKG_NAME "pythonx86")
#        set(HASH 066e32acfc35b60fc9e6d8d004f7ebe8ee1bbd109c067a433d92f9533a1ff1b3b5d8c3854bc0309900c2bade297950c6af023f271e7c22010b886775a0e8586b)
      else()
        set(SUBDIR "python-3.8.3-x64")
        set(URL "https://www.python.org/ftp/python/3.8.3/python-3.8.3-embed-amd64.zip")
        set(ARCHIVE "python-3.8.3-embed-amd64.zip")
        set(HASH a322fc925167edb1897764297cf47e294ad3f52c109a05f8911412807eb83e104f780e9fe783b17fe0d9b18b7838797c15e9b0805dab759829f77a9bc0159424)
#        set(URL "https://globalcdn.nuget.org/packages/python.3.7.3.nupkg")
#        set(ARCHIVE "python.3.7.3.nupkg")
#        set(NUPKG_NAME "python")
#        set(HASH 3bf76ee6495235f3104c785f8bde64689e8466276f9223720639ea6226f349d21b24b0365a69ac100ab9cd86c4ab1487fc3335fea9e878db3ba6128a2d74c5a4)
      endif()
      set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
      set(POST_INSTALL_COMMAND ${CMAKE_COMMAND} -E remove python38._pth)
	  
      find_program(PYTHON_EXECUTABLE NAMES python python3 python3.8 HINTS "${PATHS}" NO_DEFAULT_PATH)
	  get_filename_component(PYTHON3_DIR "${PATHS}/${SUBDIR}" DIRECTORY)
	  vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")
	  set(PYTHONHOME "${PYTHON3_DIR}")
#	  set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
	  set(Python3_EXECUTABLE "${PYTHON_EXECUTABLE}")
#	  set(Python_EXECUTABLE "${PYTHON_EXECUTABLE}")
	  set(PYTHONPATH "${PYTHONHOME}/DLLs;${PYTHONHOME}/Lib/site-packages")#${PYTHONHOME}/Lib;${PYTHONHOME}/Lib/lib-tk;
	  set(PYTHONSCRIPT "${PYTHONHOME}/Scripts")
	  set(PYTHON_PACKAGES_PATH "${PYTHONHOME}/Lib/site-packages")
#      find_package_handle_standard_args(Python3 DEFAULT_MSG Python3_EXECUTABLE)
      if(PYTHON_EXECUTABLE)
          _execute_process(COMMAND ${PYTHON_EXECUTABLE} --version
          OUTPUT_VARIABLE PYTHON_VERSION_STRING ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
          string(REGEX REPLACE "Python " "" PYTHON_VERSION_STRING "${PYTHON_VERSION_STRING}")
#          list(GET PYTHON_VERSION_STRING 0 PYTHON_VERSION_STRING)
      endif(PYTHON_EXECUTABLE)
      find_package_handle_standard_args(Python3Interp REQUIRED_VARS PYTHON_EXECUTABLE VERSION_VAR PYTHON_VERSION_STRING)
      find_package_handle_standard_args(Python3 REQUIRED_VARS PYTHON_EXECUTABLE VERSION_VAR PYTHON_VERSION_STRING)
	  mark_as_advanced(FORCE PYTHON_EXECUTABLE)
	  
	  message(STATUS PYTHONHOME "${PYTHON3_DIR}")
	  
#	  find_package(Python 3.8 REQUIRED COMPONENTS Interpreter)
#      find_package(Python3 3)
#	  find_package(Python3)
#      find_package(Python3 COMPONENTS Interpreter)
	  
#      set(PATHS ${DOWNLOADS}/tools/python/${NUPKG_NAME}.${VERSION}/tools)
    else()
      set(PROGNAME python3)
      set(BREW_PACKAGE_NAME "python")
      set(APT_PACKAGE_NAME "python3")
    endif()
  elseif(VAR MATCHES "PYTHON2")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME python)
      if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        set(SUBDIR "python-2.7.16-x86")
        set(URL "https://www.python.org/ftp/python/2.7.16/python-2.7.16.msi")
        set(ARCHIVE "python-2.7.16.msi")
        set(HASH c34a6fa2438682104dccb53650a2bdb79eac7996deff075201a0f71bb835d60d3ed866652a1931f15a29510fe8e1009ac04e423b285122d2e5747fefc4c10254)
      else()
        set(SUBDIR "python-2.7.16-x64")
        set(URL "https://www.python.org/ftp/python/2.7.16/python-2.7.16.amd64.msi")
        set(ARCHIVE "python-2.7.16.amd64.msi")
        set(HASH 47c1518d1da939e3ba6722c54747778b93a44c525bcb358b253c23b2510374a49a43739c8d0454cedade858f54efa6319763ba33316fdc721305bc457efe4ffb)
      endif()
      set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
    else()
      set(PROGNAME python2)
      set(BREW_PACKAGE_NAME "python2")
      set(APT_PACKAGE_NAME "python")
    endif()
  elseif(VAR MATCHES "RUBY")
    set(PROGNAME "ruby")
#    set(PATHS ${DOWNLOADS}/tools/ruby/rubyinstaller-2.6.3-1-x86/bin)
#    set(URL "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.4-1/rubyinstaller-2.6.4-1-x64.7z")
#    set(URL "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.4-1/rubyinstaller-2.6.4-1-x86.7z")

    set(URL "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.1-1/rubyinstaller-2.7.1-1-x64.7z")
#    set(URL "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.1-1/rubyinstaller-2.7.1-1-x86.7z")

#    set(URL "http://downloads.activestate.com/ActiveRuby/releases/2.3.4.0-beta/ActiveRuby-2.3.4.0-beta-win64.exe")
#    set(URL "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.4-1/rubyinstaller-devkit-2.6.4-1-x64.exe")
#    set(URL "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.4-1/rubyinstaller-devkit-2.6.4-1-x86.exe")
    set(ARCHIVE rubyinstaller.7z)
    set(HASH 4322317dd02ce13527bf09d6e6a7787ca3814ea04337107d28af1ac360bd272504b32e20ed3ea84eb5b21dae7b23bfe5eb0e529b6b0aa21a1a2bbb0a542d7aec)
  elseif(VAR MATCHES "JOM")
    set(PROGNAME jom)
    set(SUBDIR "jom-1.1.3")
    set(PATHS ${DOWNLOADS}/tools/jom/${SUBDIR})
    set(URL 
      "http://download.qt.io/official_releases/jom/jom_1_1_3.zip" 
      "http://mirrors.ocf.berkeley.edu/qt/official_releases/jom/jom_1_1_3.zip"
    )
    set(ARCHIVE "jom_1_1_3.zip")
    set(HASH 5b158ead86be4eb3a6780928d9163f8562372f30bde051d8c281d81027b766119a6e9241166b91de0aa6146836cea77e5121290e62e31b7a959407840fc57b33)
  elseif(VAR MATCHES "7Z")
    set(PROGNAME 7z)
    set(PATHS "${PROGRAM_FILES_PLATFORM_BITNESS}/7-Zip" "${PROGRAM_FILES_32_BIT}/7-Zip" "${DOWNLOADS}/tools/7z/Files/7-Zip")
    set(URL "https://7-zip.org/a/7z1900.msi")
    set(ARCHIVE "7z1900.msi")
    set(HASH f73b04e2d9f29d4393fde572dcf3c3f0f6fa27e747e5df292294ab7536ae24c239bf917689d71eb10cc49f6b9a4ace26d7c122ee887d93cc935f268c404e9067)
  elseif(VAR MATCHES "NINJA")
    set(PROGNAME ninja)
    set(SUBDIR "ninja-1.10.0")
    if(CMAKE_HOST_WIN32)
      set(PATHS "${DOWNLOADS}/tools/${SUBDIR}-windows")
      list(APPEND PATHS "${DOWNLOADS}/tools/ninja/${SUBDIR}")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(PATHS "${DOWNLOADS}/tools/${SUBDIR}-osx")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD")
      set(PATHS "${DOWNLOADS}/tools/${SUBDIR}-freebsd")
    else()
      set(PATHS "${DOWNLOADS}/tools/${SUBDIR}-linux")
    endif()
    set(BREW_PACKAGE_NAME "ninja")
    set(APT_PACKAGE_NAME "ninja-build")
    set(URL "https://github.com/ninja-build/ninja/releases/download/v1.10.0/ninja-win.zip")
    set(ARCHIVE "ninja-win-1.10.0.zip")
    set(HASH a196e243c53daa1df9d287af658d6d38d6b830b614f2d5704e8c88ffc61f179a533ae71cdb6d0d383d1559d65dacccbaaab270fb2a33aa211e5dba42ff046f97)
  elseif(VAR MATCHES "NUGET")
    set(PROGNAME nuget)
    set(SUBDIR "5.5.1")
    set(PATHS "${DOWNLOADS}/tools/nuget/${SUBDIR}")
    set(BREW_PACKAGE_NAME "nuget")
    set(URL "https://dist.nuget.org/win-x86-commandline/v5.5.1/nuget.exe")
    set(_vfa_RENAME "nuget.exe")
    set(ARCHIVE "nuget.5.5.1.exe")
    set(NOEXTRACT ON)
    set(HASH 22ea847d8017cd977664d0b13c889cfb13c89143212899a511be217345a4e243d4d8d4099700114a11d26a087e83eb1a3e2b03bdb5e0db48f10403184cd26619)
  elseif(VAR MATCHES "CMAKE")
    set(PROGNAME cmake)
    set(PATHS "${PROGRAM_FILES_PLATFORM_BITNESS}/CMake/bin" "${PROGRAM_FILES_32_BIT}/CMake/bin" "${DOWNLOADS}/tools/CMake/bin")
  elseif(VAR MATCHES "QT5")
    set(PROGNAME qmake.exe)
    set(PATHS "I:/Compile/Qt/5.11.1/msvc2015_64/bin")
  elseif(VAR MATCHES "QT4")
    set(PROGNAME qmake.exe)
    set(PATHS "I:/Compile/Qt/4.8/msvc2015_64/bin")
  elseif(VAR MATCHES "CLANG")
    set(PROGNAME clang)
    set(PATHS "E:/tools/LLVM-4/bin")
	
#  elseif(VAR MATCHES "WAF")
#    set(PROGNAME waf)
#    set(REQUIRED_INTERPRETER PYTHON3)
#    set(BREW_PACKAGE_NAME "waf")
#    set(APT_PACKAGE_NAME "waf")
#    if(CMAKE_HOST_WIN32)
#      set(SCRIPTNAME waf)
#    else()
#      set(SCRIPTNAME waf-light)
#    endif()
#    set(PATHS ${DOWNLOADS}/tools/waf/waf-2.0.18)
#    set(URL "https://waf.io/waf-2.0.18.tar.bz2")
#    set(ARCHIVE "waf-2.0.18.tar.bz2")
#    set(HASH aa102922dd48bd1d2f39208ee84f91330a1a5993a3471667181e3e47817d4cf57b0ff9041c1d75b6648d279de6688c7564670cb76ca19da1bd412d1603389e0a)

  elseif(VAR MATCHES "MESON")
    set(PROGNAME meson)
    set(REQUIRED_INTERPRETER PYTHON3)
    set(BREW_PACKAGE_NAME "meson")
    set(APT_PACKAGE_NAME "meson")
    if(CMAKE_HOST_WIN32)
      set(SCRIPTNAME meson.py)
    else()
      set(SCRIPTNAME meson.py meson)
    endif()
    set(PATHS ${DOWNLOADS}/tools/meson/meson-0.54.2)
    set(_vfa_SUPPORTED ON) # Just download meson from github. It is very likely that the system package manager has only an outdated version
    set(URL "https://github.com/mesonbuild/meson/archive/0.54.2.zip")
    set(ARCHIVE "meson-0.54.2.zip")
    set(HASH a322fc925167edb1897764297cf47e294ad3f52c109a05f8911412807eb83e104f780e9fe783b17fe0d9b18b7838797c15e9b0805dab759829f77a9bc0159424)
  elseif(VAR MATCHES "GYP")
    set(PROGNAME gyp)
    set(REQUIRED_INTERPRETER PYTHON2)
    set(BREW_PACKAGE_NAME "gyp")
    set(APT_PACKAGE_NAME "gyp")
    if(CMAKE_HOST_WIN32)
      set(SCRIPTNAME gyp_main.py)
    else()
      set(SCRIPTNAME gyp.bat)
    endif()
    set(PATHS ${DOWNLOADS}/gyp/gyp-aca1e2c3d346d704adfa60944e6b4dd06f4728be)
    set(URL "https://github.com/chromium/gyp/archive/aca1e2c3d346d704adfa60944e6b4dd06f4728be.zip")
    set(ARCHIVE "gyp.zip")
    set(HASH 2b972c60af4664baf6ce4d2181810a2e9d67fe634dd2942b92a8e5b9eccef6f5116cd943f2a4d1b2baffdc824bd7d4252d206c7cca638f44b13d8f7c18607e5d)
	
  elseif(VAR MATCHES "FLEX")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME win_flex)
      set(SUBDIR win_flex-2.5.18)
      set(PATHS ${DOWNLOADS}/tools/win_flex/${SUBDIR})
      set(URL "https://sourceforge.net/projects/winflexbison/files/win_flex_bison-2.5.18.zip/download")
      set(ARCHIVE "win_flex_bison-2.5.18.zip")
      set(HASH 8b30f046e090a0ddcf85b38197913bbf5ac6f5e3063bdfebf288fd7e3d22288c72ba98fd2d04c5eaf9157997bc4bd9911c1e0f6007106589d25b58a9673f7b83)
      if(NOT EXISTS "${PATHS}/data/m4sugar/m4sugar.m4")
        file(REMOVE_RECURSE "${PATHS}")
      endif()
    else()
      set(PROGNAME flex)
      set(APT_PACKAGE_NAME flex)
      set(BREW_PACKAGE_NAME flex)
    endif()
  elseif(VAR MATCHES "BISON")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME win_bison)
      set(SUBDIR win_bison-2.5.18)
      set(PATHS ${DOWNLOADS}/tools/win_bison/${SUBDIR})
      set(URL "https://sourceforge.net/projects/winflexbison/files/win_flex_bison-2.5.18.zip/download")
      set(ARCHIVE "win_flex_bison-2.5.18.zip")
      set(HASH 8b30f046e090a0ddcf85b38197913bbf5ac6f5e3063bdfebf288fd7e3d22288c72ba98fd2d04c5eaf9157997bc4bd9911c1e0f6007106589d25b58a9673f7b83)
      if(NOT EXISTS "${PATHS}/data/m4sugar/m4sugar.m4")
        file(REMOVE_RECURSE "${PATHS}")
      endif()
    else()
      set(PROGNAME bison)
      set(APT_PACKAGE_NAME bison)
      set(BREW_PACKAGE_NAME bison)
      if (APPLE)
        set(PATHS /usr/local/opt/bison/bin)
      endif()
    endif()
  elseif(VAR MATCHES "GPERF")
    set(PROGNAME gperf)
    set(PATHS ${DOWNLOADS}/tools/gperf/bin)
    set(URL "https://sourceforge.net/projects/gnuwin32/files/gperf/3.0.1/gperf-3.0.1-bin.zip/download")
    set(ARCHIVE "gperf-3.0.1-bin.zip")
    set(HASH 3f2d3418304390ecd729b85f65240a9e4d204b218345f82ea466ca3d7467789f43d0d2129fcffc18eaad3513f49963e79775b10cc223979540fa2e502fe7d4d9)
  elseif(VAR MATCHES "GASPREPROCESSOR")
    set(NOEXTRACT true)
    set(PROGNAME gas-preprocessor)
    set(SUBDIR "b5ea3a50")
    set(REQUIRED_INTERPRETER PERL)
    set(SCRIPTNAME "gas-preprocessor.pl")
    set(PATHS ${DOWNLOADS}/tools/gas-preprocessor/${SUBDIR})
    set(_vfa_RENAME "gas-preprocessor.pl")
    set(URL "https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/b5ea3a50ed991e6a3218e89402a8162c73f59cb2/gas-preprocessor.pl")
    set(ARCHIVE "gas-preprocessor-${SUBDIR}.pl")
    set(HASH 3a42a90dee09f3c8653d043d848057287f7460806a08f9471131d0c546ba541bdfa4efa3019e7ffc57a6c20538f1034f7a53b30ecaad9db5add7c71d8de35db9)
  elseif(VAR MATCHES "DARK")
    set(PROGNAME dark)
    set(SUBDIR "wix311-binaries")
    set(PATHS ${DOWNLOADS}/tools/dark/${SUBDIR})
    set(URL "https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip")
    set(ARCHIVE "wix311-binaries.zip")
    set(HASH 74f0fa29b5991ca655e34a9d1000d47d4272e071113fada86727ee943d913177ae96dc3d435eaf494d2158f37560cd4c2c5274176946ebdb17bf2354ced1c516)
  elseif(VAR MATCHES "SCONS")
    set(PROGNAME scons)
    set(REQUIRED_INTERPRETER PYTHON3)
    set(SCRIPTNAME "scons.py")
    set(PATHS ${DOWNLOADS}/tools/scons)
    set(URL "https://sourceforge.net/projects/scons/files/scons-local/3.1.2/scons-local-3.1.2.zip/download")
    set(ARCHIVE "scons-local-3.1.2.zip")
    set(HASH 5a6f6321564c5578978245695b75855ab19ad6c5ffd2c7831d0c02c17bef850c9b08d72d53a6457a53f04caa8a814b1863cf4731ddfb263dc57039c58ddbe814)
  elseif(VAR MATCHES "ASCIIDOC")
    set(PROGNAME asciidoc)
    set(REQUIRED_INTERPRETER PYTHON2)
    set(SCRIPTNAME asciidoc.py)
    set(PATHS ${DOWNLOADS}/tools/${PROGNAME}/asciidoc-8.6.10)
    set(URL "https://github.com/asciidoc/asciidoc/archive/8.6.10.zip")
    set(ARCHIVE "asciidoc.zip")
    set(HASH c418e0dc7c9dfe83721823ddcfb6e57ac73dc911a33ecc217390d8ec58323b5aa8046b7e123c2a5f5a127ff4eb9e03c801719037be328d85987b4b22dab55e87)
  elseif(VAR MATCHES "TCL")
    set(PROGNAME tclsh)
    set(PATHS ${DOWNLOADS}/tools/tcl/bin)
#	set(SUBDIR "F0EB52A")
#    set(URL "https://sourceforge.net/projects/magicsplat/files/magicsplat-tcl/tcl-8.6.9-installer-1.9.1-x64.msi/download")
    set(URL "https://downloads.activestate.com/ActiveTcl/releases/8.6.9.0/ActiveTcl-8.6.9.8609.2-MSWin32-x64.exe")
    set(ARCHIVE "ActiveTcl.exe")
    set(HASH 8e5f4d81afea4ca64815b4b9ae1aa421ca6e24ced8b4f1bdd01236b7f0e94fef02d16e0b9716c4bbda3c340384d0b770b719888eb17427e74b5c0017765c4567)
#    file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}" DESTINATION_NATIVE_PATH)
    file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}" DESTINATION_NATIVE_PATH)
    set(INSTALL_OPTIONS "/extract:${DESTINATION_NATIVE_PATH}")
  elseif(VAR MATCHES "DOXYGEN")
    set(PROGNAME doxygen)
    set(DOXYGEN_VERSION 1.8.17)
    set(PATHS ${DOWNLOADS}/tools/doxygen)
    set(URL
      "http://doxygen.nl/files/doxygen-${DOXYGEN_VERSION}.windows.bin.zip"
      "https://sourceforge.net/projects/doxygen/files/rel-${DOXYGEN_VERSION}/doxygen-${DOXYGEN_VERSION}.windows.bin.zip")
    set(ARCHIVE "doxygen-${DOXYGEN_VERSION}.windows.bin.zip")
    set(HASH 6bac47ec552486783a70cc73b44cf86b4ceda12aba6b52835c2221712bd0a6c845cecec178c9ddaa88237f5a781f797add528f47e4ed017c7888eb1dd2bc0b4b)
  # Download Tools
  elseif(VAR MATCHES "NPM")
    set(PROGNAME npm)
    set(PATHS "${PROGRAM_FILES_PLATFORM_BITNESS}/nodejs" "${PROGRAM_FILES_32_BIT}/nodejs" "${DOWNLOADS}/tools/nodejs")
  elseif(VAR MATCHES "GO")
    set(PROGNAME go)
    set(PATHS "I:/Compile/Go/bin")

  elseif(VAR MATCHES "MEINPROC4")
    set(PROGNAME meinproc4)
    set(PATHS "${DOWNLOADS}/tools/${PROGNAME}")

  elseif(VAR MATCHES "VALAC")
    set(PROGNAME valac)
    set(PATHS ${DOWNLOADS}/tools/valac/bin)
#    set(URL "http://www.tarnyko.net/repo/vala-0.20.1_(GTK+-3.6.4)(TARNYKO).exe")	
#    set(ARCHIVE "vala-0.20.1.bin")

#    vcpkg_find_acquire_program(7Z)
#    message(STATUS "UnPack ${PROGNAME}")
#    if(NOT EXISTS ${DESTINATION_NATIVE_PATH})
#    file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}" DESTINATION_NATIVE_PATH)
#        _execute_process(
#        COMMAND ${7Z} x -tNsis ${ARCHIVE} -o${DESTINATION_NATIVE_PATH}
#        WORKING_DIRECTORY ${DOWNLOADS}
#        )
#    endif()

#    set(HASH 32b9709694e9c40d38dc01889026a689fe31e0d38f7e6ffeaf4f6e52a4259827475bb6f8d38848ea56bb697d7d9885b61fd90b9afa6545e035e069704028cbb2)

#  if(NOT EXISTS "${PATHS}/uninstall.exe" "${PATHS}/vala-0.20.1_(GTK+-3.6.4)(TARNYKO).zip" "${PATHS}/$PLUGINSDIR")
#    file(REMOVE_RECURSE "${PATHS}")
#  endif()

  elseif(VAR MATCHES "TEXLIVE")
    set(PROGNAME tex)
#http://ctan.pp.ua/systems/win32/w32tex/TLW64/tl-win64.zip
#http://core.ring.gr.jp/pub/text/TeX/ptex-win32/current/TLW64/tl-win64.zip
#http://mirrors.mi.ras.ru/CTAN/systems/win32/w32tex/TLW64/tl-win64.zip
    set(PATHS "${DOWNLOADS}/tools/texlive/bin/win32" "${DOWNLOADS}/tools/miktex/texmfs/install/miktex/bin")

  elseif(VAR MATCHES "DocBookXML4_DTD")
    set(PROGNAME docbookx.dtd)
    set(PATHS "${DOWNLOADS}/tools/xgettext/bin/docbook-xml")
  elseif(VAR MATCHES "DocBookXSL")
    set(PROGNAME catalog.xml)
    set(PATHS "${DOWNLOADS}/tools/xgettext/bin/docbook-xsl")
  elseif(VAR MATCHES "BAZEL")
    set(PROGNAME bazel)
    set(BAZEL_VERSION 0.25.2)
    set(SUBDIR ${BAZEL_VERSION})
    set(PATHS ${DOWNLOADS}/tools/bazel/${SUBDIR})
    set(_vfa_RENAME "bazel")
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      set(_vfa_SUPPORTED ON)
      set(URL "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64")
      set(ARCHIVE "bazel-${BAZEL_VERSION}-linux-x86_64")
      set(NOEXTRACT ON)
      set(HASH db4a583cf2996aeb29fd008261b12fe39a4a5faf0fbf96f7124e6d3ffeccf6d9655d391378e68dd0915bc91c9e146a51fd9661963743857ca25179547feceab1)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(_vfa_SUPPORTED ON)
      set(URL "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-darwin-x86_64") 
      set(ARCHIVE "bazel-${BAZEL_VERSION}-darwin-x86_64")
      set(NOEXTRACT ON)
      set(HASH 420a37081e6ee76441b0d92ff26d1715ce647737ce888877980d0665197b5a619d6afe6102f2e7edfb5062c9b40630a10b2539585e35479b780074ada978d23c)
    else()
      set(URL "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-windows-x86_64.zip") 
      set(ARCHIVE "bazel-${BAZEL_VERSION}-windows-x86_64.zip")
      set(HASH 6482f99a0896f55ef65739e7b53452fd9c0adf597b599d0022a5e0c5fa4374f4a958d46f98e8ba25af4b065adacc578bfedced483d8c169ea5cb1777a99eea53)
    endif()
  # Download Tools
  elseif(VAR MATCHES "ARIA2")
    set(PROGNAME aria2c)
    set(PATHS ${DOWNLOADS}/tools/aria2c/aria2-1.34.0-win-32bit-build1)
    set(URL "https://github.com/aria2/aria2/releases/download/release-1.34.0/aria2-1.34.0-win-32bit-build1.zip")
    set(ARCHIVE "aria2-1.34.0-win-32bit-build1.zip")
    set(HASH 2a5480d503ac6e8203040c7e516a3395028520da05d0ebf3a2d56d5d24ba5d17630e8f318dd4e3cc2094cc4668b90108fb58e8b986b1ffebd429995058063c27)
  elseif(VAR MATCHES "XGETTEXT")
    set(PROGNAME xgettext)
    set(PATHS "${DOWNLOADS}/tools/xgettext/bin")
    set(URL "https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.20.1-v1.16/gettext0.20.1-iconv1.16-static-32.zip")
    set(ARCHIVE "gettext0.20.1.zip")
    set(HASH 9b423bc72c06ce8e1f59842a3ec2d8e2ccab2179179f733a83703d4145300ca9053758ca1232245435e88a82983a785c3b51030eea4a5aaa7c3d7d3995b1c040)	

  elseif(VAR MATCHES "MOZMAKE")
    set(PROGNAME "mozmake")
      set(PATHS "${DOWNLOADS}/tools/${PROGNAME}/bin")
    set(URL "https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-Latest.exe")
    set(ARCHIVE "mozillabuild.nsis")
      set(MOZILLABUILD "${DOWNLOADS}/tools/${PROGNAME}")
    if(VAR MATCHES "MOZ_PYTHON2")
      set(PROGNAME "python2.7")
      set(PATHS "${DOWNLOADS}/tools/${PROGNAME}/python")
      find_program(PYTHON_EXECUTABLE NAMES "python2.7.exe" HINTS "${MOZMAKE}/../python" DOC "path to MOZ_PYTHON2")
    elseif(VAR MATCHES "MOZ_PYTHON3")
      set(PROGNAME "python3.6")
      set(PATHS "${DOWNLOADS}/tools/${PROGNAME}/python3")
    endif()
    find_program(PYTHON3_EXECUTABLE NAMES "python3.6.exe" HINTS "${MOZMAKE}/../python3" DOC "path to MOZ_PYTHON2")
#    set(ENV{MOZILLABUILD} "${DOWNLOADS}/tools/${PROGNAME}")
#    get_filename_component(PYTHON2 "${MOZ_PYTHON2}" DIRECTORY)
#    get_filename_component(PYTHON3 "${MOZ_PYTHON3}" DIRECTORY)
#    set(ENV{PATH} ";$ENV{PATH};${MOZILLABUILD};${MOZILLABUILD}/../nsis-3.01;${MOZILLABUILD}/../msys/bin;${MOZILLABUILD}/../python;${MOZILLABUILD}/../python3")

#    vcpkg_find_acquire_program(7Z)
#    message(STATUS "Usage: get_filename_component(MOZILLABUILD "\${MOZMAKE}"\ DIRECTORY)")
#    file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}" DESTINATION_NATIVE_PATH)
#        _execute_process(
#        COMMAND ${7Z} x -tNsis ${ARCHIVE} -o${DESTINATION_NATIVE_PATH}
#        WORKING_DIRECTORY ${DOWNLOADS}
#    )
    set(HASH db77e882de30f5050489852353d6c171c09b3e70bfd3285d7cda4ea3fc8e7b8df9537ba6430f605c68a1a8c3f33e4763a03d353f915fd755df2a7e26409974c2)

  elseif(VAR MATCHES "SWIG")
    set(PROGNAME swig)
    set(PATHS "${DOWNLOADS}/tools/swig/swigwin-3.0.12")
    set(URL "https://jaist.dl.sourceforge.net/project/swig/swigwin/swigwin-3.0.12/swigwin-3.0.12.zip")
    set(ARCHIVE "swigwin-3.0.12.zip")
    set(HASH f47024e850e2a7eca97e2d67c6a3e88677a44678bf0bf9cc0cd4f784648d325645e05dee5b3d661caa24b9653054447d3b53eefe005a09ad6a82cdc286c3c22b)

  elseif(VAR MATCHES "FLANG")
    set(ERROR_LIST "")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      if(CMAKE_HOST_WIN32)
        set(VERSION "5.0.0")
        set(CLANG_URL "https://conda.anaconda.org/conda-forge/win-64/clangdev-${FLANG_VERSION}-flang_3.tar.bz2")
        set(LIBFLANG_URL "https://conda.anaconda.org/conda-forge/win-64/libflang-${FLANG_VERSION}-vc14_20180208.tar.bz2")
        set(OPENMP_URL "https://conda.anaconda.org/conda-forge/win-64/openmp-${FLANG_VERSION}-vc14_1.tar.bz2")
        set(FLANG_URL "https://conda.anaconda.org/conda-forge/win-64/flang-${FLANG_VERSION}-vc14_20180208.tar.bz2")

        set(URL_VARS CLANG_URL LIBFLANG_URL OPENMP_URL FLANG_URL)

        set(ARCHIVES
            "clangdev-${VERSION}-flang_3.tar.bz2"
            "libflang-${VERSION}-vc14_20180208.tar.bz2"
            "openmp-${VERSION}-vc14_1.tar.bz2"
            "flang-${VERSION}-vc14_20180208.tar.bz2"
        )

        set(HASHES
            "fd5eb1d39ba631e2e85ecf63906c8a5d0f87e5f3f9a86dbe4cfd28d399e922f9786804f94f2a3372d13c9c4f01d9d253fba31d9695be815b4798108db17939b4"
            "a8bcb44b344c9ca3571e1de08894d9ee450e2a36e9a604dedb264415adbabb9b0b698b39d96abc8b319041b15ba991b28d463a61523388509038a363cbaebae2"
            "5277f0a33d8672b711bbf6c97c9e2e755aea411bfab2fce4470bb2dd112cbbb11c913de2062331cc61c3acf7b294a6243148d7cb71b955cc087586a2f598809a"
            "c72a4532dfc666ad301e1349c1ff0f067049690f53dbf30fd38382a546b619045a34660ee9591ce5c91cf2a937af59e87d0336db2ee7f59707d167cd92a920c4"
        )

        set(REQUIRED_LIBRARY_PATH "${DOWNLOADS}/tools/flang/${VERSION}/Library/lib")
        set(REQUIRED_BINARY_PATH "${DOWNLOADS}/tools/flang/${VERSION}/Library/bin")
      elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(VERSION "7.0.0")
        set(URL https://github.com/flang-compiler/flang/releases/download/flang_20190329/flang-20190329-x86-70.tgz)
        set(ARCHIVE "flang-20190329-x86-70.tgz")
        set(HASH "4e6f4ced56a10405dd6b556b5a3f1f294db544fe84e6a7a165abccfaa58f192badaacd90f079fd496e2405a84b49bbbc965505ca868bb9c9ccba78df315938ad")
        set(REQUIRED_LIBRARY_PATH "${DOWNLOADS}/tools/flang/${VERSION}/lib")
        set(REQUIRED_BINARY_PATH "${DOWNLOADS}/tools/flang/${VERSION}/bin")
      endif()
    else()
      message(FATAL "Flang can only target 64-bit architectures.")
    endif()

    set(PROGNAME flang)
    set(SUBDIR ${VERSION})
    set(PATHS ${DOWNLOADS}/tools/flang/${VERSION}/bin)
    set(SKIP_PACKAGE_MANAGER TRUE)
  else()
    message(FATAL "unknown tool ${VAR} -- unable to acquire.")
  endif()

  if(NOT DEFINED ARCHIVES)
    set(ARCHIVES ${ARCHIVE})
  endif()

  if(NOT DEFINED HASHES)
    set(HASHES ${HASH})
  endif()

  if(NOT DEFINED URL_VARS)
    set(URL_VARS URL)
  endif()

  macro(do_find)
    if(NOT DEFINED REQUIRED_INTERPRETER)
      find_program(${VAR} NAMES ${PROGNAME} PATHS ${PATHS} NO_DEFAULT_PATH ${FIND_OPTIONS})
      find_program(${VAR} NAMES ${PROGNAME})
    else()
      vcpkg_find_acquire_program(${REQUIRED_INTERPRETER})
      find_file(SCRIPT_${VAR} NAMES ${SCRIPTNAME} PATHS ${PATHS} NO_DEFAULT_PATH)
      find_file(SCRIPT_${VAR} NAMES ${SCRIPTNAME})
      set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT_${VAR}})
    endif()
  endmacro()

  do_find()
  if("${${VAR}}" MATCHES "-NOTFOUND")
    if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows" AND NOT _vfa_SUPPORTED AND NOT SKIP_PACKAGE_MANAGER)
      set(EXAMPLE ".")
      if(DEFINED BREW_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        set(EXAMPLE ":\n    brew install ${BREW_PACKAGE_NAME}")
      elseif(DEFINED APT_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(EXAMPLE ":\n    sudo apt-get install ${APT_PACKAGE_NAME}")
      endif()
      message(FATAL_ERROR "Could not find ${PROGNAME}. Please install it via your package manager${EXAMPLE}")
    endif()

    list(LENGTH ARCHIVES ARCHIVES_LENGTH)
    list(LENGTH HASHES HASHES_LENGTH)
    list(LENGTH URL_VARS URL_VARS_LENGTH)

    if(ARCHIVES_LENGTH GREATER HASHES_LENGTH)
      message(FATAL_ERROR "A hash must be provided for every archive")
    endif()

    if(ARCHIVES_LENGTH GREATER URL_VARS_LENGTH)
        message(FATAL_ERROR "A list of URLS must be provided for every archive")
    endif()

    math(EXPR ARCHIVES_LENGTH "${ARCHIVES_LENGTH}-1")

    foreach(ARCHIVE_IDX RANGE ${ARCHIVES_LENGTH})
      list(GET ARCHIVES $ARCHIVE_IDX ARCHIVE)
      list(GET HASHES $ARCHIVE_IDX HASH)
      list(GET URL_VARS $ARCHIVE_IDX URL_VAR)
      set(URLS ${${URL_VAR}})

      vcpkg_download_distfile(ARCHIVE_PATH
        URLS ${URLS}
        SHA512 ${HASH}
        FILENAME ${ARCHIVE}
    )

    set(PROG_PATH_SUBDIR "${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}")
    file(MAKE_DIRECTORY ${PROG_PATH_SUBDIR})
    if(DEFINED NOEXTRACT)
      if(DEFINED _vfa_RENAME)
        file(INSTALL ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} RENAME ${_vfa_RENAME} FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
      else()
        file(COPY ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
      endif()
    else()
      get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} LAST_EXT)
      string(FIND ${ARCHIVE_EXTENSION} "." IDX REVERSE)
      if (IDX GREATER 0)
        string(SUBSTRING ${ARCHIVE_EXTENSION} ${IDX} -1 ARCHIVE_EXTENSION)
      endif()
      string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
      if (INSTALL_OPTIONS STREQUAL "")
        set(HAS_INSTALL_OPTIONS OFF)
      else()
        set(HAS_INSTALL_OPTIONS ON)
      endif()
      if(ARCHIVE_EXTENSION STREQUAL ".msi")
        file(TO_NATIVE_PATH "${ARCHIVE_PATH}" ARCHIVE_NATIVE_PATH)
        file(TO_NATIVE_PATH "${PROG_PATH_SUBDIR}" DESTINATION_NATIVE_PATH)
        _execute_process(
          COMMAND msiexec /a ${ARCHIVE_NATIVE_PATH} /qn TARGETDIR=${DESTINATION_NATIVE_PATH}
          WORKING_DIRECTORY ${DOWNLOADS}
        )
      elseif(ARCHIVE_EXTENSION STREQUAL ".exe$" AND HAS_INSTALL_OPTIONS)
        file(TO_NATIVE_PATH "${ARCHIVE_PATH}" ARCHIVE_NATIVE_PATH)
        _execute_process(
          COMMAND "${ARCHIVE_NATIVE_PATH}" ${INSTALL_OPTIONS}
          WORKING_DIRECTORY ${DOWNLOADS}
        )
      elseif(ARCHIVE_EXTENSION STREQUAL ".nsis")
        vcpkg_find_acquire_program(7Z)
#        file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}" DESTINATION_NATIVE_PATH)
        _execute_process(
#          COMMAND ${7Z} x ${ARCHIVE} -o${DESTINATION_NATIVE_PATH}
#          WORKING_DIRECTORY ${DOWNLOADS}
          COMMAND ${7Z} x "${ARCHIVE_PATH}" "-o${PROG_PATH_SUBDIR}" -y -bso0 -bsp0
          WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
        )
      elseif("${ARCHIVE_PATH}" MATCHES ".nupkg$")
        vcpkg_find_acquire_program(NUGET)
        set(NOEXTRACT ON)
        vcpkg_execute_required_process(COMMAND
          ${NUGET} install ${NUPKG_NAME} -Version ${VERSION} -Source ${DOWNLOADS} -OutputDirectory ${PROG_PATH_SUBDIR}
          WORKING_DIRECTORY ${DOWNLOADS}
        )
#	file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}" DESTINATION_NATIVE_PATH)
#        _execute_process(
#			COMMAND ${7Z} x -tNsis ${ARCHIVE} -o${DESTINATION_NATIVE_PATH}

#	if(ARCHIVE_EXTENSION STREQUAL ".exe")
#		file(TO_NATIVE_PATH "${PROG_PATH_SUBDIR}" DESTINATION_NATIVE_PATH)
#		file(TO_NATIVE_PATH "${ARCHIVE}" ARCHIVE_NATIVE_PATH)
#        _execute_process(
#			COMMAND ${7z} x ${ARCHIVE_NATIVE_PATH} -o${DESTINATION_NATIVE_PATH}
#			WORKING_DIRECTORY ${DOWNLOADS}
#        )
#	endif()

#    else()
#      get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} EXT)
#      string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
#      if(ARCHIVE_EXTENSION STREQUAL ".exe")
#        file(TO_NATIVE_PATH "${ARCHIVE_PATH}" ARCHIVE_NATIVE_PATH)
#        file(TO_NATIVE_PATH "${PROG_PATH_SUBDIR}" DESTINATION_NATIVE_PATH)
#        _execute_process(
#          COMMAND ${7Z} x ${ARCHIVE_NATIVE_PATH} -o${DESTINATION_NATIVE_PATH}
#          WORKING_DIRECTORY ${DOWNLOADS}
#    )

      else()
        _execute_process(
          COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
          WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
        )
      endif()
    endif()

    if(DEFINED POST_INSTALL_COMMAND)
      vcpkg_execute_required_process(
        ALLOW_IN_DOWNLOAD_MODE
        COMMAND ${POST_INSTALL_COMMAND}
        WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
        LOGNAME ${VAR}-tool-post-install
      )
    endif()

    do_find()
    endforeach()
  endif()

  set(${VAR} "${${VAR}}" PARENT_SCOPE)

#  message("${REQUIRED_BINARY_PATH}")

#  if(DEFINED _vfa_REQUIRED_LIBRARY_PATH_VAR)
#    set(${_vfa_REQUIRED_LIBRARY_PATH_VAR} ${REQUIRED_LIBRARY_PATH} PARENT_SCOPE)
#  endif()

#  if(DEFINED _vfa_REQUIRED_BINARY_PATH_VAR)
#    set(${_vfa_REQUIRED_BINARY_PATH_VAR} ${REQUIRED_BINARY_PATH} PARENT_SCOPE)
#  endif()

#  if(DEFINED _vfa_VERSION_VAR)
#    set(${_vfa_VERSION_VAR} ${VERSION} PARENT_SCOPE)
#  endif()
endfunction()
