cmake_minimum_required(VERSION 3.17)

#set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/../vcpkg/scripts/buildsystems/vcpkg.cmake)
#list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

project(lapack_test CXX)

set(MSYS_ROOT "D:/vcpkg_common/downloads/tools/msys2/msys64")
set(GCC_LIBS_BASE "${MSYS_ROOT}/mingw64/lib/gcc/x86_64-w64-mingw32/10.1.0/")
set(MINGW_LIBS_BASE "${MSYS_ROOT}/mingw64/x86_64-w64-mingw32/lib/")
#set(ENV{LIBS} "$ENV{LIBS};${GCC_LIBS_BASE}libgfortran.dll.a;${GCC_LIBS_BASE}libquadmath.dll.a")
#set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} ${GCC_LIBS_BASE}libgfortran.dll.a ${GCC_LIBS_BASE}libquadmath.dll.a ${GCC_LIBS_BASE}libgcc.a)
#set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} ${MIGW_LIBS_BASE}libpthread.a ${MIGW_LIBS_BASE}libmingw32.a ${MIGW_LIBS_BASE}libmingwex.a ${MIGW_LIBS_BASE}libmsvcrt.a ${GCC_LIBS_BASE}libgfortran.a ${GCC_LIBS_BASE}libquadmath.a ${GCC_LIBS_BASE}libsupc++.a ${GCC_LIBS_BASE}libssp.a ${GCC_LIBS_BASE}libssp_nonshared.a ${GCC_LIBS_BASE}libgcc.a ${GCC_LIBS_BASE}libgcc_eh.a ${GCC_LIBS_BASE}libgcc_s.a ${GCC_LIBS_BASE}libcaf_single.a ${GCC_LIBS_BASE}libstdc++.a)

#libmingw32.a(lib64_libmingw32_a-pesect.o) : error LNK2001: unresolved external symbol __image_base__ if linked against ${MIGW_LIBS_BASE}libmingw32.a

set(CMAKE_C_STANDARD_LIBRARIES "${CMAKE_C_STANDARD_LIBRARIES} ${GCC_LIBS_BASE}libgfortran.dll.a ${GCC_LIBS_BASE}libquadmath.dll.a" CACHE INTERNAL "" FORCE)
set(CMAKE_CXX_STANDARD_LIBRARIES "${CMAKE_CXX_STANDARD_LIBRARIES} ${GCC_LIBS_BASE}libgfortran.dll.a ${GCC_LIBS_BASE}libquadmath.dll.a" CACHE INTERNAL "" FORCE)
find_package(BLAS)

find_package(LAPACK REQUIRED)
#
add_executable(${PROJECT_NAME} main.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")
target_link_libraries(${PROJECT_NAME} PRIVATE "${BLAS_LIBRARIES}")
target_link_libraries(${PROJECT_NAME} PRIVATE "${LAPACK_LIBRARIES}")
message(STATUS "BLAS_LIBRARIES:${BLAS_LIBRARIES}")
#target_link_libraries(${PROJECT_NAME} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/../vcpkg/installed/x64-linux/lib/liblapack.a")
#target_link_libraries(${PROJECT_NAME} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/../vcpkg/installed/x64-linux/lib/libf2c.a")
#target_link_libraries(${PROJECT_NAME} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/../vcpkg/installed/x64-linux/lib/libopenblas.a")
target_link_libraries(${PROJECT_NAME} PRIVATE Threads::Threads)
#target_link_libraries(${PROJECT_NAME} PRIVATE "-lm")
#target_link_libraries(${PROJECT_NAME} PRIVATE arithchk)

install(TARGETS ${PROJECT_NAME} DESTINATION tools/lapack_test)