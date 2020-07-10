## # vcpkg_acquire_msys
##
## Download and prepare an MSYS2 instance.
##
## ## Usage
## ```cmake
## vcpkg_acquire_msys(<MSYS_ROOT_VAR> [PACKAGES <package>...])
## ```
##
## ## Parameters
## ### MSYS_ROOT_VAR
## An out-variable that will be set to the path to MSYS2.
##
## ### PACKAGES
## A list of packages to acquire in msys.
##
## To ensure a package is available: `vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.15)`
##
## ## Notes
## A call to `vcpkg_acquire_msys` will usually be followed by a call to `bash.exe`:
## ```cmake
## vcpkg_acquire_msys(MSYS_ROOT)
## set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
##
## vcpkg_execute_required_process(
##     COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
##     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
##     LOGNAME build-${TARGET_TRIPLET}-rel
## )
## ```
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
## * [libvpx](https://github.com/Microsoft/vcpkg/blob/master/ports/libvpx/portfile.cmake)

function(vcpkg_acquire_msys PATH_TO_ROOT_OUT)
  set(TOOLPATH ${DOWNLOADS}/tools/msys2)
  cmake_parse_arguments(_am "" "" "PACKAGES" ${ARGN})

  if(NOT CMAKE_HOST_WIN32)
    message(FATAL_ERROR "vcpkg_acquire_msys() can only be used on Windows hosts")
  endif()

  # detect host architecture
  if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
  else()
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
  endif()

  if(_vam_HOST_ARCHITECTURE STREQUAL "AMD64")
    set(TOOLSUBPATH msys64)
    set(URLS
      "https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20190524.tar.xz/download"
      "http://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20190524.tar.xz"
    )
    set(ARCHIVE "msys2-base-x86_64-20190524.tar.xz")
    set(HASH 50796072d01d30cc4a02df0f9dafb70e2584462e1341ef0eff94e2542d3f5173f20f81e8f743e9641b7528ea1492edff20ce83cb40c6e292904905abe2a91ccc)
    set(STAMP "initialized-msys2_64.stamp")
  else()
    set(TOOLSUBPATH msys32)
    set(URLS
      "https://sourceforge.net/projects/msys2/files/Base/i686/msys2-base-i686-20190524.tar.xz/download"
      "http://repo.msys2.org/distrib/i686/msys2-base-i686-20190524.tar.xz"
    )
    set(ARCHIVE "msys2-base-i686-20190524.tar.xz")
    set(HASH b26d7d432e1eabe2138c4caac5f0a62670f9dab833b9e91ca94b9e13d29a763323b0d30160f09a381ac442b473482dac799be0fea5dd7b28ea2ddd3ba3cd3c25)
    set(STAMP "initialized-msys2_32.stamp")
  endif()

  set(PATH_TO_ROOT ${TOOLPATH}/${TOOLSUBPATH})

  if(NOT EXISTS "${TOOLPATH}/${STAMP}")

    message(STATUS "Acquiring MSYS2...")
    vcpkg_download_distfile(ARCHIVE_PATH
        URLS ${URLS}
        FILENAME ${ARCHIVE}
        SHA512 ${HASH}
    )

    file(REMOVE_RECURSE ${TOOLPATH}/${TOOLSUBPATH})
    file(MAKE_DIRECTORY ${TOOLPATH})
    _execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;rm -r /etc/pacman.d/gnupg/"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman-key --init;PATH=/usr/bin;pacman-key --populate;PATH=/usr/bin;pacman-key --refresh-keys"
      WORKING_DIRECTORY ${TOOLPATH}
    )

#    _execute_process(
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syuu --noconfirm --overwrite '*'"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )

#       COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syuu --noconfirm && ps -ef | grep 'gpg-agent' | grep -v grep | awk '{print `$2}' | xargs -r kill -9"
#       COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syuu --needed --noconfirm --ask=20 --disable-download-timeout --overwrite '*'"
#       COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syuu --noconfirm --disable-download-timeout --overwrite '*'"

#    _execute_process(
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;gpgconf --homedir /etc/pacman.d/gnupg --kill all"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )

#    _execute_process(
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Rc dash --noconfirm"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )
#    _execute_process(
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;gpgconf --homedir /etc/pacman.d/gnupg --kill all"
#      WORKING_DIRECTORY ${TOOLPATH}
#    )

    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Sydd --noconfirm --needed --ask=20 --disable-download-timeout --overwrite '*' pacman"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syuu --noconfirm --ask=20 --disable-download-timeout --overwrite '*'"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND taskkill /f /fi "MODULES eq msys-2.0.dll"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Syuu --noconfirm --ask=20 --disable-download-timeout --overwrite '*'"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND taskkill /f /fi "MODULES eq msys-2.0.dll"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    _execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -Sydd --noconfirm --needed --ask=20 --disable-download-timeout --overwrite '*' pacman-contrib"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    
    file(WRITE "${TOOLPATH}/${STAMP}" "0")
    message(STATUS "Acquiring MSYS2... OK")

    # Remove database lock
    SET(DB_LOCK_PATH ${PATH_TO_ROOT}/var/lib/pacman/db.lck)
    if (EXISTS "${DB_LOCK_PATH}")
      message(STATUS "${DB_LOCK_PATH} exists --- deleting it")
      file(REMOVE "${DB_LOCK_PATH}")
    endif()
  endif()

  if(_am_PACKAGES)
    message(STATUS "Acquiring MSYS Packages...")
    string(REPLACE ";" " " _am_PACKAGES "${_am_PACKAGES}")
    set(_ENV_ORIGINAL $ENV{PATH})
    set(ENV{PATH} ${PATH_TO_ROOT}/usr/bin)
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman -Su --noconfirm --needed --overwrite '*' `pacman -Ssq ${_am_PACKAGES}` "
#      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "pacman -Syyuu --noconfirm --needed --overwrite '*' ${_am_PACKAGES} "
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin;pacman -S --noconfirm --needed --ask=20 --disable-download-timeout --overwrite '*' ${_am_PACKAGES} "
      WORKING_DIRECTORY ${TOOLPATH}
      LOGNAME msys-pacman-${TARGET_TRIPLET}
    )
    set(ENV{PATH} "${_ENV_ORIGINAL}")

    message(STATUS "Acquiring MSYS Packages... OK")
  endif()

#  # Deal with a stale process created by MSYS
  if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
      vcpkg_execute_required_process(
          ALLOW_IN_DOWNLOAD_MODE
          COMMAND TASKKILL /F /IM gpg-agent.exe /fi "memusage gt 2"
          WORKING_DIRECTORY ${TOOLPATH}
      )
  endif()

#    _execute_process(
#      COMMAND taskkill /F /IM gpg-agent.exe
#      WORKING_DIRECTORY ${TOOLPATH}
#    )

  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
