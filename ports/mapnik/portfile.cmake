vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

find_program(GIT NAMES git git.cmd)
set(GIT_URL "https://github.com/mapnik/mapnik")
set(GIT_REV boost_1_71)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})
if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
      COMMAND ${GIT} clone --recurse-submodules -q --depth=20 --branch=${GIT_REV} ${GIT_URL} ${SOURCE_PATH}
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME clone
    )
    message(STATUS "Fetching submodules")
    vcpkg_execute_required_process(
      COMMAND ${GIT} submodule update --init --remote --recursive
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME submodules
    )
endif()

vcpkg_find_acquire_program(PYTHON2)
#vcpkg_find_acquire_program(QT5)
#vcpkg_find_acquire_program(TEXLIVE)
#vcpkg_find_acquire_program(XGETTEXT)
#vcpkg_find_acquire_program(DOXYGEN)
#vcpkg_find_acquire_program(DOXYGEN)
#vcpkg_find_acquire_program(PERL)
#vcpkg_find_acquire_program(FLEX)
#vcpkg_find_acquire_program(BISON)
#get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
#get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
#get_filename_component(DOXYGEN_DIR "${DOXYGEN}" DIRECTORY)
#get_filename_component(PERL_DIR "${PERL}" DIRECTORY)
#get_filename_component(QT5_DIR "${QT5}" DIRECTORY)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
#get_filename_component(DOXYGEN_DIR "${DOXYGEN}" DIRECTORY)
#get_filename_component(XGETTEXT_DIR "${XGETTEXT}" DIRECTORY)
#get_filename_component(TEXLIVE_DIR "${TEXLIVE}" DIRECTORY)
#set(ENV{PATH} ";$ENV{PATH};${QT5_DIR};${PYTHON3_DIR};${DOXYGEN_DIR};${XGETTEXT_DIR};${TEXLIVE_DIR};${FLEX_DIR};${BISON_DIR};${DOXYGEN_DIR};${PERL_DIR}")
#vcpkg_find_acquire_program(YASM)
#get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON2_DIR}")

#get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
#set(SH_EXE_PATH "${GIT_EXE_PATH}/../usr/bin")
#set(ENV{PATH} "$ENV{PATH};${VALAC_DIR};${BISON_DIR};${FLEX_DIR};${SH_EXE_PATH}")

set(BOOST_ROOT ${CURRENT_INSTALLED_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja

    OPTIONS 
      -DWITH_CAIRO=OFF
      -DWITH_DEMO=OFF
      -DWITH_GRID=OFF
      -DWITH_INPUTS=OFF
      -DWITH_INPUT_CSV=ON
      -DWITH_INPUT_GDAL=OFF
      -DWITH_INPUT_GEOBUF=OFF
      -DWITH_INPUT_GEOJSON=ON
      -DWITH_INPUT_OGR=ON
      -DWITH_INPUT_PGRASTER=OFF
      -DWITH_INPUT_POSTGIS=OFF
      -DWITH_INPUT_RASTER=ON
      -DWITH_INPUT_SHAPE=ON
      -DWITH_INPUT_SQLITE=ON
      -DWITH_INPUT_TOPOJSON=ON
      -DWITH_PROJ4=ON
	  -DSVG_RENDERER=OFF
	  -DWITH_SVG=OFF
      -DWITH_UTILS=OFF
      -DWITH_VIEWER=OFF
      -DMAPNIK_STATIC_LIB=OFF
	  -DBOOST_PREFIX=${CURRENT_INSTALLED_DIR}/include
	  -DFREE_TYPE_INCLUDE=${CURRENT_INSTALLED_DIR}/include/freetype2
)

vcpkg_install_cmake()

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
