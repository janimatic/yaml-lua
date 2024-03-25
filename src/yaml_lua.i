/* 

File : yaml_lua.i 

check 
https://github.com/swig/swig/blob/master/Examples/lua/nspace/example.i
https://github.com/swig/swig/tree/master/Lib/lua

- Renamed yaml-lua > yaml_lua
- Exposed as many yaml-cpp objects as i could
- Temp fixed many errors by excluding some headers from wrapper
TODO :
- Explore yaml-cpp userdata as-is
- swig templates
- convert to lua tables
*/

%module yaml_lua

%{
#include "yaml_lua/yaml_lua.h"
#include "yaml-cpp/anchor.h"
#include "yaml-cpp/binary.h"
#include "yaml-cpp/depthguard.h"
#include "yaml-cpp/dll.h"
#include "yaml-cpp/emitfromevents.h"
#include "yaml-cpp/emitter.h"
#include "yaml-cpp/emitterdef.h"
#include "yaml-cpp/emittermanip.h"
#include "yaml-cpp/emitterstyle.h"
#include "yaml-cpp/eventhandler.h"
#include "yaml-cpp/exceptions.h"
#include "yaml-cpp/mark.h"
#include "yaml-cpp/noexcept.h"
#include "yaml-cpp/null.h"
#include "yaml-cpp/ostream_wrapper.h"
#include "yaml-cpp/parser.h"
#include "yaml-cpp/stlemitter.h"
#include "yaml-cpp/traits.h"
#include "yaml-cpp/yaml.h"

#include "yaml-cpp/contrib/anchordict.h"
#include "yaml-cpp/contrib/graphbuilder.h"

#include "yaml-cpp/node/convert.h"
#include "yaml-cpp/node/emit.h"
#include "yaml-cpp/node/impl.h"
#include "yaml-cpp/node/iterator.h"
#include "yaml-cpp/node/node.h"
#include "yaml-cpp/node/parse.h"
#include "yaml-cpp/node/ptr.h"
#include "yaml-cpp/node/type.h"

#include "yaml-cpp/node/detail/impl.h"
#include "yaml-cpp/node/detail/iterator.h"
#include "yaml-cpp/node/detail/iterator_fwd.h"
#include "yaml-cpp/node/detail/memory.h"
#include "yaml-cpp/node/detail/node.h"
#include "yaml-cpp/node/detail/node_data.h"
#include "yaml-cpp/node/detail/node_iterator.h"
#include "yaml-cpp/node/detail/node_ref.h"

%}

%include stl.i
%include exception.i
/*
namespace YAML {
    %template(NodeStrings) YAML::Node...;
}
*/
//%rename(Node) YAML::Node;
/*
// https://stackoverflow.com/questions/51146132/lua-swig-basics
%extend Node {
    std::string __tostring() {
        return std::string{"Vector ["}
            + std::to_string($self->x) + ", "
            + std::to_string($self->y) + ", "
            + std::to_string($self->z) + "]";
    }
};
*/

// avoid errors on class YAML_CPP_API Binary etc...
#define YAML_CPP_API 

// yaml_luaLUA_wrap.cxx(3661,5): error C2065: 'Mark' : identificateur non déclaré
using Mark = YAML::Mark;
using EMITTER_MANIP = YAML::EMITTER_MANIP;
//using const_node_iterator = node_iterator_base<const node>;

//namespace YAML {
//	%template(someLuaType) someCppType;
//}

%include stl.i
namespace std {
    %template(nodeMap) map<std::string,  YAML::Node>;
    %template(stringMap) map<std::string, std::string>;
}

%include "std_string.i"
%include "std_vector.i"
%include "std_map.i"
/*
 * Defining a typemap for std::map< std::string, std::string >
 */

%typemap(in) std::map< std::string, std::string >, const std::map< std::string, std::string > & (std::map< std::string, std::string > aux)
{
  lua_pushnil(L);
  
  while(lua_next(L, -2) != 0)
  {
    if(lua_isstring(L, -1) && lua_isstring(L, -2))
    {
      std::string key(lua_tostring(L, -2)), 
                  value(lua_tostring(L, -1)); 
      
      aux[key] = value;
    }
    
    lua_pop(L, 1);
  }
  
  $1 = &aux;
}

%typemap(out) const std::map< std::string, std::string >&
{
  lua_newtable(L);
  
  std::map<std::string, std::string>::const_iterator it;
    
  for(it = $result->begin(); it != $result->end(); ++it)
  {
    const char* key = it->first.c_str();
    const char* value = it->second.c_str();
    
    lua_pushstring(L, key);
    lua_pushstring(L, value);
    lua_settable(L, -3);
  }
  
  return 1;
}

