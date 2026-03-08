# cmake/RunApp.cmake

# Variables passed via -D:
# BINARY_DIR: Root of the app build (e.g., .../app-build)
# CONFIG: The build config (e.g., Debug, Release)
# EXE_NAME: The name of the binary
# STAGING_LIB_DIR: Where Boost/Sqlite live

# Resolve the actual path for Multi-Config
set(BINARY_PATH "${BINARY_DIR}/${CONFIG}/${EXE_NAME}")

if(NOT EXISTS "${BINARY_PATH}")
    message(FATAL_ERROR "Executable not found at: ${BINARY_PATH}\nDid you build the '${CONFIG}' configuration?")
endif()

# Platform-specific library paths
if(CMAKE_HOST_WIN32)
    set(PATH_VAR "PATH")
    set(SEP ";")
else()
    set(PATH_VAR "LD_LIBRARY_PATH")
    set(SEP ":")
endif()

set(NEW_PATH "${STAGING_LIB_DIR}${SEP}$ENV{${PATH_VAR}}")

message(STATUS "Launching (${CONFIG}): ${BINARY_PATH}")

execute_process(
    COMMAND ${CMAKE_COMMAND} -E env "${PATH_VAR}=${NEW_PATH}" "${BINARY_PATH}"
    RESULT_VARIABLE RUN_RESULT
)

if(NOT RUN_RESULT EQUAL 0)
    message(FATAL_ERROR "Application exited with error code: ${RUN_RESULT}")
endif()
