## # vcpkg_configure_make
##
## Configure configure for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_make(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [AUTOCONFIG]
##     [NO_DEBUG]
##     [SKIP_CONFIGURE]
##     [PROJECT_SUBPATH <${PROJ_SUBPATH}>]
##     [PRERUN_SHELL <${SHELL_PATH}>]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `configure`/`configure.ac`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### PROJECT_SUBPATH
## Specifies the directory containing the ``configure`/`configure.ac`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### SKIP_CONFIGURE
## Skip configure process
##
## ### AUTOCONFIG
## Need to use autoconfig to generate configure file.
##
## ### PRERUN_SHELL
## Script that needs to be called before configuration (do not use for batch files which simply call autoconf or configure)
##
## ### OPTIONS
## Additional options passed to configure during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to configure during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to configure during the Debug configuration. These are in addition to `OPTIONS`.
##
## ## Notes
## This command supplies many common arguments to configure. To see the full list, examine the source.
##
## ## Examples
##
## * [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
## * [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
## * [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
## * [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
macro(_vcpkg_determine_host_mingw out_var)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(HOST_ARCH MATCHES "(amd|AMD)64")
        set(${out_var} mingw64)
    elseif(HOST_ARCH MATCHES "(x|X)86")
        set(${out_var} mingw32)
    else()
        message(FATAL_ERROR "Unsupported mingw architecture ${HOST_ARCH} in _vcpkg_determine_autotools_host_cpu!" )
    endif()
    unset(HOST_ARCH)
endmacro()

macro(_vcpkg_determine_autotools_host_cpu out_var)
    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(HOST_ARCH $ENV{PROCESSOR_ARCHITECTURE})
    endif()
    if(HOST_ARCH MATCHES "(amd|AMD)64")
        set(${out_var} x86_64)
    elseif(HOST_ARCH MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(HOST_ARCH MATCHES "^(ARM|arm)64$")
        set(${out_var} armv8)
    elseif(HOST_ARCH MATCHES "^(ARM|arm)$")
        set(${out_var} armv7)
    else()
        message(FATAL_ERROR "Unsupported host architecture ${HOST_ARCH} in _vcpkg_determine_autotools_host_cpu!" )
    endif()
    unset(HOST_ARCH)
endmacro()

macro(_vcpkg_determine_autotools_target_cpu out_var)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)64")
        set(${out_var} x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)86")
        set(${out_var} i686)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)64$")
        set(${out_var} armv8)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)$")
        set(${out_var} armv7)
    else()
        message(FATAL_ERROR "Unsupported VCPKG_TARGET_ARCHITECTURE architecture ${VCPKG_TARGET_ARCHITECTURE} in _vcpkg_determine_autotools_target_cpu!" )
    endif()
endmacro()

macro(_vcpkg_backup_env_variable envvar)
    if(DEFINED ENV{${envvar}})
        set(${envvar}_BACKUP "$ENV{${envvar}}")
        set(${envvar}_PATHLIKE_CONCAT "${VCPKG_HOST_PATH_SEPARATOR}$ENV{${envvar}}")
    else()
        set(${envvar}_PATHLIKE_CONCAT)
    endif()
endmacro()

macro(_vcpkg_restore_env_variable envvar)
    if(${envvar}_BACKUP)
        set(ENV{${envvar}} ${${envvar}_BACKUP})
    else()
        unset(ENV{${envvar}})
    endif()
endmacro()