%typemap(out) std::map< std::string, std::string >
{
  lua_newtable(L);
  
  std::map<std::string, std::string>::const_iterator it;
    
  for(it = $result.begin(); it != $result.end(); ++it)
  {
    const char* key = it->first.c_str();
    const char* value = it->second.c_str();
    
    lua_pushstring(L, key);
    lua_pushstring(L, value);
    lua_settable(L, -3);
  }
  
  return 1;
}

%typemap(out) std::map< std::string, std::string >&
{
  lua_newtable(L);
  
  std::map<std::string, std::string>::const_iterator it;
    
  for(it = $result->begin(); it != $result->end(); ++it)
  {
    const char* key = it->first.c_str();
    const char* value = it->second.c_str();
    
    lua_pushstring(L, key);
    lua_pushstring(L, value);
    lua_settable(L, -3);
  }
  
  return 1;
}

/*
void PushTable(lua_State*L, std::map<std::string,std::string> dongs)
{
	lua_newtable(L);
	std::map<std::string,std::string>::iterator it=dongs.begin();
	for(it;it!=dongs.end();it++)
	{
		//key
		lua_pushlstring(L,(&it->first)->data(),(&it->first)->size());

		//value
		lua_pushlstring(L,(&it->second)->data(),(&it->second)->size());

		// set the table entry
		lua_settable(L, -3);
	}
    // push the new table
    lua_pushvalue(L,-1);
}
*/

// error LNK2019: symbole externe non résolu "bool __cdecl YAML::IsNull(class YAML::Node const &)" (?IsNull@YAML@@YA_NAEBVNode@1@@Z) référencé dans la fonction _wrap_IsNull
// see yaml-cpp/null.h  IsNull // old API only
%{
     bool YAML::IsNull(const Node& node){return false;}
%}

%include "yaml_lua/yaml_lua.h"
%include "yaml-cpp/anchor.h"
%include "yaml-cpp/binary.h"
// %include "yaml-cpp/depthguard.h" // yaml_luaLUA_wrap.cxx(3661,5): error C2065: 'Mark' : identificateur non déclaré
%include "yaml-cpp/dll.h"
//%include "yaml-cpp/emitfromevents.h" //yaml_luaLUA_wrap.cxx(3859,5): error C2653: 'EmitterStyle' : n'est pas un nom de classe ni d'espace de noms
%include "yaml-cpp/emittermanip.h" // EMITTER_MANIP enum defined here must be included before emitter.h etc...
%include "yaml-cpp/emitter.h"
%include "yaml-cpp/emitterdef.h"
%include "yaml-cpp/emitterstyle.h"
%include "yaml-cpp/eventhandler.h"
//%include "yaml-cpp/exceptions.h" // yaml-cpp\exceptions.h(157): error : Syntax error in input(3).
%include "yaml-cpp/mark.h"
%include "yaml-cpp/noexcept.h"
%include "yaml-cpp/null.h"
%include "yaml-cpp/ostream_wrapper.h"
%include "yaml-cpp/parser.h"
%include "yaml-cpp/stlemitter.h"
// %include "yaml-cpp/traits.h" // static const bool value = decltype(test<S, T>(0))::value;
%include "yaml-cpp/yaml.h"

%include "yaml-cpp/contrib/anchordict.h"
%include "yaml-cpp/contrib/graphbuilder.h"

%include "yaml-cpp/node/type.h" // NodeType enum defined here must be included before node etc...
%include "yaml-cpp/node/convert.h"
%include "yaml-cpp/node/emit.h"
%include "yaml-cpp/node/impl.h"
%include "yaml-cpp/node/iterator.h"
%include "yaml-cpp/node/node.h"
%include "yaml-cpp/node/parse.h"
%include "yaml-cpp/node/ptr.h"

// %include "yaml-cpp/node/detail/impl.h" // yaml-cpp\node\detail\impl.h(29): error : Syntax error in input(1).

// const_node_iterator errors...
// %include "yaml-cpp/node/detail/iterator.h"
// %include "yaml-cpp/node/detail/iterator_fwd.h"
// %include "yaml-cpp/node/detail/memory.h"
// %include "yaml-cpp/node/detail/node.h"
// %include "yaml-cpp/node/detail/node_iterator.h" // const_node_iterator defined here must be included before node_data.h etc...
// %include "yaml-cpp/node/detail/node_data.h"
// %include "yaml-cpp/node/detail/node_ref.h"
