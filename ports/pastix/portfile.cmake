find_program(GIT NAMES git git.cmd)
set(GIT_URL "https://gitlab.inria.fr/solverstack/pastix")
set(GIT_REV master)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})
if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
      COMMAND ${GIT} clone --recurse-submodules -q --depth=20 --branch=${GIT_REV} ${GIT_URL} ${SOURCE_PATH}
#      COMMAND ${GIT} clone submodule sync --recursive -q --depth=20 --branch=${GIT_REV} ${GIT_URL} ${SOURCE_PATH}
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME clone
    )
    message(STATUS "Fetching submodules")
    vcpkg_execute_required_process(
      COMMAND ${GIT} submodule update --init --recursive
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME submodules
    )
endif()

#vcpkg_find_acquire_program(PYTHON2)
#vcpkg_find_acquire_program(QT5)
#vcpkg_find_acquire_program(TEXLIVE)
#vcpkg_find_acquire_program(XGETTEXT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    NO_CHARSET_FLAG # automatic templates
#    GENERATOR "NMake Makefiles" # automatic templates
#    DISABLE_PARALLEL_CONFIGURE

#      -D =OFF
    OPTIONS 
      -DBUILD_SHARED_LIBS=ON# Enable the shared libraries build. This option needs to be enabled for the Python wrapper.
      -DPASTIX_INT64=ON# Enable/disable int64_t for integer arrays.
      -DPASTIX_ORDERING_SCOTCH=OFF# Enable/Disable the support of the Scotch library to compute the ordering.
      -DPASTIX_ORDERING_METIS=OFF# Enable/Disable the support of the Metis library to compute the ordering. Metis 5.1 is required.
      -DPASTIX_WITH_PARSEC=OFF# Enable/disable the PaRSEC runtime support. Require to install PaRSEC tag pastix-releasenumber (mymaster for master branch) from the repository https://bitbucket.org/mfaverge/parsec that includes a few patches on top of the original PaRSEC runtime system. PaRSEC needs to be compiled with option 
#      -DPARSEC_WITH_DEVEL_HEADERS=ON
      -DPASTIX_WITH_STARPU=OFF# Enable/disable the StarPU runtime support. Require to install StarPU 1.3.
      -DPASTIX_WITH_MPI=ON# Enable/disable distributed memory support (See above for details). If used with the PaRSEC library, MPI should be enabled or disabled in both libraries.*
      -DPASTIX_WITH_EXTERNAL_SPM=OFF# Enable/disable the use of an external SpM library in favor of the internal one.
      -DBUILD_DOCUMENTATION=OFF#] to enable the Doxygen documentation generation.
      -DPASTIX_WITH_CUDA=OFF
      -DPASTIX_WITH_EZTRACE=OFF
      -DPASTIX_WITH_FORTRAN=OFF
      -DPASTIX_WITH_MPI=OFF
      -DPASTIX_WITH_PARSEC=OFF
      -DPASTIX_WITH_STARPU=OFF
#      -DPKG_CONFIG_EXECUTABLE:FILEPATH=E:/tools/vcpkg/installed/x64-windows/debug/bin/pkg-config.exe
#      -DPYTHON_EXECUTABLE:FILEPATH=E:/tools/python/python3/python3.7.exe
)

vcpkg_install_cmake()

#vcpkg_install_cmake(DISABLE_PARALLEL)

#vcpkg_fixup_cmake_targets()

### https://mesonbuild.com/Configuring-a-build-directory.html
#vcpkg_configure_meson(
#    SOURCE_PATH ${SOURCE_PATH}
#    OPTIONS
#      --backend=ninja
#)

#vcpkg_install_meson()

###
#msbuild build-package.proj /t:Clean;BeforeBuild
#msbuild build.proj /t:Build
#msbuild build-package.proj /t:PreparePackage;Package

#vcpkg_install_msbuild(
#    SOURCE_PATH ${SOURCE_PATH}
#    PROJECT_SUBPATH "ide/vs2017/mimalloc.vcxproj"
#    TARGET restore
#    SKIP_CLEAN
#    RELEASE_CONFIGURATION Release_x86${MPG123_CONFIGURATION_SUFFIX}
#    DEBUG_CONFIGURATION Debug_x86${MPG123_CONFIGURATION_SUFFIX}
#    LICENSE_SUBPATH LICENSE
#    INCLUDES_SUBPATH hidapi ALLOW_ROOT_INCLUDES
#    ALLOW_ROOT_INCLUDES ON
#    USE_VCPKG_INTEGRATION
#)

#file(GLOB_RECURSE TMP_FILES "${SOURCE_PATH}/include/*.hin" "${SOURCE_PATH}/include/*.orig" "${SOURCE_PATH}/include/*.in")
#file(REMOVE_RECURSE ${TMP_FILES})

#remove_srcs_file("${SOURCE_PATH}/include/*.hin" "${SOURCE_PATH}/include/*.orig" "${SOURCE_PATH}/include/*.in")

#file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug*" DESTINATION ${SOURCE_PATH_TCL}/win)
#file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PGSQL_INCLUDE_DIR)


#file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include)
#file(RENAME ${CURRENT_PACKAGES_DIR}/include/include ${CURRENT_PACKAGES_DIR}/include/openldap)

#file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin FILES_MATCHING PATTERN "*.dll")
#file(COPY ${SOURCE_PATH}/greatest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

#vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/${PORT}")
#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nlohmann_json TARGET_PATH share/nlohmann_json)
#file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
#file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${LIB_NAME}.dll ${CURRENT_PACKAGES_DIR}/bin/${LIB_NAME}.dll
#file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pastix RENAME copyright)

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/include)

#file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
#file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})

#vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openexr)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME pastix)

#install(
#    TARGETS ${PROJECT} 
#    EXPORT ${PROJECT}-export
#    RUNTIME DESTINATION ${BINARY_INSTALL_DIR}
#    LIBRARY DESTINATION ${LIBRARY_INSTALL_DIR}
#    ARCHIVE DESTINATION ${LIBRARY_INSTALL_DIR}
#    BUNDLE DESTINATION .
##    FRAMEWORK DESTINATION ${FRAMEWORK_INSTALL_DIR}
##    PUBLIC_HEADER DESTINATION ${INCLUDE_INSTALL_DIR}/qjson${QJSON_SUFFIX}
#)

# # Moves all .cmake files from /debug/share/pastix/ to /share/pastix/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/pastix)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pastix RENAME copyright)
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
