#vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
#vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/OpenCMISS-Dependencies/scotch/archive/f6237a1ab8c10e35dcfe71f47f0f12f7f111c68b.zip"
    FILENAME "scotch.zip"
    SHA512 36fb5a7da8f252334891a066c373ef921f3cdd874fa62f1559522d03d9faccdcba8b92e7b4a1593e8a536cceb0037cbd5997525a57e638a7bc4b853534f6ea3e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    NO_CHARSET_FLAG
    OPTIONS
      -DBUILD_TESTS=OFF
      -DUSE_THREADS=OFF
      -DFLEX_EXECUTABLE=${FLEX}
      -DBISON_EXECUTABLE=${BISON}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/${PORT})

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
vcpkg_copy_pdbs()
configure_file(${SOURCE_PATH}/LICENSE_en.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
