cmake_minimum_required(VERSION 3.10...4.1)
project(app LANGUAGES CXX)

include(FetchContent)
include(ClangdHelpers)
include(CheckIPOSupported)
check_ipo_supported(RESULT IPO_SUPPORTED OUTPUT error)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
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
find_package(SQLite3 REQUIRED)
find_package(Boost REQUIRED COMPONENTS json log)

target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt-header-only)
target_link_libraries(${PROJECT_NAME} PRIVATE SQLite::SQLite3)
target_link_libraries(${PROJECT_NAME} PRIVATE Boost::headers Boost::json Boost::log)

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

add_subdirectory(test)

generate_clangd_config("${CMAKE_CURRENT_SOURCE_DIR}")

# Define a target that "dirties" the build configuration
# This forces Ninja to re-run the CMake Configure step on the NEXT build invocation.
add_custom_target(force_reconfigure_clangd ALL
    COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_LIST_FILE}"
    COMMENT "Triggering CMake re-configure for clangd update..."
    VERBATIM
)
