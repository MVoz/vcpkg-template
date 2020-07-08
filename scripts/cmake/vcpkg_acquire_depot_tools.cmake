## # vcpkg_acquire_depot_tools
##
## Download or find `depot_tools`
##
## ## Usage
## ```cmake
## vcpkg_acquire_depot_tools(
##   [OUT_ROOT_PATH <ROOT_PATH>]
##   [TOOLS <tool>...]
## )
## ```
##
## ## Parameters
## ### OUT_ROOT_PATH
## An out-variable that will be set to the path to `depot_tools`.
##
## ### TOOLS
## A list of tools to acquire in `depot_tools`.
## Available tools: `GCLIENT`, `GN`
##
## ## Notes:
## The path to `depot_tools` will be prepended to the PATH environment variable.

function(vcpkg_acquire_depot_tools)
  cmake_parse_arguments(_adt "" "OUT_ROOT_PATH" "TOOLS" ${ARGN})

  # find python before modifying the path
  vcpkg_find_acquire_program(PYTHON2)

  if(NOT DEFINED CACHE{DEPOT_TOOLS_DIR})
    set(REF "464e9ff4f3682426b0cb3b68ee38e7be6fa4a2be")
    set(URL "https://chromium.googlesource.com/chromium/tools/depot_tools.git")

    vcpkg_from_git(
      OUT_SOURCE_PATH SOURCE_PATH
      URL ${URL}
      REF ${REF}
      NAME "depot_tools"
      TARGET_DIRECTORY "${DOWNLOADS}/tools/depot_tools"
    )

    # avoid polluting the path env by using the cache
    set(DEPOT_TOOLS_DIR "${SOURCE_PATH}" CACHE INTERNAL "")

    # Disable depot_tools' auto update
    set(ENV{DEPOT_TOOLS_UPDATE} 0)

    if(CMAKE_HOST_WIN32)
      # Workaround for skipping depot_tools' bootstrap on Windows
      if(NOT EXISTS "$CACHE{DEPOT_TOOLS_DIR}/python.bat")
        file(WRITE "$CACHE{DEPOT_TOOLS_DIR}/python.bat" "@echo off\npython %*")
      endif()
      if(NOT EXISTS "$CACHE{DEPOT_TOOLS_DIR}/git.bat")
        file(WRITE "$CACHE{DEPOT_TOOLS_DIR}/git.bat" "@echo off\ngit %*")
      endif()
    endif()

    vcpkg_add_to_path(PREPEND "$CACHE{DEPOT_TOOLS_DIR}")

    # Python and git are required by depot_tools
    get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${PYTHON2_DIR}")

    vcpkg_find_acquire_program(GIT)
    get_filename_component(GIT_DIR "${GIT}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${GIT_DIR}")

    if(CMAKE_HOST_WIN32)
      # Workaround for long paths on Windows
      # https://github.com/msysgit/msysgit/wiki/Git-cannot-create-a-file-or-directory-with-a-long-path
      _execute_process(COMMAND "${GIT}" config --system core.longpaths true)
    endif()
  endif()

  foreach(TOOL ${_adt_TOOLS})
    if(TOOL STREQUAL "GCLIENT")
      set(TOOL_OUT "${PYTHON2}" "$CACHE{DEPOT_TOOLS_DIR}/gclient.py")
    elseif(TOOL STREQUAL "GN")
      set(TOOL_OUT "${PYTHON2}" "$CACHE{DEPOT_TOOLS_DIR}/gn.py")
    else()
      message(FATAL_ERROR "Could not find tool '${TOOL}'.")
    endif()

    set(${TOOL} "${TOOL_OUT}" PARENT_SCOPE)
  endforeach()

  if(DEFINED _adt_OUT_ROOT_PATH)
    set(${_adt_OUT_ROOT_PATH} "$CACHE{DEPOT_TOOLS_DIR}" PARENT_SCOPE)
  endif()

endfunction()
