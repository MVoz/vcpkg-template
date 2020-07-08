## # vcpkg_get_fortran_compiler
##
## Tries to detect a fortran compiler using CMakeDetermineFortranCompiler with some additional error checking.
##
##
## If the variable CMAKE_Fortran_COMPILER gets not set an error will be raised.
## You can use that variable or VCPKG_FORTRAN_COMPILER
##
## ## Usage:
## ```cmake
## vcpkg_get_fortran_compiler()
## ```
##
## ## Examples:
##
## * [lapack](https://github.com/Microsoft/vcpkg/blob/master/ports/lapack-reference/portfile.cmake)

function(vcpkg_get_fortran_compiler)

    if(WIN32)
        file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" _programfiles)
        file(GLOB PGI_PATHS LIST_DIRECTORIES true "${_programfiles}/PGI/win64/*") # find possible PGI default paths
        message(STATUS "${PGI_PATHS}")
        foreach(_pgi_path ${PGI_PATHS})
            if(IS_DIRECTORY ${_pgi_path})
                if(EXISTS "${_pgi_path}/bin")
                    list(APPEND CMAKE_PROGRAM_PATH "${_pgi_path}/bin")
                endif()
            endif()
        endforeach()
        
        set(_PROGRAMFILESX86 "PROGRAMFILES(x86)")
        file(TO_CMAKE_PATH "$ENV{${_PROGRAMFILESX86}}" _programfiles_x86)
        if(EXISTS ${_programfiles_x86}/IntelSWTools/compilers_and_libraries/windows/bin/intel64)
             list(APPEND CMAKE_PROGRAM_PATH "${_programfiles_x86}/IntelSWTools/compilers_and_libraries/windows/bin/intel64")
             # Seems like newer intel fortran compilers are not yet correctly supported by cmake
             # I see -- The Fortran compiler identification is unknown: 
        endif()
    endif()

    #CMake will generate some files. Setting these paths is enough to move those files into the buildtree
    set(_tmp_CMAKE_PLATFORM_INFO_DIR "${CMAKE_PLATFORM_INFO_DIR}")
    set(_tmp_CMAKE_BUILD_DIRECTORY "${CMAKE_BUILD_DIRECTORY}")
    set(_tmp_CMAKE_BINARY_DIR "${CMAKE_BINARY_DIR}")

    set(CMAKE_PLATFORM_INFO_DIR "${CURRENT_BUILDTREES_DIR}/cmake/${TARGET_TRIPLET}")
    set(CMAKE_BUILD_DIRECTORY "${CURRENT_BUILDTREES_DIR}/cmake/${TARGET_TRIPLET}")
    set(CMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/cmake/${TARGET_TRIPLET}")

    include(CMakeDetermineFortranCompiler)  # Find a Fortran compiler for us. Can be overwritten by setting CMAKE_Fortran_COMPILER

    set(CMAKE_PLATFORM_INFO_DIR "${_tmp_CMAKE_PLATFORM_INFO_DIR}")
    set(CMAKE_BUILD_DIRECTORY "${_tmp_CMAKE_BUILD_DIRECTORY}")
    set(CMAKE_BINARY_DIR "${_tmp_CMAKE_BINARY_DIR}")

    if(${CMAKE_Fortran_COMPILER} MATCHES "NOTFOUND")
        message(FATAL_ERROR "LAPACK requires a Fortran compiler! Examples: Windows: PGI Compiler & Tools/Intel; Linux: gFortran")
    else()
        message(STATUS "Used Fortran Compiler: ${CMAKE_Fortran_COMPILER}")
    endif()

    get_filename_component(_fort_comp_name ${CMAKE_Fortran_COMPILER} NAME)
    #get_filename_component(_fort_comp_dir ${CMAKE_Fortran_COMPILER} DIRECTORY) 
#    if(${CMAKE_Fortran_COMPILER} MATCHES "$pg")
    if(_fort_comp_name MATCHES "^pg")
        set(VCPKG_Fortran_IS_PGI 1 PARENT_SCOPE)
        if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64") 
            # Support for 32-bit development was deprecated in PGI 2016 and is no longer available as of the PGI 2017 release. 
            # PGI 2017 is only available for 64-bit operating systems and does not include the ability to compile 32-bit applications
            message(FATAL_ERROR "lapack can only be built for x64 systems using pgi fortran")
        endif()
    elseif(_fort_comp_name MATCHES "^ifort")
        set(VCPKG_Fortran_IS_INTEL 1 PARENT_SCOPE)
    endif()
    
    set(VCPKG_FORTRAN_COMPILER "${CMAKE_Fortran_COMPILER}" PARENT_SCOPE)
endfunction()