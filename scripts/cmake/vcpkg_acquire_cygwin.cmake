## # vcpkg_acquire_cygwin
##
## Download and prepare an CYGWIN instance.
##
## ## Usage
## ```cmake
## vcpkg_acquire_cygwin(<CYGWIN_ROOT_VAR> [APT_CYG <package>...])
## ```
##
## ## Parameters
## ### CYGWIN_ROOT_VAR
## An out-variable that will be set to the path to CYGWIN.
##
## ### APT-CYG
## A list of packages to acquire in cygwin.
##
## To ensure a package is available: `vcpkg_acquire_cygwin(CYGWIN_ROOT APT_CYG make m4 flex gcc-core gcc-g++ gcc-fortran diffutils)`
##
## ## Notes
## A call to `vcpkg_acquire_cygwin` will usually be followed by a call to `bash.exe`:
## ```cmake
## vcpkg_acquire_cygwin(CYGWIN_ROOT)
## set(BASH ${CYGWIN_ROOT}/bin/bash.exe)
##
## vcpkg_execute_required_process(
##     COMMAND ${BASH} --noprofile --norc -c "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
##     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
##     LOGNAME build-${TARGET_TRIPLET}-rel
## )
## ```
##
## ## Examples
##
## * []()

function(vcpkg_acquire_cygwin PATH_TO_ROOT_OUT)

  unset(NOEXTRACT)
  unset(_vfa_RENAME)
  unset(TOOLSUBPATH)

  set(TOOLPATH ${DOWNLOADS}/tools/cygwin)
  cmake_parse_arguments(_vac "" "" "CYG_GET;APT_CYG" ${ARGN})

  if(NOT CMAKE_HOST_WIN32)
    message(FATAL_ERROR "vcpkg_acquire_cygwin() can only be used on Windows hosts")
  endif()

  if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
  else()
      set(_vam_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
  endif()

  if(_vam_HOST_ARCHITECTURE STREQUAL "AMD64")
    set(TOOLSUBPATH cygwin64)
    set(URLS "https://cygwin.com/setup/setup-2.905.x86_64.exe")
    set(_vfa_RENAME "setup-x86_64.exe")
    set(ARCHIVE "cygwin-2.905.x86_64.exe")
    set(NOEXTRACT ON)
    set(HASH 499b0f5d94488588c5e7f0e73edbb95bf92c0bfbe5379139f79b4d259132486ee026e12cd4191300a7355f28ee19274e9aec472e393cc79f018487034f2d8bf1)
    set(STAMP "initialized-cygwin64.stamp")
  else()
    set(TOOLSUBPATH cygwin86)
    set(URLS "https://cygwin.com/setup/setup-2.905.x86.exe")
    set(_vfa_RENAME "setup-x86.exe")
    set(ARCHIVE "cygwin-2.905.x86.exe")
    set(NOEXTRACT ON)
    set(HASH 74786326c07c1cf2b11440cbd7caf947c2a32ebcc2b5bb362301d12327a2108182f57e98c217487db75bf6f0e3a4577291933e025b9b170e37848ec0b51a134c)
    set(STAMP "initialized-cygwin86.stamp")
  endif()
  
  set(PATH_TO_ROOT ${TOOLPATH}/${TOOLSUBPATH})
  
  set(BASH ${PATH_TO_ROOT}/bin/bash.exe)
  set(BASH_EXECUTABLE ${BASH})
  set(WGET ${PATH_TO_ROOT}/bin/wget.exe)
  set(CURL ${PATH_TO_ROOT}/bin/curl.exe)

  set(CYG-GET ${PATH_TO_ROOT}/bin/cyg-get)
  set(APT-CYG ${PATH_TO_ROOT}/bin/apt-cyg)

#	find_program(BASH_EXECUTABLE bash.exe)
#	message(STATUS "BASH_EXECUTABLE ${BASH_EXECUTABLE}")
#	message(STATUS "BASH ${BASH}")
  
  if(NOT EXISTS "${TOOLPATH}/${STAMP}")
    message(STATUS "Acquiring CYGWIN...")
    vcpkg_download_distfile(CYGWIN_SETUP
        URLS ${URLS}
        FILENAME ${ARCHIVE}
        SHA512 ${HASH}
    )

    file(REMOVE_RECURSE ${TOOLPATH}/${TOOLSUBPATH})
	file(MAKE_DIRECTORY ${PATH_TO_ROOT})
	
	if(DEFINED NOEXTRACT)
	  if(DEFINED _vfa_RENAME)
	    file(INSTALL ${CYGWIN_SETUP} DESTINATION ${PATH_TO_ROOT} RENAME ${_vfa_RENAME} FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
	  else()
	    file(COPY ${CYGWIN_SETUP} DESTINATION ${PATH_TO_ROOT} FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
	  endif()
	endif()

#    _execute_process(
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${CYGWIN_SETUP} 
	    --no-admin --prune-install --quiet-mode
		--disable-buggy-antivirus --upgrade-also --wait
	    --root "${PATH_TO_ROOT}"
		--no-desktop --no-shortcuts --no-startmenu --download
		--pubkey "http://cygwinports.org/ports.gpg"
		--arch "x86_64"# or x86
#		--package-manager
		--local-install "${PATH_TO_ROOT}"
		--local-package-dir "${DOWNLOADS}"
#		--only-site
		--site "http://cygwin.mirror.constant.com"
		--packages "check,wget,curl,tar,gawk,ca-certificates,gnupg,which"#install wget,tar,gawk to use apt-cyg
		--verbose
      WORKING_DIRECTORY ${TOOLPATH}
#      RESULT_VARIABLE cygwin-setup-${TARGET_TRIPLET}
      LOGNAME cygwin-setup-${TARGET_TRIPLET}
    )

#    _execute_process(
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${BASH} --login -c "wget --no-check-certificate -O /tmp/cyg-get https://gitlab.com/cogline.v3/cygwin/raw/master/cyg-get?inline=false && install /tmp/cyg-get /usr/bin"
      WORKING_DIRECTORY ${TOOLPATH}
#      RESULT_VARIABLE cyg-get-setup-${TARGET_TRIPLET}
      LOGNAME cyg-get-setup-${TARGET_TRIPLET}
    )

#    _execute_process(
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${BASH} --login -c "wget --no-check-certificate -O /tmp/apt-cyg https://raw.githubusercontent.com/kou1okada/apt-cyg/master/apt-cyg && install /tmp/apt-cyg /usr/bin"
      WORKING_DIRECTORY ${TOOLPATH}
#      RESULT_VARIABLE cyg-get-setup-${TARGET_TRIPLET}
      LOGNAME apt-cyg-setup-${TARGET_TRIPLET}
    )

