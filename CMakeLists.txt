cmake_minimum_required(VERSION 3.10...4.1)
project(app_superbuild NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(ExternalProject)
include(ClangdHelpers)
include(TargetEnv)

include(Sqlite)
include(Boost)

# --- APP ---
ExternalProject_Add(app
    SOURCE_DIR        ${CMAKE_CURRENT_SOURCE_DIR}/app
    CMAKE_ARGS        ${COMMON_CMAKE_ARGS}
    DEPENDS           sqlite boost
    BUILD_ALWAYS      TRUE
)

ExternalProject_Get_Property(app BINARY_DIR)
set(APP_EXE_NAME "app${CMAKE_EXECUTABLE_SUFFIX}")

if(CMAKE_CROSSCOMPILING)
    add_custom_target(run
        COMMAND ${CMAKE_COMMAND} -E echo "Cannot run: Cross-compiled for ${CMAKE_SYSTEM_NAME}."
    )
else()
    add_custom_target(run
        COMMAND ${CMAKE_COMMAND} 
                -DBINARY_DIR=${BINARY_DIR}
                -DCONFIG=$<CONFIG>
                -DEXE_NAME=${APP_EXE_NAME}
                -DSTAGING_LIB_DIR=${CMAKE_STAGING_PREFIX}/lib
                -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/RunApp.cmake"
        DEPENDS app
        USES_TERMINAL
        COMMAND_EXPAND_LISTS
        COMMENT "Running application from ${BINARY_DIR}..."
    )
endif()

set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Template CPP App")

# This MUST be the last line of CMakeLists.txt
include(CPack)
