#include "tinyxml2.h"
#include <iostream>
#include <stdio.h>
#include <string>
#include <regex.h>

const char *pattern = "^([-+]?([0-9]+)|([0-9]+\\.[0-9]+))|(0x[0-9a-f]+)$";
regex_t reg;
regmatch_t pmatch[1];

static void compileRegex()
{
	int flags = REG_EXTENDED|REG_ICASE|REG_NOSUB;
	int status = regcomp(&reg, pattern, flags);
	if (status != 0) {
		std::cout << "compile regex failed" << std::endl;
	}
}

static bool isNumValue(std::string &val)
{
	int status = regexec(&reg, val.c_str(), 1, pmatch, 0);
	return status == 0;
}

static void processElement(const tinyxml2::XMLElement *ele, std::string &luaTxt)
{
	const char *txtValue = ele->GetText();
	if (txtValue != NULL) {
		luaTxt += "txtValue=\"";
		luaTxt += txtValue;
		luaTxt += "\",";
	}

	const tinyxml2::XMLAttribute *att = ele->FirstAttribute();
	while (att) {
		luaTxt += att->Name();
		luaTxt += "=";
		std::string val = att->Value();
		if ((val.compare("false") == 0) || (val.compare("true") == 0) || isNumValue(val)) {
			luaTxt += att->Value();
		} else {
			luaTxt += "\"";
			luaTxt += att->Value();
			luaTxt += "\"";
		}
		
		luaTxt += ",";
		att = att->Next();
	}
	
	const tinyxml2::XMLElement *child = ele->FirstChildElement();
	bool flag = child != NULL;
	if (flag) {
		luaTxt += "valueList={";
	}

	while (child) {
		luaTxt += "{";
		luaTxt += child->Name();
		luaTxt += "={";
		processElement(child, luaTxt);
		luaTxt += "}},";
		child = child->NextSiblingElement();
	}
	if (flag) {
		luaTxt += "}";
	}

}


int main(int argc, char **argv)
{
	if (argc < 3) {
		std::cout << "wrong arguments: " << argc << " need 3" << std::endl;
		return 0;
	}

	std::cout << "generating " << argv[1] << std::endl;
	compileRegex();	
	
	std::string path(argv[1]);
	size_t idx = path.rfind("/");
	size_t idx1 = path.rfind(".");
	std::string fileName = path.substr(idx+1, idx1-idx-1);
	
	tinyxml2::XMLDocument tinyDoc;
	tinyDoc.LoadFile(argv[1]);
	
	std::string luaTxt = "local C={";
	
	tinyxml2::XMLElement *root = tinyDoc.RootElement();
	processElement(root, luaTxt);
	
	luaTxt += "}\nreturn C";
	
	std::string writePath(argv[2]);
	std::string luaPath = writePath + fileName+".lua";

	FILE *fp = fopen(luaPath.c_str(), "wb+");
	fwrite(luaTxt.c_str(), luaTxt.size(), 1, fp);
	fflush(fp);

}
