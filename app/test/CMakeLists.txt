cmake_minimum_required(VERSION 3.10...4.1)
project(app-test)

fetchcontent_declare(
    googletest
    GIT_REPOSITORY  https://github.com/google/googletest.git
    GIT_TAG         v1.17.0
    EXCLUDE_FROM_ALL
)

fetchcontent_makeavailable(googletest)

add_executable(${PROJECT_NAME} test.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE GTest::gtest)
