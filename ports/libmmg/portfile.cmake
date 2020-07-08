vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/MmgTools/mmg/archive/c14de9b6a01c2a32649838c8df099263eb56c4d8.zip"
    FILENAME "c14de9b6a01c2a32649838c8df099263eb56c4d8.zip"
    SHA512 156ab578b48b1c529d2592c8067d6b3227df07e5ae289ad9a670db00760ae17375e611306fc4f5499cc9ced5d7edbb24e4e892f7fbe3e4cc70ac43a1d2d576ce
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    NO_CHARSET_FLAG
    OPTIONS
      -DUSE_SCOTCH=OFF
      -DTEST_LIBMMG3D=OFF
      -DTEST_LIBMMG2D=OFF
      -DTEST_LIBMMGS=OFF
      -DTEST_LIBMMG=OFF
)

vcpkg_install_cmake()

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
#file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmmg RENAME copyright)

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/include)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
vcpkg_copy_pdbs()
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
