#TODO: Features to add:
# USE_XBLAS??? extended precision blas. needs xblas
# LAPACKE should be its own PORT
# USE_OPTIMIZED_LAPACK (Probably not what we want. Does a find_package(LAPACK): probably for LAPACKE only builds _> own port?)
# LAPACKE Builds LAPACKE
# LAPACKE_WITH_TMG Build LAPACKE with tmglib routines

SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(CMAKE_HOST_WIN32 AND NOT VCPKG_USE_EXTERNAL_Fortran)
    # Since we use MinGW Fortran here and would require ld otherwise for all dependent ports
    set(VCPKG_CRT_LINKAGE dynamic) # Will always be dynamic no way to overwrite internal CRT linkage here
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
    #set(VCPKG_CRT_LINKAGE dynamic)
endif()

set(lapack_ver 3.8.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  "Reference-LAPACK/lapack"
    REF "v${lapack_ver}"
    SHA512 17786cb7306fccdc9b4a242de7f64fc261ebe6a10b6ec55f519deb4cb673cb137e8742aa5698fd2dc52f1cd56d3bd116af3f593a01dcf6770c4dcc86c50b2a7f
    HEAD_REF master
)

set(USE_OPTIMIZED_BLAS OFF)
if("noblas" IN_LIST FEATURES)
    set(USE_OPTIMIZED_BLAS ON)
endif()

set(CBLAS OFF)
if("cblas" IN_LIST FEATURES)
    set(CBLAS ON)
endif()

vcpkg_configure_cmake(
        PREFER_NINJA
        ENABLE_Fortran
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            "-DUSE_OPTIMIZED_BLAS=${USE_OPTIMIZED_BLAS}"
            "-DCBLAS=${CBLAS}"
        )

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/lapack-${lapack_ver}) #Should the target path be lapack and not lapack-reference?
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# remove debug includs
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_TARGET_IS_WINDOWS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/liblapack.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/liblapack.lib" "${CURRENT_PACKAGES_DIR}/lib/lapack.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/liblapack.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/liblapack.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/lapack.lib")
    endif()
endif()

#SET(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled)