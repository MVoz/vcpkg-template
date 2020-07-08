include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://gitlab.gnome.org/GNOME/gobject-introspection/-/archive/1.64.0/gobject-introspection-1.64.0.zip"
    FILENAME "gobject-introspection-1.64.0.zip"
    SHA512 b84398a73e594a8b846dbd2a863feddff2007fba3c7fd073dd4a961b10ca30d5d23a26ddcaaf227f83cf49f65b9eb20fee806e22348610dfc14916bb74269dfd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(DOXYGEN)
vcpkg_find_acquire_program(PYTHON3)

get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
get_filename_component(DOXYGEN_DIR "${DOXYGEN}" DIRECTORY)

set(ENV{PATH} ";$ENV{PATH};${FLEX_DIR};${BISON_DIR};${DOXYGEN_DIR};${PYTHON3_DIR}")


get_cmake_property(CACHE_VARS CACHE_VARIABLES)
foreach(CACHE_VAR ${CACHE_VARS})
  get_property(CACHE_VAR_HELPSTRING CACHE ${CACHE_VAR} PROPERTY HELPSTRING)
  if(CACHE_VAR_HELPSTRING STREQUAL "No help, variable specified on the command line.")
    get_property(CACHE_VAR_TYPE CACHE ${CACHE_VAR} PROPERTY TYPE)
    if(CACHE_VAR_TYPE STREQUAL "UNINITIALIZED")
      set(CACHE_VAR_TYPE)
    else()
      set(CACHE_VAR_TYPE :${CACHE_VAR_TYPE})
    endif()
    set(CMAKE_ARGS "${CMAKE_ARGS} -D${CACHE_VAR}${CACHE_VAR_TYPE}=\"${${CACHE_VAR}}\"")
  endif()
endforeach()
message("CMAKE_ARGS: ${CMAKE_ARGS}")
message(STATUS "User Specified CMake Arguments: ${CMAKE_ARGS}")

#find_program(PYTHON3_REL NAMES python HINTS "${CURRENT_INSTALLED_DIR}/python3")
#find_program(PYTHON3_DBG NAMES python_d HINTS "${CURRENT_INSTALLED_DIR}/debug/python3")


# не работает с debug lib python error #unresolved external symbol __imp_PyModule_Create2

# https://mesonbuild.com/Configuring-a-build-directory.html
vcpkg_configure_meson(
	SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
		--backend=ninja
#		-Dcairo_libname=cairo-gobject-2.dll
		-Dcairo_libname=cairo-gobject.dll
#		-Dpython=${PYTHON3}
		-Dgtk_doc=false
		-Ddoctool=disabled
#	OPTIONS_RELEASE
		-Dpython=${PYTHON3}
#	OPTIONS_DEBUG
#		-Dpython=${PYTHON3_DBG}
)
vcpkg_install_meson()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gobject-introspection RENAME copyright)

set(VCPKG_POLICY_* enabled)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)
