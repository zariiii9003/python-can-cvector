cmake_minimum_required(VERSION 3.30.3)
project(${SKBUILD_PROJECT_NAME} LANGUAGES C)

find_package(
  Python
  COMPONENTS Interpreter Development.Module
  REQUIRED)

add_custom_command(
  OUTPUT _abstraction.c
  COMMENT
    "Making ${CMAKE_CURRENT_BINARY_DIR}/_abstraction from ${CMAKE_CURRENT_SOURCE_DIR}/src/can_cvector/_abstraction.pyx"
  COMMAND Python::Interpreter -m cython
          "${CMAKE_CURRENT_SOURCE_DIR}/src/can_cvector/_abstraction.pyx"
          --output-file
          _abstraction.c
  DEPENDS _abstraction.pyx
  VERBATIM)

python_add_library(_abstraction MODULE _abstraction.c WITH_SOABI)

if(NOT DEFINED VXLAPI_DIR)
  if(DEFINED ENV{VXLAPI_DIR})
    set(VXLAPI_DIR $ENV{VXLAPI_DIR})
  else()
    message(FATAL_ERROR "VXLAPI_DIR not set. Set it to the folder containing vxlapi.h and the vxlapi DLL files.")
  endif()
endif()

target_include_directories(_abstraction PRIVATE ${VXLAPI_DIR})

# choose DLL name by pointer size: 64-bit -> vxlapi64.dll, otherwise vxlapi.dll
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(VXLAPI_DLLNAME "vxlapi64.lib")
else()
  set(VXLAPI_DLLNAME "vxlapi.lib")
endif()

target_link_libraries(_abstraction PRIVATE ${VXLAPI_DIR}/${VXLAPI_DLLNAME})
install(TARGETS _abstraction DESTINATION can_cvector)