function(vcpkg_configure_make)
    cmake_parse_arguments(_csc
        "AUTOCONFIG;SKIP_CONFIGURE;COPY_SOURCE;USE_MINGW_MAKE;DISABLE_VERBOSE_FLAGS;NO_ADDITIONAL_PATHS"
        "SOURCE_PATH;PROJECT_SUBPATH;PRERUN_SHELL;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
        ${ARGN}
    )
    if(DEFINED VCPKG_MAKE_BUILD_TRIPLET)
        set(_csc_BUILD_TRIPLET ${VCPKG_MAKE_BUILD_TRIPLET}) # Triplet overwrite for crosscompiling
    endif()

    set(SRC_DIR "${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}")

    set(REQUIRES_AUTOGEN FALSE) # use autogen.sh
    set(REQUIRES_AUTOCONFIG FALSE) # use autotools and configure.ac
    if(EXISTS "${SRC_DIR}/configure" AND "${SRC_DIR}/configure.ac") # remove configure; rerun autoconf
        if(NOT VCPKG_MAINTAINER_SKIP_AUTOCONFIG) # If fixing bugs skipping autoconfig saves a lot of time
            set(REQUIRES_AUTOCONFIG TRUE)
            file(REMOVE "${SRC_DIR}/configure") # remove possible autodated configure scripts
            set(_csc_AUTOCONFIG ON)
        endif()
    elseif(EXISTS "${SRC_DIR}/configure" AND NOT _csc_SKIP_CONFIGURE) # run normally; no autoconf or autgen required
    elseif(EXISTS "${SRC_DIR}/configure.ac") # Run autoconfig
        set(REQUIRES_AUTOCONFIG TRUE)
        set(_csc_AUTOCONFIG ON)
    elseif(EXISTS "${SRC_DIR}/autogen.sh") # Run autogen
        set(REQUIRES_AUTOGEN TRUE)
    else()
        message(FATAL_ERROR "Don't know what to do!")
    endif()
    
    debug_message("REQUIRES_AUTOGEN:${REQUIRES_AUTOGEN}")
    debug_message("REQUIRES_AUTOCONFIG:${REQUIRES_AUTOCONFIG}")
    # Backup environment variables
    # CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJCXX R UPC Y 
    set(FLAGPREFIXES CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R UPC Y)
    foreach(_prefix IN LISTS FLAGPREFIXES)
        if(DEFINED $ENV{${prefix}FLAGS})
            set(${_prefix}_FLAGS_BACKUP "$ENV{${prefix}FLAGS}")
        else()
            set(${_prefix}_FLAGS_BACKUP)
        endif()
    endforeach()

    # FC fotran compiler | FF Fortran 77 compiler 
    # LDFLAGS -> pass -L flags
    # LIBS -> pass -l flags

    set(INCLUDE_PATH_BACKUP "$ENV{INCLUDE_PATH}")
    set(INCLUDE_BACKUP "$ENV{INCLUDE}")
    set(C_INCLUDE_PATH_BACKUP "$ENV{C_INCLUDE_PATH}")
    set(CPLUS_INCLUDE_PATH_BACKUP "$ENV{CPLUS_INCLUDE_PATH}")
    #set(LD_LIBRARY_PATH_BACKUP "$ENV{LD_LIBRARY_PATH}")
    _vcpkg_backup_env_variable(LD_LIBRARY_PATH) 
    #set(LIBRARY_PATH_BACKUP "$ENV{LIBRARY_PATH}")
    _vcpkg_backup_env_variable(LIBRARY_PATH)
    set(LIBPATH_BACKUP "$ENV{LIBPATH}")

    if(${CURRENT_PACKAGES_DIR} MATCHES " " OR ${CURRENT_INSTALLED_DIR} MATCHES " ")
        # Don't bother with whitespace. The tools will probably fail and I tried very hard trying to make it work (no success so far)!
        message(WARNING "Detected whitespace in root directory. Please move the path to one without whitespaces! The required tools do not handle whitespaces correctly and the build will most likely fail")
    endif()

    if(CMAKE_HOST_WIN32)
        set(_SEP ";")
    else()
        set(_SEP ":")
    endif()

    function(sleep delay)
	  execute_process(
	    COMMAND ${CMAKE_COMMAND} -E sleep ${delay}
	    RESULT_VARIABLE result
	    )
	  if(NOT result EQUAL 0)
	    message(FATAL_ERROR "failed to sleep for ${delay} second.") #sleep(1) - 1 sec. #sleep(0.300) - 300 mlsec
	  endif()
    endfunction(sleep)

    # Pre-processing windows configure requirements
    if (CMAKE_HOST_WIN32)
        _vcpkg_determine_autotools_host_cpu(BUILD_ARCH) # VCPKG_HOST => machine you are building on => --build=

        list(APPEND MSYS_REQUIRE_PACKAGES diffutils 
                                          pkg-config 
                                          binutils 
                                          libtool 
                                          libedit
                                          automake-wrapper
                                          autoconf-archive
                                          autoconf2.13
                                          texinfo-tex
                                          texinfo
                                          gettext 
                                          gettext-devel
                                          make
             )
        if(_csc_USE_MINGW_MAKE) # untested
            list(APPEND MSYS_REQUIRE_PACKAGES mingw-w64-${BUILD_ARCH}-make) 
            list(APPEND MSYS_REQUIRE_PACKAGES mingw-w64-${BUILD_ARCH}-pkg-config)
            _vcpkg_determine_host_mingw(HOST_MINGW)
        else()
            list(APPEND MSYS_REQUIRE_PACKAGES make)
        endif()
        if (_csc_AUTOCONFIG)
            list(APPEND MSYS_REQUIRE_PACKAGES autoconf
                                              autoconf-archive
                                              automake
                                              m4
					      libtool
					      perl
                )
            # --build: the machine you are building on
            # --host: the machine you are building for
            # --target: the machine that CC will produce binaries for
            # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
            if(NOT _csc_BUILD_TRIPLET)
                set(_csc_BUILD_TRIPLET "--build=${BUILD_ARCH}-pc-mingw32")  # This is required since we are running in a msys
                                                                            # shell which will be otherwise identified as ${BUILD_ARCH}-pc-msys
                _vcpkg_determine_autotools_target_cpu(TARGET_ARCH)
                if(NOT TARGET_ARCH MATCHES "${BUILD_ARCH}") # we do not need to specify the additional flags if we build nativly. 
                    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
                        string(APPEND _csc_BUILD_TRIPLET " --target=i686-pc-mingw32 --host=i686-pc-mingw32")
                    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
                        string(APPEND _csc_BUILD_TRIPLET " --target=x86_64-pc-mingw32 --host=x86_64-pc-mingw32")
                    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
                        string(APPEND _csc_BUILD_TRIPLET " --target=arm-pc-mingw32 --host=i686-pc-mingw32") # This is probably wrong
                        # There is no crosscompiler for ARM-Windows in msys.
                    endif()
                endif()
            endif()
        endif()
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${MSYS_REQUIRE_PACKAGES})
        if(_csc_USE_MINGW_MAKE)
            vcpkg_add_to_path("${MSYS_ROOT}/${HOST_MINGW}/bin")
        endif()
        vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
        set(BASH "${MSYS_ROOT}/usr/bin/bash.exe")

        # This is required because PATH contains sort and find from Windows but the MSYS versions are needed
        # ${MSYS_ROOT}/urs/bin cannot be prepended to PATH due to other conflicts
        file(CREATE_LINK "${MSYS_ROOT}/usr/bin/sort.exe" "${SCRIPTS}/buildsystems/make_wrapper/sort.exe" COPY_ON_ERROR)
        file(CREATE_LINK "${MSYS_ROOT}/usr/bin/find.exe" "${SCRIPTS}/buildsystems/make_wrapper/find.exe" COPY_ON_ERROR)
        vcpkg_add_to_path(PREPEND "${SCRIPTS}/buildsystems/make_wrapper") # Other required wrappers are also located there
