cmake_minimum_required(VERSION 3.10)
project(yaml_lua VERSION 1.0)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# find swig wrapper generator, witch must fisrt be installed from https://www.swig.org/download.html
find_package(SWIG REQUIRED)
include(${SWIG_USE_FILE})

# find lua libs/headers, witch must fisrt be installed from https://www.swig.org/download.html
find_package(Lua51 REQUIRED)
include_directories(${LUA_INCLUDE_DIR})

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_SWIG_FLAGS "")
set(CMAKE_SWIG_OUTDIR ${PROJECT_SOURCE_DIR}/swig)

set_source_files_properties(yaml_lua.i PROPERTIES CPLUSPLUS ON)
set_source_files_properties(yaml_lua.i PROPERTIES USE_SWIG_DEPENDENCIES TRUE)
set_source_files_properties(yaml_lua.i PROPERTIES USE_TARGET_INCLUDE_DIRECTORIES TRUE) # fixes yaml_lua.i(8): error : Unable to find 'yaml-cpp\yaml.h'
set_property(SOURCE yaml_lua.i PROPERTY SWIG_MODULE_NAME yaml_lua)
set_property(SOURCE yaml_lua.i PROPERTY CPLUSPLUS ON)

swig_add_library(yaml_lua 
LANGUAGE lua 
SOURCES yaml_lua.i
)
# add_library() not required because swig_add_library defines a target already

target_link_libraries(yaml_lua PUBLIC ${LUA_LIBRARIES})

# copied from https://github.com/jbeder/yaml-cpp?tab=readme-ov-file#how-to-integrate-it-within-your-project-using-cmake
include(FetchContent)

FetchContent_Declare(
  yaml-cpp
  GIT_REPOSITORY https://github.com/jbeder/yaml-cpp.git
  GIT_TAG master # Can be a tag (yaml-cpp-x.x.x), a commit hash, or a branch name (master)
)
FetchContent_GetProperties(yaml-cpp)

if(NOT yaml-cpp_POPULATED)
  message(STATUS "Fetching yaml-cpp...")
  FetchContent_Populate(yaml-cpp)
  add_subdirectory(${yaml-cpp_SOURCE_DIR} ${yaml-cpp_BINARY_DIR})
endif()

target_link_libraries(yaml_lua PUBLIC yaml-cpp::yaml-cpp) # The library or executable that require yaml-cpp library

file(GLOB yaml_lua_HEADERS
        yaml_lua/*.h
        )
file(GLOB yaml_lua_SRCS
        yaml_lua/*.cpp
        )
target_sources( yaml_lua PRIVATE 
    ${yaml_lua_HEADERS} ${yaml_lua_SRCS} 
)

# copy our dll next to our lua source
set(LUA_SRC ${PROJECT_SOURCE_DIR}/lua)
add_custom_command(TARGET yaml_lua POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/Release/yaml_lua.dll
                                    ${LUA_SRC}/yaml_lua.dll
)
