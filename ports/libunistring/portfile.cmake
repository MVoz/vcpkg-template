vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libunistring/libunistring-0.9.10.tar.gz"
    FILENAME "libunistring-0.9.10.tar.gz"
    SHA512 690082732fbbd47ab4ffbd6f21d85afece0f8e2ded24982f949f4ae52bf0a981b75ea9bc14ab289e0954cde07f31a7a4c2bb65615a8eb5b2bfa65720310b6fc9
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
#    PATCHES
#      001_libunistring_fixes.patch
#      001_libunistring_patch.patch
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    COPY_SOURCE
    OPTIONS_RELEASE
      --with-libiconv-prefix=${CURRENT_INSTALLED_DIR}
      --with-libpth-prefix=${CURRENT_INSTALLED_DIR}
    OPTIONS_DEBUG
      --with-libiconv-prefix=${CURRENT_INSTALLED_DIR}/debug
      --with-libpth-prefix=${CURRENT_INSTALLED_DIR}/debug
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
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
#file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libunistring RENAME copyright)

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/include)

#file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
#file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})

#vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openexr)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME libunistring)

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

# # Moves all .cmake files from /debug/share/libunistring/ to /share/libunistring/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/libunistring)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libunistring RENAME copyright)
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
