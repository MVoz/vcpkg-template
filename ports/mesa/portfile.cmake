
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PATCHES meson.build.patch) 
    # this patch is not 100% correct since xcb and xcb-xkb can be build dynamically in a custom triplet
    # However, VCPKG currently is limited by the possibilities of meson and they have to fix their lib dependency detection
    list(APPEND MESA_OPTIONS -Dshared-llvm=false) # add llvm to CONTROL?
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/mesa
    REF  352037317b36c7ffd13aa3be8dc12e23a38a5bf2 #v19.3.3
    SHA512 9813c98b6b04186e510e16b76b29d0ec1be75bcc0eca758a115ab93c289c72d9103c69c8e4025f3c48d0350b7432aba42167b3768bbbc5877720c036681f1fec
    HEAD_REF master # branch name
    PATCHES ${PATCHES} #patch name
) 

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -D gles1=true 
        -D gles2=true 
        -D shared-glapi=true
        -D gles-lib-suffix=_mesa
        -D egl-lib-suffix=_mesa
        "${MESA_OPTIONS}"
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

#installed by egl-registry
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/KHR)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/EGL/egl.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/EGL/eglext.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/EGL/eglplatform.h)

#installed by opengl-registry
set(_double_files include/GL/glcorearb.h include/GL/glext.h include/GL/glxext.h 
    include/GLES/egl.h include/GLES/gl.h include/GLES/glext.h include/GLES/glplatform.h 
    include/GLES2/gl2.h include/GLES2/gl2ext.h include/GLES2/gl2platform.h
    include/GLES3/gl3.h  include/GLES3/gl31.h include/GLES3/gl32.h include/GLES3/gl3platform.h)
foreach(_file ${_double_files})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/${_file}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/${_file}")
    endif()
endforeach()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/GLES)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/GLES2)
# # Handle copyright
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")


