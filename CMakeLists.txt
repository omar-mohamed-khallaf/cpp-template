cmake_minimum_required(VERSION 3.10...4.1)
project(app_superbuild NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(ExternalProject)
include(TargetEnv)

include(Sqlite)
include(Boost)

# --- JSONCPP ---
ExternalProject_Add(jsoncpp
    GIT_REPOSITORY  https://github.com/open-source-parsers/jsoncpp.git
    GIT_TAG         1.9.6
    CMAKE_ARGS      ${COMMON_CMAKE_ARGS}
                    -DBUILD_STATIC_LIBS:BOOL=ON
                    -DJSONCPP_WITH_TESTS:BOOL=OFF
)

# --- APP ---
ExternalProject_Add(app
    SOURCE_DIR        ${CMAKE_CURRENT_SOURCE_DIR}/app
    CMAKE_ARGS        ${COMMON_CMAKE_ARGS}
    DEPENDS           sqlite jsoncpp boost
)

ExternalProject_Get_Property(app BINARY_DIR)

add_custom_target(link_compile_commands ALL
    COMMAND ${CMAKE_COMMAND} -E create_symlink 
            "${BINARY_DIR}/compile_commands.json" 
            "${CMAKE_SOURCE_DIR}/compile_commands.json"
    COMMENT "Linking compile_commands.json to root for clangd"
    DEPENDS app)

set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Template CPP App")

# This MUST be the last line of CMakeLists.txt
include(CPack)
