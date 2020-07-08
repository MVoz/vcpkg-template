#TODO: Features to add:
# USE_XBLAS??? extended precision blas. needs xblas
# LAPACKE should be its own PORT
# USE_OPTIMIZED_LAPACK (Probably not what we want. Does a find_package(LAPACK): probably for LAPACKE only builds _> own port?)
# LAPACKE Builds LAPACKE
# LAPACKE_WITH_TMG Build LAPACKE with tmglib routines

SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_configure_cmake(
        PREFER_NINJA
        #ENABLE_FORTRAN
        SOURCE_PATH ${CURRENT_PORT_DIR}
        )

vcpkg_install_cmake()
#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/lapack-${lapack_ver}) #Should the target path be lapack and not lapack-reference?
#vcpkg_fixup_pkgconfig()
#vcpkg_copy_pdbs()

# Handle copyright
#file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# remove debug includs
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)