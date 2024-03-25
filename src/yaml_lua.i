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

// error LNK2019: symbole externe non résolu "bool __cdecl YAML::IsNull(class YAML::Node const &)" (?IsNull@YAML@@YA_NAEBVNode@1@@Z) référencé dans la fonction _wrap_IsNull
// see yaml-cpp/null.h  IsNull // old API only
%{
     bool YAML::IsNull(const Node& node){return false;}
%}

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
