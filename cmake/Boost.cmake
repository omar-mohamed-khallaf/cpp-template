# Detect Architecture for Boost
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
    set(BOOST_ARCH "arm")
    set(BOOST_ADDR_MODEL 64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    set(BOOST_ARCH "arm")
    set(BOOST_ADDR_MODEL 32)
else()
    set(BOOST_ARCH "x86")
    set(BOOST_ADDR_MODEL 64)
endif()

# Determine Toolset
set(BOOST_TOOLSET "clang")
if(CMAKE_C_COMPILER_ID MATCHES "GNU" OR NOT CMAKE_C_COMPILER_ID)
    if(NOT CMAKE_C_COMPILER MATCHES "clang")
        set(BOOST_TOOLSET "gcc")
    endif()
endif()

# Handle the user-config.jam
# We use the compiler found by the toolchain file
set(BOOST_USER_CONFIG "${CMAKE_BINARY_DIR}/user-config.jam")
file(WRITE ${BOOST_USER_CONFIG} 
    "using ${BOOST_TOOLSET} : cross : ${CMAKE_CXX_COMPILER} ;\n")

if(WIN32) 
  set(BOOST_BOOTSTRAP ./bootstrap.bat)
else() 
  set(BOOST_BOOTSTRAP ./bootstrap.sh)
endif()

ExternalProject_Add(boost
    URL               https://archives.boost.io/release/1.90.0/source/boost_1_90_0.tar.gz
    BUILD_IN_SOURCE   ON
    CONFIGURE_COMMAND <SOURCE_DIR>/${BOOST_BOOTSTRAP} --prefix=${CMAKE_STAGING_PREFIX}
    # The actual build uses the jam file and our target settings
    BUILD_COMMAND     ./b2 install 
                      -j${PARALLEL_LEVEL}
                      --user-config=${BOOST_USER_CONFIG}
                      toolset=${BOOST_TOOLSET}-cross
                      architecture=${BOOST_ARCH}
                      address-model=${BOOST_ADDR_MODEL} 
                      link=static 
                      variant=release
                      threading=multi
                      --prefix=${CMAKE_STAGING_PREFIX}
                      # Add specific components here to save time:
                      --with-system 
                      --with-filesystem
    
    INSTALL_COMMAND   "" # b2 install is handled in BUILD_COMMAND
)
