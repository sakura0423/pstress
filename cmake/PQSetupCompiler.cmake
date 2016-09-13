INCLUDE(CheckCXXCompilerFlag)
#
CHECK_CXX_COMPILER_FLAG("-std=gnu++11" COMPILER_SUPPORTS_CXX11)
IF(NOT COMPILER_SUPPORTS_CXX11)
  MESSAGE(FATAL_ERROR "Compiler ${CMAKE_CXX_COMPILER} has no C++11 support.")
ENDIF()
#
IF((CMAKE_SYSTEM_PROCESSOR MATCHES "i386|i686|x86|AMD64") AND (CMAKE_SIZEOF_VOID_P EQUAL 4))
  SET(ARCH "x86")
ELSEIF((CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64") AND (CMAKE_SIZEOF_VOID_P EQUAL 8))
  SET(ARCH "x86_64")
ELSEIF((CMAKE_SYSTEM_PROCESSOR MATCHES "i386") AND (CMAKE_SIZEOF_VOID_P EQUAL 8) AND (APPLE))
  # Mac is weird like that.
  SET(ARCH "x86_64")
ELSEIF(CMAKE_SYSTEM_PROCESSOR MATCHES "^arm*")
  SET(ARCH "ARM")
ELSEIF(CMAKE_SYSTEM_PROCESSOR MATCHES "sparc")
  SET(ARCH "sparc")
ENDIF()
#
MESSAGE(STATUS "Architecture is ${ARCH}")
#
ADD_DEFINITIONS(-std=gnu++11 -pipe)
#
OPTION(STRICT "Turn on a lot of compiler warnings" ON)
OPTION(ASAN "Turn ON Address sanitizer feature" OFF)
OPTION(DEBUG "Add debug info for GDB" OFF)
OPTION(STATIC_LIB "Statically compile MySQL library into PQuery" ON)
OPTION(OPTIMIZATION "Optimize binaries" ON)
OPTION(SIZE_OPTIMIZATION "Optimize binaries for size (sometimes for speed also)" OFF)
#
IF(DEBUG)
  SET(OPTIMIZATION OFF)
  SET(SIZE_OPTIMIZATION OFF)
  ADD_DEFINITIONS(-O0 -g3 -ggdb3)
ENDIF()
#
IF(OPTIMIZATION)
  ADD_DEFINITIONS(-O3)
ENDIF()
IF(SIZE_OPTIMIZATION)
  ADD_DEFINITIONS(-Os)
ENDIF()
IF(OPTIMIZATION OR SIZE_OPTIMIZATION)
  ADD_DEFINITIONS(-march=native -mtune=generic)
ENDIF()
#
IF(STRICT)
  ADD_DEFINITIONS(-Wall -Werror -Wextra -pedantic-errors -Wmissing-declarations)
ENDIF ()
#
IF(ASAN)
  # doesn't work with GCC < 4.8
  ADD_DEFINITIONS(-fsanitize=address)
  SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address")
ENDIF()
#
IF(STATIC_LIB)
  # we will link shared libraries
  INCLUDE(FindOpenSSL REQUIRED)
  INCLUDE(FindThreads REQUIRED)
  INCLUDE(FindZLIB REQUIRED)
  # and link static MySQL client library
  SET(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
  SET (OTHER_LIBS pthread z)
  IF(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    SET (OTHER_LIBS ${OTHER_LIBS} dl rt)
  ENDIF()
  IF(PERCONASERVER OR WEBSCALESQL OR PERCONACLUSTER)
    SET(OTHER_LIBS ${OTHER_LIBS} ssl crypto)
  ENDIF(PERCONASERVER OR WEBSCALESQL OR PERCONACLUSTER)
ENDIF(STATIC_LIB)
