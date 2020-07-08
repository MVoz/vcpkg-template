include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://icl.utk.edu/projectsfiles/magma/downloads/magma-2.5.3.tar.gz"
    FILENAME "magma-2.5.3.tar.gz"
    SHA512 0c12825a053f77cfba176a2e1dd4fdacc0bc6d8472252f5ce50861885beb8f7de8df695db3696280e754890bbf99a66804c73571c9cc861450fed00aa5f1ffeb
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_enable_fortran()
#set(VCPKG_FORTRAN_ENABLED ON)
#set(VCPKG_FORTRAN_TOOLSET_VERSION "19.10")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
#    DISABLE_PARALLEL_CONFIGURE
#    OPTIONS_DEBUG # automatic templates
#        -D =OFF
#    OPTIONS_RELEASE
#        -D =OFF
#    OPTIONS 
)

vcpkg_install_cmake()

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
configure_file(${SOURCE_PATH}/COPYRIGHT ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