###      COMMAND ${BASH} --login -c "source ~/.bashrc; /bin/wget.exe --no-check-certificate -O /usr/bin/cyg-get 
###      COMMAND ${BASH} --login -c "source ~/.inputrc; /bin/cygpath.exe -w /" > "%DIST_DIR%/root_path"
###      COMMAND ${BASH} --login -c "ln -s /usr/bin/python3.6 /usr/bin/python"
###      COMMAND ${BASH} --login -c "../apm_install.sh"
###      COMMAND ${BASH} --login -c "cd build/dqac-adlink/ipmitool && LANG=C ./bootstrap 2>&1"
###      COMMAND ${BASH} --login -c "wget --progress=dot -S -N  http://cygwin.com/setup-x86_64.exe"

#How can I get bash filename completion to be case insensitive?
#Add the following to your ~/.bashrc file:
#	shopt -s nocaseglob
#and add the following to your ~/.inputrc file:
#	set completion-ignore-case on

    file(WRITE "${TOOLPATH}/${STAMP}" "0")
    message(STATUS "Acquiring CYGWIN... OK")
  endif()

#  if(_vac_CYG_GET)
#  endif()

  if(_vac_APT_CYG)
    message(STATUS "Acquiring CYGWIN Packages...")
    string(REPLACE ";" " " _vac_APT_CYG "${_vac_APT_CYG}")
    set(_ENV_ORIGINAL $ENV{PATH})
    set(ENV{PATH} ${PATH_TO_ROOT}/bin)

    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${BASH} --login -c "/usr/bin/apt-cyg --no-verify --ipv4 --verbose upgrade-self dist-upgrade" # update-setup
      WORKING_DIRECTORY ${TOOLPATH}
    )
    vcpkg_execute_required_process(
      ALLOW_IN_DOWNLOAD_MODE
      COMMAND ${BASH} --login -c "/usr/bin/apt-cyg --force-update-packageof-cache --no-verify --ipv4 --verbose install ${_vac_APT_CYG}"
      WORKING_DIRECTORY ${TOOLPATH}
      LOGNAME apt-cyg-${TARGET_TRIPLET}
    )

    set(ENV{PATH} "${_ENV_ORIGINAL}")
    message(STATUS "Acquiring CYGWIN Packages... OK")
  endif()
  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
