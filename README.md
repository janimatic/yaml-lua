# yaml_lua
 A yaml cpp lua warper based on swig

* create a new repository using github desktop

* swig wrapper generator must be installed from
https://www.swig.org/download.html (http://prdownloads.sourceforge.net/swig/swigwin-4.2.1.zip in my case)

* lua 5.1 libs must be installed from ...
https://sourceforge.net/projects/luabinaries/files/5.1.5/Windows%20Libraries/Dynamic/ 
(The latest lua 5.1 x64 libs, in my case :  https://sourceforge.net/projects/luabinaries/files/5.1.5/Windows%20Libraries/Dynamic/lua-5.1.5_Win64_dll17_lib.zip/download )
5.1 is required by Blackmagic Davinci Resolve/Fusion

* create a new cmake file CMakeLists.txt in the src subdirectory
- declare a cmake project
```
cmake_minimum_required(VERSION 3.10)
project(yaml_lua VERSION 1.0)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
```

- find swig and lua51
```
find_package(SWIG REQUIRED)
include(${SWIG_USE_FILE})
find_package(Lua51 REQUIRED)
```

- setup swig
```
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_SWIG_FLAGS "")
set(CMAKE_SWIG_OUTDIR ${PROJECT_SOURCE_DIR}/yaml_lua)
set(SWIG_OUTFILE_DIR ${PROJECT_SOURCE_DIR}/yaml_lua)
set_source_files_properties(yaml_lua.i PROPERTIES CPLUSPLUS ON)
set_source_files_properties(yaml_lua.i PROPERTIES USE_SWIG_DEPENDENCIES TRUE)
set_property(SOURCE yaml_lua.i PROPERTY SWIG_MODULE_NAME yaml_lua)
set_property(SOURCE yaml_lua.i PROPERTY CPLUSPLUS ON)
```

- add our swig library yaml_lua
```
swig_add_library(yaml_lua 
LANGUAGE lua 
SOURCES yaml_lua.i
)
```

- link lua lib in our library yaml_lua
```
target_link_libraries(yaml_lua PUBLIC ${LUA_LIBRARIES})
```

- fetch the content of yaml cpp based on https://github.com/jbeder/yaml-cpp?tab=readme-ov-file#how-to-integrate-it-within-your-project-using-cmake
```
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
```

* launch cmake-gui to run cmake
ex 
source_code: P:/workflow/dev/yaml_lua/src
build dir: P:/workflow/dev/yaml_lua/build

* configure
use default generator (ex : vs2019  x64)

Fix the red lines. 
In my case :
LUA_INCLUDE_DIR P:/workflow/dev/lua/lua-5.1.5_Win64_dll17_lib/include
LUA_LIBRARY P:/workflow/dev/lua/lua-5.1.5_Win64_dll17_lib/lua5.1.lib

And re-run configure until there is no red line in the name/value fields...
I kept the default values for yaml-cpp settings (rerun configure for those)
It's ok if logged messages are red

* Generate
It will create the c++ projects (vs2019 in my case) in P:\workflow\dev\janimatic\yaml_lua\build

* open your c++ ide
Switch to release mode
Build the solution
yaml-cpp projects will build
but the swig warper will fail until we provide a valid swig interface file.

* Create a minimal swig interface file yaml_lua.i
By default will expose all the included files c++ objects definitions to lua
```
/* File : xcl.i */
%module yaml

%{
#include "yaml-cpp/yaml.h"
%}

%include "yaml-cpp/yaml.h"
```

* fix a problem with yaml cpp includes (probably because swig included files are not in subfolders but in build/_deps)
```
set_source_files_properties(yaml_lua.i PROPERTIES USE_TARGET_INCLUDE_DIRECTORIES TRUE) # fixes yaml_lua.i(8): error : Unable to find 'yaml-cpp\yaml.h'
```

* copy our yaml_lua.dll in the swig directory
next to runme.lua, example lua file inmporting the dll

* write and test your lua code...
- edit yaml_lua/src/swig/runme.lua
- run with a lua interpreter. In my case :
```
cd P:\workflow\dev\janimatic\yaml_lua\src\lua
P:\workflow\dev\lua\lua-5.1.5_Win64_bin\lua5.1.exe runme.lua
```

* explore swig
https://www.swig.org/Doc1.3/SWIG.html
https://www.swig.org/Doc1.3/SWIGPlus.html

