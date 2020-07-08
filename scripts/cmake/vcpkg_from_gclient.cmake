## # vcpkg_from_gclient
##
## Download and extract a project with gclient
##
## ## Usage:
## ```cmake
## vcpkg_from_gclient(
##     OUT_SOURCE_PATH <SOURCE_PATH>
##     URL <https://android.googlesource.com/platform/external/fdlibm>
##     REF <59f7335e4d...>
##     NAME <name>
## )
## ```
##
## ## Parameters:
## ### OUT_SOURCE_PATH (required)
## Specifies the out-variable that will contain the gclient root location.
##
## ### URL (required)
## The url of the git repository.
##
## ### REF (required)
## The git sha of the commit to download.
##
## ### NAME (required)
## The name of the project

function(vcpkg_from_gclient)
    cmake_parse_arguments(_vfgc "" "OUT_SOURCE_PATH;URL;REF;NAME" "" ${ARGN})

    if(NOT DEFINED _vfgc_OUT_SOURCE_PATH)
        message(FATAL_ERROR "OUT_SOURCE_PATH must be specified.")
    endif()

    if(NOT DEFINED _vfgc_URL)
        message(FATAL_ERROR "URL must be specified")
    endif()

    if(NOT DEFINED _vfgc_REF)
        message(FATAL_ERROR "REF must be specified.")
    endif()

    if(NOT DEFINED _vfgc_NAME)
        message(FATAL_ERROR "NAME must be specified.")
    endif()

    set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/${REF}")
    file(MAKE_DIRECTORY "${SOURCE_PATH}")

    set(GCLIENT_CONFIG [==[
solutions = [
  {
    "url": "@_vfgc_URL@@@_vfgc_REF@",
    "managed": False,
    "name": "@_vfgc_NAME@"
  }
]
    ]==])

    string(CONFIGURE "${GCLIENT_CONFIG}" GCLIENT_CONFIG @ONLY)
    file(WRITE "${SOURCE_PATH}/.gclient" "${GCLIENT_CONFIG}")

    vcpkg_acquire_depot_tools(TOOLS GCLIENT)

    message(STATUS "Syncing sources and dependencies...")
    vcpkg_execute_required_process(
        COMMAND "${GCLIENT}" sync --no-history --shallow
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME gclient-sync-${TARGET_TRIPLET}
    )

    set(${_vfgc_OUT_SOURCE_PATH} "${SOURCE_PATH}" PARENT_SCOPE)
endfunction()