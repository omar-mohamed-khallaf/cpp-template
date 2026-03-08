cmake_minimum_required(VERSION 3.15)
project(app LANGUAGES CXX)

include(FetchContent)
include(CheckIPOSupported)
check_ipo_supported(RESULT IPO_SUPPORTED OUTPUT error)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})


if(IPO_SUPPORTED)
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()

fetchcontent_declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt.git
  GIT_TAG 10.2.1
  GIT_SHALLOW True
  GIT_PROGRESS True
  USE_TERMINAL True EXCLUDE_FROM_ALL)
fetchcontent_makeavailable(fmt)

add_executable(${PROJECT_NAME} src/main.cpp)

# Find the libraries in the staging directory
find_package(jsoncpp REQUIRED)
find_package(SQLite3 REQUIRED)
find_package(Boost REQUIRED)

target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt-header-only)
target_link_libraries(${PROJECT_NAME} PRIVATE JsonCpp::JsonCpp)
target_link_libraries(${PROJECT_NAME} PRIVATE SQLite::SQLite3)
target_link_libraries(${PROJECT_NAME} PRIVATE Boost::headers)

target_compile_options(
  ${PROJECT_NAME}
  PRIVATE -Wall
          -Wextra
          -Wundef
          -Wshadow
          -Wpedantic
          -Wconversion
          -Wcast-align
          -Wwrite-strings
          -Wpointer-arith
          -Wstrict-aliasing
          -Wstrict-overflow=4
          -Werror=format-security
          -Wno-missing-field-initializers)
