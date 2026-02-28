cmake_minimum_required(VERSION 3.14)
project(qemu_bridge VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBVIRT REQUIRED libvirt)

add_library(qemu_bridge SHARED qemu_bridge.cc)

target_include_directories(qemu_bridge PRIVATE ${LIBVIRT_INCLUDE_DIRS})
target_link_libraries(qemu_bridge PRIVATE ${LIBVIRT_LIBRARIES})
target_compile_options(qemu_bridge PRIVATE ${LIBVIRT_CFLAGS_OTHER})

set_target_properties(qemu_bridge PROPERTIES
  OUTPUT_NAME "qemu_bridge"
  POSITION_INDEPENDENT_CODE ON
)

install(TARGETS qemu_bridge
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
