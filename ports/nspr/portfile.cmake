vcpkg_download_distfile(ARCHIVE
#    URLS "https://hg.mozilla.org/projects/nspr/archive/0f3d68d560164a1c51d8aa9b48f976b0537339be.zip"
    URLS "https://ftp.mozilla.org/pub/nspr/releases/v4.27/src/nspr-4.27.tar.gz"
    FILENAME "nspr-4.27.tar.gz"
#    SHA512 077ac3ffee81f5be8d6777c235db8f2d71f8813bc2baf9293a1745ad9a3918c5d8992a2c12614b606fdf556e063f6871c106d3a80f3c59b2c28553c7452eca4a
    SHA512 	2be539e6fd5ed8987874147a2bacc3f0b7177cdfddbb1a4f9e5f93575de871584b05fb56ca4e1ba5f7e53074cd4069310658f1559de0f38def208b087b6e6dca
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

#set(ENV{NO-DEV} True)
vcpkg_download_distfile(MOZILLABUILDSETUP
    URLS "https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-3.3.exe"
    FILENAME "MozillaBuildSetup-3.3.exe"
    SHA512 ac33d15dd9c974ef8ad581f9b414520a9d5e3b9816ab2bbf3e305d0a33356cc22c356cd9761e64a19588d17b6c13f124e837cfb462a36b8da898899e7db22ded
)

set(MOZILLABUILD "${CURRENT_BUILDTREES_DIR}/moz_build")

vcpkg_find_acquire_program(7Z)
_execute_process(
  COMMAND ${7Z} x -tNsis "${MOZILLABUILDSETUP}" "-o${CURRENT_BUILDTREES_DIR}/moz_build" -y -bso0 -bsp0
  WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
find_program(PKGCONFIG_EXECUTABLE NAMES pkg-config HINTS ${MSYS_ROOT} PATH_SUFFIXES "usr/bin" NO_DEFAULT_PATH)
mark_as_advanced(FORCE PKGCONFIG_EXECUTABLE)
set(PKGCONFIG ${PKGCONFIG_EXECUTABLE})

find_program(BASH_EXECUTABLE NAMES bash HINTS ${MOZILLABUILD} PATH_SUFFIXES "msys/bin" NO_DEFAULT_PATH)
mark_as_advanced(FORCE BASH_EXECUTABLE)
set(BASH ${BASH_EXECUTABLE})
find_program(MOZMAKE_EXECUTABLE NAMES mozmake HINTS ${MOZILLABUILD} PATH_SUFFIXES bin NO_DEFAULT_PATH)
mark_as_advanced(FORCE MOZMAKE_EXECUTABLE)
set(MAKE_EXECUTABLE ${MOZMAKE_EXECUTABLE})
set(MAKE ${MOZMAKE_EXECUTABLE})
find_program(PYTHON_EXECUTABLE NAMES python2.7 HINTS ${MOZILLABUILD} PATH_SUFFIXES python NO_DEFAULT_PATH)
mark_as_advanced(FORCE PYTHON_EXECUTABLE)
find_program(PYTHON3_EXECUTABLE NAMES python3.7 HINTS ${MOZILLABUILD} PATH_SUFFIXES python3 NO_DEFAULT_PATH)
mark_as_advanced(FORCE PYTHON3_EXECUTABLE)
find_program(TOOL_MAKENSIS NAMES "makensis-3.01" HINTS ${MOZILLABUILD} PATH_SUFFIXES "nsis-3.01" NO_DEFAULT_PATH)
mark_as_advanced(FORCE TOOL_MAKENSIS)
set(MAKENSIS_EXECUTABLE ${TOOL_MAKENSIS})

get_filename_component(MOZMAKE_DIR "${MOZMAKE_EXECUTABLE}" DIRECTORY)
vcpkg_add_to_path(${MOZMAKE_DIR})
get_filename_component(MSYS_DIR "${BASH_EXECUTABLE}" DIRECTORY)
vcpkg_add_to_path(${MSYS_DIR})

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=x86_64-pc-mingw32 --target=x86_64-pc-mingw32 --enable-64bit")
else()
  set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=i686-pc-mingw32 --target=i686-pc-mingw32")
endif()

#--enable-win32-target=WIN95 #NSPR build generates a "WINNT" configuration by default on Windows


#if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
#    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --disable-static --enable-shared")
#else()
#    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static --disable-shared")
#endif()

set(CONFIGURE_OPTIONS_RELASE "--disable-debug --prefix=${CURRENT_PACKAGES_DIR}")
set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --disable-optimize --prefix=${CURRENT_PACKAGES_DIR}/debug")

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
#        file(GLOB NSPR_SOURCE_FILES ${SOURCE_PATH}/*)
#        foreach(SOURCE_FILE ${NSPR_SOURCE_FILES})
#          file(COPY ${SOURCE_FILE} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
#        endforeach()
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND ${BASH_EXECUTABLE} --noprofile --norc -c "${SOURCE_PATH}/nspr/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELASE}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            LOGNAME "configure-${TARGET_TRIPLET}-rel")
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
#        file(GLOB NSPR_SOURCE_FILES ${SOURCE_PATH}/*)
#        foreach(SOURCE_FILE ${NSPR_SOURCE_FILES})
#          file(COPY ${SOURCE_FILE} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
#        endforeach()
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND ${BASH_EXECUTABLE} --noprofile --norc -c "${SOURCE_PATH}/nspr/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            LOGNAME "configure-${TARGET_TRIPLET}-dbg")
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
    endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    message(STATUS "Package ${TARGET_TRIPLET}-rel")
    vcpkg_execute_build_process(
        COMMAND ${BASH_EXECUTABLE} --noprofile --norc -c "${MOZMAKE_EXECUTABLE} -j1 USE_64=1 BUILD_OPT=1"# ${VCPKG_CONCURRENCY} - error Waiting for unfinished jobs....
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME "make-build-${TARGET_TRIPLET}-rel")
    vcpkg_execute_build_process(
        COMMAND ${BASH_EXECUTABLE} --noprofile --norc -c "${MOZMAKE_EXECUTABLE} install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME "make-install-${TARGET_TRIPLET}-rel")
    message(STATUS "Package ${TARGET_TRIPLET}-rel done")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    message(STATUS "Package ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_build_process(
        COMMAND ${BASH_EXECUTABLE} --noprofile --norc -c "${MOZMAKE_EXECUTABLE} -j1 USE_64=1 USE_DEBUG_RTL=1"# ${VCPKG_CONCURRENCY} - error Waiting for unfinished jobs....
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        LOGNAME "make-build-${TARGET_TRIPLET}-dbg")
    vcpkg_execute_build_process(
        COMMAND ${BASH_EXECUTABLE} --noprofile --norc -c "${MOZMAKE_EXECUTABLE} install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        LOGNAME "make-install-${TARGET_TRIPLET}-dbg")
    message(STATUS "Package ${TARGET_TRIPLET}-dbg done")
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs() # automatic templates
configure_file(${SOURCE_PATH}/nspr/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
