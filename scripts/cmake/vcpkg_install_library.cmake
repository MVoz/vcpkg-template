## # vcpkg_install_library
##
## Install a library from the build to the packages directory
##
## ## Usage:
## ```cmake
## vcpkg_install_library(
##     NAMES <NAMES>...
##     [RELATIVE_PATHS <RELATIVE_PATHS>...]
## )
## ```
##
## ## Parameters:
## ### NAMES (required)
## A list of possible names for the library.
##
## ### RELATIVE_PATHS
## A list of paths relative to the build directory where the library may be found.

function(vcpkg_install_library)
    cmake_parse_arguments(_vil "" "" "NAMES;RELATIVE_PATHS" ${ARGN})

    if(NOT DEFINED _vil_NAMES)
        message(FATAL_ERROR "NAMES must be specified.")
    endif()

    function(install_for_config CONFIG OUT_DIR_PREFIX)
        set(PATHS ${_vil_RELATIVE_PATHS} ".")
        list(TRANSFORM PATHS PREPEND "${CURRENT_BUILDTREES_DIR}/${CONFIG}/")

        function(install_in_directory DIR SILENT_ERROR)
            find_library(_LIB NAMES ${_vil_NAMES} PATHS ${PATHS} NO_DEFAULT_PATH)
            if("${_LIB}" MATCHES "-NOTFOUND")
                if(NOT SILENT_ERROR)
                    message(FATAL_ERROR "Library with NAMES: \"${_vil_NAMES}\" could not be found.")
                endif()
            else()
                file(INSTALL "${_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/${OUT_DIR_PREFIX}${DIR}")
            endif()
            unset(_LIB CACHE)
        endfunction()

        install_in_directory(lib FALSE)

        if(VCPKG_TARGET_IS_WINDOWS)
            # copy dlls and pdbs on Windows
            set(OLD_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
            
            set(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")
            install_in_directory(bin TRUE)

            set(CMAKE_FIND_LIBRARY_SUFFIXES ".pdb")
            install_in_directory(bin TRUE)

            set(CMAKE_FIND_LIBRARY_SUFFIXES ${OLD_CMAKE_FIND_LIBRARY_SUFFIXES})
        endif()
    endfunction()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        install_for_config(${TARGET_TRIPLET}-dbg "debug/")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        install_for_config(${TARGET_TRIPLET}-rel "")
    endif()
endfunction()
