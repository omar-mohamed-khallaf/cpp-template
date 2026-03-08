if(ANDROID)
    set(CROSS_FLAGS "--target=${TARGET_HOST} --sysroot=${CMAKE_SYSROOT}")
else()
    set(CROSS_FLAGS "")
endif()
set(CC "${CMAKE_C_COMPILER} ${CROSS_FLAGS}")

if(WIN32)
    # set(SQLITE_BUILD nmake /f Makefile.msc)
    # set(SQLITE_INSTALL cmake -E copy sqlite3.lib "${CMAKE_STAGING_PREFIX}/sqlite3.lib")
    message(FATAL_ERROR "Windows is not supported yet")
else()
    set(SQLITE_CONF <SOURCE_DIR>/configure
                    --prefix=${CMAKE_STAGING_PREFIX}
                    --host=${TARGET_HOST}
                    --disable-shared
                    --disable-load-extension
                    --fts5
                    --rtree
                    --dbpage
                    --dbstat
                    CC=${CC}
                    AR=${CMAKE_AR}
                    RANLIB=${CMAKE_RANLIB}
                    )
    set(SQLITE_BUILD make -j${PARALLEL_LEVEL})
    set(SQLITE_INSTALL make install)
endif()

ExternalProject_Add(sqlite
    URL               https://www.sqlite.org/2026/sqlite-autoconf-3520000.tar.gz
    CONFIGURE_COMMAND ${SQLITE_CONF}
    BUILD_COMMAND     ${SQLITE_BUILD}
    INSTALL_COMMAND   ${SQLITE_INSTALL}
)
