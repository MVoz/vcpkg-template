## # vcpkg_install_tool
##
## Install a tool from the build to the packages directory
##
## ## Usage:
## ```cmake
## vcpkg_install_tool(
##     NAMES <NAMES>...
##     [RELATIVE_PATHS <RELATIVE_PATHS>...]
## )
## ```
##
## ## Parameters:
## ### NAMES (required)
## A list of possible names for the tool.
##
## ### RELATIVE_PATHS
## A list of paths relative to the build directory where the tool may be found.

function(vcpkg_install_tool)
    cmake_parse_arguments(_vit "" "" "NAMES;RELATIVE_PATHS" ${ARGN})

    if(NOT DEFINED _vit_NAMES)
        message(FATAL_ERROR "NAMES must be specified.")
    endif()

    function(install_for_config CONFIG OUT_DIR_PREFIX)
        set(PATHS ${_vit_RELATIVE_PATHS} ".")
        list(TRANSFORM PATHS PREPEND "${CURRENT_BUILDTREES_DIR}/${CONFIG}/")

        find_program(_TOOL NAMES ${_vit_NAMES} PATHS ${PATHS} NO_DEFAULT_PATH)

        if("${_TOOL}" MATCHES "-NOTFOUND")
            message(FATAL_ERROR "Tool with NAMES: \"${_vil_NAMES}\" could not be found.")
        endif()
            
        file(INSTALL "${_TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/${OUT_DIR_PREFIX}tools")
        unset(_TOOL CACHE)
    endfunction()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        install_for_config(${TARGET_TRIPLET}-dbg "debug/")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        install_for_config(${TARGET_TRIPLET}-rel "")
    endif()
endfunction()
