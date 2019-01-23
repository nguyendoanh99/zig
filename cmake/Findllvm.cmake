# Copyright (c) 2014 Andrew Kelley
# This file is MIT licensed.
# See http://opensource.org/licenses/MIT

# LLVM_FOUND
# LLVM_INCLUDE_DIRS
# LLVM_LIBRARIES
# LLVM_LIBDIRS

find_program(LLVM_CONFIG_EXE
    NAMES llvm-config-8 llvm-config-8.0 llvm-config80 llvm-config
    PATHS
        "/mingw64/bin"
        "/c/msys64/mingw64/bin"
        "c:/msys64/mingw64/bin"
        "C:/Libraries/llvm-8.0.0/bin")

execute_process(
	COMMAND ${LLVM_CONFIG_EXE} --version
	OUTPUT_VARIABLE LLVM_CONFIG_VERSION
	OUTPUT_STRIP_TRAILING_WHITESPACE)

if(LLVM_CONFIG_VERSION VERSION_LESS 7)
  message(FATAL_ERROR "expected LLVM version >=7 but found ${LLVM_CONFIG_VERSION}")
endif()

if(NOT(CMAKE_BUILD_TYPE STREQUAL "Debug") OR ZIG_STATIC)
  execute_process(
      COMMAND ${LLVM_CONFIG_EXE} --libfiles --link-static
      OUTPUT_VARIABLE LLVM_LIBRARIES_SPACES
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " ";" LLVM_LIBRARIES "${LLVM_LIBRARIES_SPACES}")

  execute_process(
      COMMAND ${LLVM_CONFIG_EXE} --system-libs --link-static
      OUTPUT_VARIABLE LLVM_SYSTEM_LIBS_SPACES
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " ";" LLVM_SYSTEM_LIBS "${LLVM_SYSTEM_LIBS_SPACES}")

  execute_process(
      COMMAND ${LLVM_CONFIG_EXE} --libdir --link-static
      OUTPUT_VARIABLE LLVM_LIBDIRS_SPACES
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " ";" LLVM_LIBDIRS "${LLVM_LIBDIRS_SPACES}")
endif()
if(NOT LLVM_LIBRARIES)
  execute_process(
      COMMAND ${LLVM_CONFIG_EXE} --libs
      OUTPUT_VARIABLE LLVM_LIBRARIES_SPACES
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " ";" LLVM_LIBRARIES "${LLVM_LIBRARIES_SPACES}")

  execute_process(
      COMMAND ${LLVM_CONFIG_EXE} --system-libs
      OUTPUT_VARIABLE LLVM_SYSTEM_LIBS_SPACES
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " ";" LLVM_SYSTEM_LIBS "${LLVM_SYSTEM_LIBS_SPACES}")

  execute_process(
      COMMAND ${LLVM_CONFIG_EXE} --libdir
      OUTPUT_VARIABLE LLVM_LIBDIRS_SPACES
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " ";" LLVM_LIBDIRS "${LLVM_LIBDIRS_SPACES}")
endif()

execute_process(
    COMMAND ${LLVM_CONFIG_EXE} --includedir
    OUTPUT_VARIABLE LLVM_INCLUDE_DIRS
    OUTPUT_STRIP_TRAILING_WHITESPACE)

set(LLVM_LIBRARIES ${LLVM_LIBRARIES} ${LLVM_SYSTEM_LIBS})

if(NOT LLVM_LIBRARIES)
  find_library(LLVM_LIBRARIES NAMES LLVM LLVM-8 LLVM-8.0)
endif()

link_directories("${CMAKE_PREFIX_PATH}/lib")
link_directories("${LLVM_LIBDIRS}")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LLVM DEFAULT_MSG LLVM_LIBRARIES LLVM_INCLUDE_DIRS)

mark_as_advanced(LLVM_INCLUDE_DIRS LLVM_LIBRARIES LLVM_LIBDIRS)
