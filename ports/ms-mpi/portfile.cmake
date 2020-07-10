find_program(GIT NAMES git git.cmd)
set(GIT_URL "https://github.com/microsoft/Microsoft-MPI")
set(GIT_REV master)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})
if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
      COMMAND ${GIT} clone --recurse-submodules -q --depth=1 --branch=${GIT_REV} ${GIT_URL} ${SOURCE_PATH}
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

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES patch.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/packages.config DESTINATION ${SOURCE_PATH}/.build/Local/CBTModules)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES mingw-w64-x86_64-gcc-libgfortran mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-gcc-objc mingw-w64-x86_64-gcc-ada)
vcpkg_add_to_path("${MSYS_ROOT}/mingw64/bin")

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

set(VS_PLATFORM_TOOLSET "WindowsDriverKit")

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_PATH ${SOURCE_PATH}/dirs.proj
#    PROJECT_SUBPATH "ide/vs2017/mimalloc.vcxproj"
#    TARGET Restore
#    SKIP_CLEAN
    OPTIONS 
      "/p:PlatformToolset=WindowsUserModeDriver10.0"
      "/p:VCToolsVersion=$ENV{VCToolsVersion}"
      "/p:GFORTRAN_BIN=${MSYS_ROOT}/mingw64/bin"
#      /p:RestoreRecursive=true
#      /p:TargetFramework=net472
#      /t:RestoreModules
      /p:UseEnv=True
    USE_VCPKG_INTEGRATION
    INCLUDES_SUBPATH src/include
    ALLOW_ROOT_INCLUDES ON
    LICENSE_SUBPATH LICENSE.txt
)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-mpi RENAME copyright)
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
