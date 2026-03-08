cmake_minimum_required(VERSION 3.28)
project(app-test)

fetchcontent_declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG f8d7d77c06936315286eb55f8de22cd23c188571 # release-1.14.0
    EXCLUDE_FROM_ALL
)

fetchcontent_makeavailable(googletest)

add_executable(${PROJECT_NAME} test.cxx)
target_link_options(${PROJECT_NAME} PUBLIC -static)
target_link_libraries(${PROJECT_NAME} PRIVATE GTest::gtest)

# Install
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)