#        vcpkg_add_to_path(PREPEND "${CONFIG_AUX_DIR}")
#        vcpkg_add_to_path(PREPEND "${AC_AUX_DIR}")
        
        # --build: the machine you are building on
        # --host: the machine you are building for
        # --target: the machine that CC will produce binaries for

        macro(_vcpkg_append_to_configure_environment inoutstring var defaultval)
            # Allows to overwrite settings in custom triplets via the environment
            if(DEFINED ENV{${var}})
                string(APPEND ${inoutstring} " ${var}='$ENV{${var}}'")
            else()
                string(APPEND ${inoutstring} " ${var}='${defaultval}'")
            endif()
        endmacro()

        set(CONFIGURE_ENV "")
        if (_csc_AUTOCONFIG) # without autotools we assume a custom configure script which correctly handles cl and lib. Otherwise the port needs to set CC|CXX|AR and probably CPP
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CPP "${MSYS_ROOT}/usr/share/automake-1.16/compile cl.exe -nologo -E")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CC "${MSYS_ROOT}/usr/share/automake-1.16/compile cl.exe -nologo")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CXX "${MSYS_ROOT}/usr/share/automake-1.16/compile cl.exe -nologo")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV AR "${MSYS_ROOT}/usr/share/automake-1.16/ar-lib lib.exe -verbose")
        else()
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CPP "cl.exe -nologo -E")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CC "cl.exe -nologo")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV CXX "cl.exe -nologo")
            _vcpkg_append_to_configure_environment(CONFIGURE_ENV AR "lib.exe -verbose")
        endif()
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV LD "link.exe -verbose")
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV RANLIB ":") # Trick to ignore the RANLIB call
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV CCAS ":")   # If required set the ENV variable CCAS in the portfile correctly
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV STRIP ":")   # If required set the ENV variable CCAS in the portfile correctly
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV NM "dumpbin.exe -symbols -headers")
        # Would be better to have a true nm here! Some symbols (mainly exported variables) get not properly imported with dumpbin as nm 
        # and require __declspec(dllimport) for some reason (same problem CMake has with WINDOWS_EXPORT_ALL_SYMBOLS)
        _vcpkg_append_to_configure_environment(CONFIGURE_ENV DLLTOOL "link.exe -verbose -dll")
        
        # Other maybe interesting variables to control
        # COMPILE This is the command used to actually compile a C source file. The file name is appended to form the complete command line. 
        # LINK This is the command used to actually link a C program.
        # CXXCOMPILE The command used to actually compile a C++ source file. The file name is appended to form the complete command line. 
        # CXXLINK  The command used to actually link a C++ program. 
    
        #Some PATH handling for dealing with spaces....some tools will still fail with that!
        string(REPLACE " " "\\\ " _VCPKG_PREFIX ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_PREFIX "${_VCPKG_PREFIX}")
        set(_VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED_PKGCONF ${CURRENT_INSTALLED_DIR})
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" _VCPKG_INSTALLED_PKGCONF ${_VCPKG_INSTALLED_PKGCONF})
        string(REPLACE "\\" "/" _VCPKG_INSTALLED_PKGCONF ${_VCPKG_INSTALLED_PKGCONF})
        set(prefix_var "'\${prefix}'") # Windows needs extra quotes or else the variable gets expanded in the makefile!
    else()
        string(REPLACE " " "\ " _VCPKG_PREFIX ${CURRENT_INSTALLED_DIR})
        string(REPLACE " " "\ " _VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
        set(_VCPKG_INSTALLED_PKGCONF ${CURRENT_INSTALLED_DIR})
        set(EXTRA_QUOTES)
        set(prefix_var "\${prefix}")
    endif()

    # Cleanup previous build dirs
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    set(ENV{V} "1") #Enable Verbose MODE

    # Set configure paths
    set(_csc_OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE} "--prefix=${EXTRA_QUOTES}${_VCPKG_PREFIX}${EXTRA_QUOTES}")
    set(_csc_OPTIONS_DEBUG ${_csc_OPTIONS_DEBUG} "--prefix=${EXTRA_QUOTES}${_VCPKG_PREFIX}/debug${EXTRA_QUOTES}")
    if(NOT _csc_NO_ADDITIONAL_PATHS)
        set(_csc_OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE}
                            # Important: These should all be relative to prefix!
                            "--bindir=${prefix_var}/tools/${PORT}/bin"
                            "--sbindir=${prefix_var}/tools/${PORT}/sbin"
                            #"--libdir='\${prefix}'/lib" # already the default!
                            #"--includedir='\${prefix}'/include" # already the default!
                            "--mandir=${prefix_var}/share/${PORT}"
                            "--docdir=${prefix_var}/share/${PORT}"
                            "--datarootdir=${prefix_var}/share/${PORT}")
        set(_csc_OPTIONS_DEBUG ${_csc_OPTIONS_DEBUG}
                            # Important: These should all be relative to prefix!
                            "--bindir=${prefix_var}/../tools/${PORT}/debug/bin"
                            "--sbindir=${prefix_var}/../tools/${PORT}/debug/sbin"
                            #"--libdir='\${prefix}'/lib" # already the default!
                            "--includedir=${prefix_var}/../include"
                            "--datarootdir=${prefix_var}/share/${PORT}")
    endif()
    # Setup common options
    if(NOT DISABLE_VERBOSE_FLAGS)
        list(APPEND _csc_OPTIONS --disable-silent-rules --verbose)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        list(APPEND _csc_OPTIONS --enable-shared --disable-static)
    else()
        list(APPEND _csc_OPTIONS --disable-shared --enable-static)
    endif()

    #if (VCPKG_TARGET_IS_UWP) ######## These flags belong into some port and cannot be generally set. AUTOTOOLS uses envrionment variables !
    #        list(APPEND _csc_OPTIONS --extra-ldflags=-APPCONTAINER --extra-ldflags=WindowsApp.lib)
    #endif()

    file(RELATIVE_PATH RELATIVE_BUILD_PATH "${CURRENT_BUILDTREES_DIR}" "${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}")

    set(base_cmd)
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${BASH} --noprofile --norc --debug)
        # Load toolchains
        if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        endif()
        include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
        if(VCPKG_TARGET_IS_UWP)
            # Flags should be set in the toolchain instead
            set(ENV{LIBPATH} "$ENV{LIBPATH};$ENV{_WKITS10}references\\windows.foundation.foundationcontract\\2.0.0.0\\;$ENV{_WKITS10}references\\windows.foundation.universalapicontract\\3.0.0.0\\")
            ##set(_csc_OPTIONS ${_csc_OPTIONS} --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP --extra-cflags=-D_WIN32_WINNT=0x0A00) //same as above /belongs into a port. 
        endif()
        #Join the options list as a string with spaces between options
        list(JOIN _csc_OPTIONS " " _csc_OPTIONS)
        list(JOIN _csc_OPTIONS_RELEASE " " _csc_OPTIONS_RELEASE)
        list(JOIN _csc_OPTIONS_DEBUG " " _csc_OPTIONS_DEBUG)
    endif()
    
    # Setup include enviromnent
    set(ENV{INCLUDE} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${INCLUDE_BACKUP}")
    set(ENV{INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${INCLUDE_PATH_BACKUP}")
    set(ENV{C_INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${C_INCLUDE_PATH_BACKUP}")
    set(ENV{CPLUS_INCLUDE_PATH} "${_VCPKG_INSTALLED}/include${VCPKG_HOST_PATH_SEPARATOR}${CPLUS_INCLUDE_PATH_BACKUP}")

    # Setup global flags -> TODO: Further improve with toolchain file in mind!
    set(C_FLAGS_GLOBAL "$ENV{CFLAGS} ${VCPKG_C_FLAGS}")
    set(CXX_FLAGS_GLOBAL "$ENV{CXXFLAGS} ${VCPKG_CXX_FLAGS}")
    set(LD_FLAGS_GLOBAL "$ENV{LDFLAGS} ${VCPKG_LINKER_FLAGS}")
    # Flags should be set in the toolchain instead (Setting this up correctly would requires a function named vcpkg_determined_cmake_compiler_flags which could also be used to setup CC and CXX etc.)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        string(APPEND C_FLAGS_GLOBAL " -fPIC")
        string(APPEND CXX_FLAGS_GLOBAL " -fPIC")
    else()
        string(APPEND C_FLAGS_GLOBAL " /EHsc /D_WIN32_WINNT=0x0601 /DWIN32_LEAN_AND_MEAN /DWIN32 /D_WINDOWS") # TODO: Should be CPP flags instead -> rewrite when vcpkg_determined_cmake_compiler_flags defined
        string(APPEND CXX_FLAGS_GLOBAL " /EHsc /D_WIN32_WINNT=0x0601 /DWIN32_LEAN_AND_MEAN /DWIN32 /D_WINDOWS")
#        string(APPEND LD_FLAGS_GLOBAL " /VERBOSE -no-undefined")
#        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
#            string(APPEND LD_FLAGS_GLOBAL " /machine:x64")
#        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
#            string(APPEND LD_FLAGS_GLOBAL " /machine:x86")
#        endif()
    endif()
    
    if(NOT ENV{PKG_CONFIG})
        find_program(PKGCONFIG pkg-config PATHS "${MSYS_ROOT}/usr/bin" REQUIRED)
        debug_message("Using pkg-config from: ${PKGCONFIG}")
        if(NOT PKGCONFIG)
            message(STATUS "${PORT} requires pkg-config from the system package manager (example: \"sudo apt-get install pkg-config\")")
        endif()
    else()
        debug_message("ENV{PKG_CONFIG} found! Using: $ENV{PKG_CONFIG}")
        set(PKGCONFIG $ENV{PKG_CONFIG})
    endif()
    
#    set(SRC_DIR "${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}")

    # Run autoconf if necessary
#    if(EXISTS "${SRC_DIR}/configure" AND NOT _csc_SKIP_CONFIGURE)
#        set(REQUIRES_AUTOCONFIG FALSE) # use autotools and configure.ac
#        set(REQUIRES_AUTOGEN FALSE) # use autogen.sh
#    elseif(EXISTS "${SRC_DIR}/configure.ac")
#        set(REQUIRES_AUTOCONFIG TRUE)
#        set(REQUIRES_AUTOGEN FALSE)
#    elseif(EXISTS "${SRC_DIR}/autogen.sh")
#        set(REQUIRES_AUTOGEN TRUE)
#        set(REQUIRES_AUTOCONFIG FALSE)
#    endif()

    set(_GENERATED_CONFIGURE FALSE)
    if (_csc_AUTOCONFIG OR REQUIRES_AUTOCONFIG)
        find_program(AUTORECONF autoreconf REQUIRED)
        if(NOT AUTORECONF)
            message(STATUS "${PORT} requires autoconf from the system package manager (example: \"sudo apt-get install autoconf\")")
        endif()
        find_program(LIBTOOL libtool REQUIRED)
        if(NOT LIBTOOL)
            message(STATUS "${PORT} requires libtool from the system package manager (example: \"sudo apt-get install libtool libtool-bin\")")
        endif()
        find_program(AUTOPOINT autopoint REQUIRED)
        if(NOT AUTOPOINT)
            message(STATUS "${PORT} requires autopoint from the system package manager (example: \"sudo apt-get install autopoint\")")
        endif()
        message(STATUS "Generating configure for ${TARGET_TRIPLET}")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "autoreconf -vfi"
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        else()
            vcpkg_execute_required_process(
                COMMAND autoreconf -vfi
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        endif()
        message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
    endif()
    if(REQUIRES_AUTOGEN)
        message(STATUS "Generating configure for ${TARGET_TRIPLET} via autogen.sh")
        if (CMAKE_HOST_WIN32)
            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "./autogen.sh"
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        else()
            vcpkg_execute_required_process(
                COMMAND "./autogen.sh"
                WORKING_DIRECTORY "${SRC_DIR}"
                LOGNAME autoconf-${TARGET_TRIPLET}
            )
        endif()
        message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
    endif()

    if (_csc_PRERUN_SHELL)
        message(STATUS "Prerun shell with ${TARGET_TRIPLET}")
        vcpkg_execute_required_process(
            COMMAND ${base_cmd} -c "${_csc_PRERUN_SHELL}"
            WORKING_DIRECTORY "${SRC_DIR}"
            LOGNAME prerun-${TARGET_TRIPLET}
        )
    endif()

    # Configure debug
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT _csc_NO_DEBUG)
        set(_VAR_SUFFIX DEBUG)
        set(PATH_SUFFIX_${_VAR_SUFFIX} "/debug")
        set(SHORT_NAME_${_VAR_SUFFIX} "dbg")
        list(APPEND _buildtypes ${_VAR_SUFFIX})
        if (CMAKE_HOST_WIN32) # Flags should be set in the toolchain instead
            string(REGEX REPLACE "[ \t]+/" " -" CFLAGS_${_VAR_SUFFIX} "${C_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX}d /D_DEBUG /Ob0 /Od ${VCPKG_C_FLAGS_${_VAR_SUFFIX}}")
            string(REGEX REPLACE "[ \t]+/" " -" CXXFLAGS_${_VAR_SUFFIX} "${CXX_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX}d /D_DEBUG /Ob0 /Od ${VCPKG_CXX_FLAGS_${_VAR_SUFFIX}}")
            string(REGEX REPLACE "[ \t]+/" " -" LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${_VAR_SUFFIX}}")
        else()
            set(CFLAGS_${_VAR_SUFFIX} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_DEBUG}")
            set(CXXFLAGS_${_VAR_SUFFIX} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_DEBUG}")
            set(LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/ -L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link/ ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${_VAR_SUFFIX}}")
        endif()
        unset(_VAR_SUFFIX)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_VAR_SUFFIX RELEASE)
        set(PATH_SUFFIX_${_VAR_SUFFIX} "")
        set(SHORT_NAME_${_VAR_SUFFIX} "rel")
        list(APPEND _buildtypes ${_VAR_SUFFIX})
        if (CMAKE_HOST_WIN32) # Flags should be set in the toolchain instead
            string(REGEX REPLACE "[ \t]+/" " -" CFLAGS_${_VAR_SUFFIX} "${C_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_C_FLAGS_${_VAR_SUFFIX}}")
            string(REGEX REPLACE "[ \t]+/" " -" CXXFLAGS_${_VAR_SUFFIX} "${CXX_FLAGS_GLOBAL} ${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG ${VCPKG_CXX_FLAGS_${_VAR_SUFFIX}}")
            string(REGEX REPLACE "[ \t]+/" " -" LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${_VAR_SUFFIX}}")
        else()
            set(CFLAGS_${_VAR_SUFFIX} "${C_FLAGS_GLOBAL} ${VCPKG_C_FLAGS_DEBUG}")
            set(CXXFLAGS_${_VAR_SUFFIX} "${CXX_FLAGS_GLOBAL} ${VCPKG_CXX_FLAGS_DEBUG}")
            set(LDFLAGS_${_VAR_SUFFIX} "-L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/ -L${_VCPKG_INSTALLED}${PATH_SUFFIX_${_VAR_SUFFIX}}/lib/manual-link/ ${LD_FLAGS_GLOBAL} ${VCPKG_LINKER_FLAGS_${_VAR_SUFFIX}}")
        endif()
        unset(_VAR_SUFFIX)
    endif()

    foreach(_buildtype IN LISTS _buildtypes)
        foreach(ENV_VAR ${_csc_CONFIG_DEPENDENT_ENVIRONMENT})
            if(DEFINED ENV{${ENV_VAR}})
                set(BACKUP_CONFIG_${ENV_VAR} "$ENV{${ENV_VAR}}")
            endif()
            set(ENV{${ENV_VAR}} "${${ENV_VAR}_${_buildtype}}")
        endforeach()

        set(TAR_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_NAME_${_buildtype}}")
        file(MAKE_DIRECTORY "${TAR_DIR}")
        file(RELATIVE_PATH RELATIVE_BUILD_PATH "${TAR_DIR}" "${SRC_DIR}")

        if(_csc_COPY_SOURCE)
            file(COPY "${SRC_DIR}/" DESTINATION "${TAR_DIR}")
            set(RELATIVE_BUILD_PATH .)
        endif()

        set(PKGCONFIG_INSTALLED_DIR "${_VCPKG_INSTALLED_PKGCONF}${PATH_SUFFIX_${_buildtype}}/lib/pkgconfig")
        set(PKGCONFIG_INSTALLED_SHARE_DIR "${_VCPKG_INSTALLED_PKGCONF}/share/pkgconfig")

        if(ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype} $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}:${PKGCONFIG_INSTALLED_SHARE_DIR}:$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}:${PKGCONFIG_INSTALLED_SHARE_DIR}")
        endif()

        # Setup environment
        set(ENV{CFLAGS} ${CFLAGS_${_buildtype}})
        set(ENV{CXXFLAGS} ${CXXFLAGS_${_buildtype}})
        set(ENV{LDFLAGS} ${LDFLAGS_${_buildtype}})
        set(ENV{PKG_CONFIG} "${PKGCONFIG} --define-variable=prefix=${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}")
        set(ENV{LIBPATH} "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib${VCPKG_HOST_PATH_SEPARATOR}${LIBPATH_BACKUP}")
 
        set(ENV{LIBRARY_PATH} "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/manual-link/${LD_LIBRARY_PATH_PATHLIKE_CONCAT}")
        set(ENV{LD_LIBRARY_PATH} "${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_VCPKG_INSTALLED}${PATH_SUFFIX_${_buildtype}}/lib/manual-link/${LD_LIBRARY_PATH_PATHLIKE_CONCAT}")

        if (CMAKE_HOST_WIN32)   
            set(command ${base_cmd} -c "${CONFIGURE_ENV} ./${RELATIVE_BUILD_PATH}/configure ${_csc_BUILD_TRIPLET} ${_csc_OPTIONS} ${_csc_OPTIONS_${_buildtype}}")
        else()
            set(command /bin/bash "./${RELATIVE_BUILD_PATH}/configure" ${_csc_BUILD_TRIPLET} ${_csc_OPTIONS} ${_csc_OPTIONS_${_buildtype}})
        endif()
        debug_message("Configure command:'${command}'")
        if (NOT _csc_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TARGET_TRIPLET}-${SHORT_NAME_${_buildtype}}")
            vcpkg_execute_required_process(
                COMMAND ${command}
                WORKING_DIRECTORY "${TAR_DIR}"
                LOGNAME config-${TARGET_TRIPLET}-${SHORT_NAME_${_buildtype}}
            )
            if(EXISTS "${TAR_DIR}/libtool" AND VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                set(_file "${TAR_DIR}/libtool")
                file(READ "${_file}" _contents)
                string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                file(WRITE "${_file}" "${_contents}")
            endif()
        endif()

        if(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype})
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype}}")
        else()
            unset(ENV{PKG_CONFIG_PATH})
        endif()
        unset(BACKUP_ENV_PKG_CONFIG_PATH_${_buildtype})
        
        # Restore environment (config dependent)
        foreach(ENV_VAR ${_csc_CONFIG_DEPENDENT_ENVIRONMENT})
            if(BACKUP_CONFIG_${ENV_VAR})
                set(ENV{${ENV_VAR}} "${BACKUP_CONFIG_${ENV_VAR}}")
            else()
                unset(ENV{${ENV_VAR}})
            endif()
        endforeach()
    endforeach()

    # Restore environment
    foreach(_prefix IN LISTS FLAGPREFIXES)
        if(${prefix}_FLAGS_BACKUP)
            set(ENV{${prefix}FLAGS} ${${_prefix}_FLAGS_BACKUP})
        else()
            unset(ENV{${prefix}FLAGS})
        endif()
    endforeach()

    set(ENV{INCLUDE} "${INCLUDE_BACKUP}")
    set(ENV{INCLUDE_PATH} "${INCLUDE_PATH_BACKUP}")
    set(ENV{C_INCLUDE_PATH} "${C_INCLUDE_PATH_BACKUP}")
    set(ENV{CPLUS_INCLUDE_PATH} "${CPLUS_INCLUDE_PATH_BACKUP}")
    _vcpkg_restore_env_variable(LIBRARY_PATH)
    _vcpkg_restore_env_variable(LD_LIBRARY_PATH)
    set(ENV{LIBPATH} "${LIBPATH_BACKUP}")
    SET(_VCPKG_PROJECT_SOURCE_PATH ${_csc_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${_csc_PROJECT_SUBPATH} PARENT_SCOPE)
endfunction()
