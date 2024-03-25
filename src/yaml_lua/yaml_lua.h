/*
* yaml-cpp helper
* using stl containers with Option3 : asMap
* 
* Option1 :
* use a map with string keys with the form [parent.child] = value
* convert it to a lua table
* 
* Option2 :
* Provide as* mmethod for each YAML::NodeType
* Fix the std::map lua typemap
* https://otland.net/threads/send-std-map-to-lua-as-a-table.274993/
* https://stackoverflow.com/questions/40451586/creating-new-classes-members-at-run-time-in-scripting-languages-used-in-c
* https://github.com/optimusgisit/terralib/blob/9b49ccebd5cc483471998a89fb656ba3c1633b92/src/terralib/binding/swig/lua/typemaps.i#L20
* 
* Option3 : asMap
* use a typemap to translate std::map<std::string, std::string>
* asMap is recursive but translates eveything to string, flattening the map std::map<std::string, std::string>
* In the submited yaml file, on on hierarchy case was found (an empty array)
* In case of vector value, the stringstream generated a comma separated string.
* Hierarchy use cases are to be defined...
* There are clashing key names in cooke-lens.yaml
* root level nodes should be separated by --- ? (i don't know yaml...)
*/
#include "yaml-cpp/yaml.h"
#include <string>
#include <iostream>
#include <fstream>


class yaml {
private:
	//int verbosity = 1;
	int verbosity = 0;
	YAML::Node root;
	std::vector<YAML::Node> nodesVec;
	std::map<std::string, YAML::Node> nodesMap;
	int documentCount;

public:

	int getNumberOfDocuments(std::string file) {
		std::ifstream infile(file);
		std::string line;
		int result = 0;
		if (infile.is_open())
		{
			while (getline(infile, line))
			{
				if (line == "---")
					result++;
			}
			infile.close();
		}
		return result;
	}

	YAML::Node load(std::string file, int document = 0) {
		documentCount = getNumberOfDocuments(file);
		if (document > documentCount) {
			std::cerr << "YAML::Node load:  document " << document << " exceed the number of documents " << documentCount << "found in yaml file " << file << std::endl;
		}
		if (verbosity) std::cout << "YAML::Node load document " << document << "/" << documentCount << std::endl;
		root = YAML::LoadAllFromFile(file)[document];
		return root;
	}

	std::map<std::string, std::string> asMap(YAML::Node node, std::string parent= "") {
		std::map<std::string, std::string> result;
		std::vector<YAML::Node> tmpVec;
		std::string tmpString;
		std::stringstream tmpSs;
		std::map<std::string, std::string> tmpMap;
		std::string path;
		std::string key;
		YAML::Node key_node;
		YAML::Node value_node;
		for (auto kv : node) {
			key_node = kv.first;
			value_node = kv.second;
			key = key_node.as<std::string>();
			if(parent.empty())
				path = key;
			else
				path = parent + "." + key;
			if (verbosity) std::cout << "asMap key: " << key << std::endl;
			if (verbosity) std::cout << "asMap path: " << path << std::endl;
			key = path;
			switch (value_node.Type()) {
				case YAML::NodeType::Scalar:
					tmpString = value_node.as< std::string >();
					result[key] = tmpString;
					if(verbosity) std::cout << "asMap kv Scalar: " << result[key] << std::endl;
					break;
				case YAML::NodeType::Sequence:
					tmpSs.clear();
					for (auto v : asSequence(value_node)) {
						if(v.IsScalar())
							tmpSs << v.as< std::string >() << ",";
					}
					if(tmpSs.str().size() > 0)
						result[key] = tmpSs.str();
					else
						result[key] = "";
					if (verbosity) std::cout << "asMap kv Sequence: " << result[key] << std::endl;
					break;
				case YAML::NodeType::Map:
					if (verbosity) std::cout << "asMap value_node.Type() Map: " << value_node.Type() << std::endl;
					//tmpMap = asMap(value_node, key);
					tmpMap = asMap(value_node, path);
					result.insert(tmpMap.begin(), tmpMap.end());
					break;
				case YAML::NodeType::Null:
					if (verbosity) std::cout << "asMap value_node.Type() Null: " << value_node.Type() << std::endl;
					break;
				case YAML::NodeType::Undefined:
					if (verbosity) std::cout << "asMap value_node.Type() Undefined: " << value_node.Type() << std::endl;
					break;
				default:
					if (verbosity) std::cout << "asMap value_node.Type() unknown: " << value_node.Type() << std::endl;
					break;
			}
		}
		return result;
	}

	std::vector<YAML::Node> asSequence(YAML::Node node) {
		std::vector<YAML::Node> result;
		for (auto it = node.begin(); it != node.end(); ++it) {
			const auto& child_node = *it;
			result.push_back(child_node);
		}
		return result;
	}

	std::string asString(YAML::Node node) {
		return node.as<std::string>();
	}

	std::string asScalar(YAML::Node node) {
		return node.as<std::string>();
	}

	void dumpFile(std::string file) {
		int docs = getNumberOfDocuments(file);
		int indent = 0;
		for (int d = 0; d < docs; d++) {
			std::cout << std::string(indent, '\t') << "dumpFile: " << file << " doc: " << d << std::endl;
			auto root = load(file, d);
			dumpNode(root, indent);
		}
	}

	void dumpNode(YAML::Node node, int indent = 0) {
		std::string key;
		YAML::Node key_node;
		YAML::Node value_node;
		if (node.IsMap()) {
			indent += 1;
			for (auto kv : node) {
				key_node = kv.first;
				std::cout << std::string(indent, '\t') << "map: " << key_node.as<std::string>() << std::endl;
				dumpNode(kv.second, indent);
			}
		}
		else if (node.IsSequence()) {
			indent += 1;
			for (auto v : asSequence(node)) dumpNode(v, indent);
		}
		else if (node.IsScalar()) {
			std::cout << std::string(indent, '\t') << "scalar: " << node.as< std::string >() << std::endl;
		}
	}

};
