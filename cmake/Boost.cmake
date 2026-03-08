# Detect Architecture for Boost
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
    set(BOOST_ARCH "arm")
    set(BOOST_ADDR_MODEL 64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    set(BOOST_ARCH "arm")
    set(BOOST_ADDR_MODEL 32)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64")
    set(BOOST_ARCH "x86")
    set(BOOST_ADDR_MODEL 64)
else()
    set(BOOST_ARCH "x86")
    set(BOOST_ADDR_MODEL 32)
endif()

string(TOLOWER "${CMAKE_SYSTEM_NAME}" BOOST_TARGET_OS)

# Determine Toolset
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_C_COMPILER MATCHES "clang")
    set(BOOST_TOOLSET_TYPE "clang")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_C_COMPILER MATCHES "gcc")
    set(BOOST_TOOLSET_TYPE "gcc")
elseif(MSVC)
    set(BOOST_TOOLSET_TYPE "msvc")
else()
    set(BOOST_TOOLSET_TYPE "gcc")
endif()

# Construct Cross-Compilation Flags
set(BOOST_FLAGS "")
if(CMAKE_CROSSCOMPILING)
    # Pass the sysroot if defined
    if(CMAKE_SYSROOT)
        string(APPEND BOOST_FLAGS " --sysroot=${CMAKE_SYSROOT}")
    endif()

    # Pass the target triple (vital for Clang)
    if(CMAKE_CXX_COMPILER_TARGET)
        string(APPEND BOOST_FLAGS " --target=${CMAKE_CXX_COMPILER_TARGET}")
    elseif(ANDROID)
        # Fallback for Android NDK toolchains that don't set CMAKE_CXX_COMPILER_TARGET
        string(APPEND BOOST_FLAGS " --target=${CMAKE_LIBRARY_ARCHITECTURE}")
    endif()

    # Inherit any flags passed via the toolchain/command line
    string(APPEND BOOST_FLAGS " ${CMAKE_CXX_FLAGS}")
endif()

# Handle the user-config.jam
set(BOOST_USER_CONFIG "${CMAKE_BINARY_DIR}/user-config.jam")
file(WRITE ${BOOST_USER_CONFIG} 
    "using ${BOOST_TOOLSET_TYPE} : cross : ${CMAKE_CXX_COMPILER} :\n"
    "  <compileflags>\"${BOOST_FLAGS}\"\n"
    "  <target-os>${BOOST_TARGET_OS}\n"
    ";\n")

if(WIN32) 
  set(BOOST_BOOTSTRAP ./bootstrap.bat)
else() 
  set(BOOST_BOOTSTRAP ./bootstrap.sh)
endif()

ExternalProject_Add(boost
    URL               https://archives.boost.io/release/1.90.0/source/boost_1_90_0.tar.gz
    BUILD_IN_SOURCE   TRUE
    CONFIGURE_COMMAND <SOURCE_DIR>/${BOOST_BOOTSTRAP} --prefix=${CMAKE_STAGING_PREFIX}
    # The actual build uses the jam file and our target settings
    BUILD_COMMAND     ./b2 install
                      -j${PARALLEL_LEVEL}
                      --prefix=${CMAKE_STAGING_PREFIX}
                      --user-config=${BOOST_USER_CONFIG}
                      # Add specific components here to save time:
                      --with-system 
                      --with-filesystem
                      --with-json
                      --with-log
                      --layout=system
                      # Properties:
                      toolset=${BOOST_TOOLSET_TYPE}-cross
                      architecture=${BOOST_ARCH}
                      address-model=${BOOST_ADDR_MODEL} 
                      target-os=${BOOST_TARGET_OS}
                      link=static 
                      variant=release
                      threading=multi
    
    INSTALL_COMMAND   "" # b2 install is handled in BUILD_COMMAND
)
