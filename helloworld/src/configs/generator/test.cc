#include <iostream>
#include <stdio.h>
#include <string.h>
#include <string>
#include <vector>
#include <set>
#include <float.h>
#include "tinyxml2.h"
#include "Vec2.h"

#define MAX(x,y) (((x) < (y)) ? (y) : (x))

static float m_gridHeight = 0, m_gridWidth = 0, m_gridNum = 0, m_xoff = 0, m_yoff = 0;
static int m_ident = 0;
std::string m_bg;
static const int kmapW = 2048, kmapH = 1536;

class Grid {
	public:
		Grid():x(0),y(0),z(0),a(0),mark(false) {};
		~Grid() {};
		int x;
		int y;
		int z;
		int a;
		bool mark;

};

static std::vector<Grid> mergeGrid(std::vector<Grid> &vec) {
//    CCLOG("34");
    std::sort(vec.begin(), vec.end(), [](Grid &a, Grid &b){if (a.x == b.x) return a.y < b.y; return a.x < b.x;});
    std::vector<Grid> vec1;
    for (auto &grid : vec) {
        if (vec1.empty()) {
            Grid g;
            g.x = grid.x;
            g.y = grid.y;
            g.z = grid.y;
            g.a = grid.x;
            vec1.push_back(std::move(g));
            continue;
        }
        
        Grid &g = vec1.back();
        if (g.x == grid.x && grid.y == g.z + 1) {
            g.z = grid.y;
        } else {
            Grid g1;
            g1.a = grid.x;
            g1.x = grid.x;
            g1.y = grid.y;
            g1.z = grid.y;
            vec1.push_back(std::move(g1));
        }
    }
    
    std::vector<Grid> vec2;
    
    for (auto iter = vec1.begin(); iter != vec1.end(); ++iter) {
        if (iter->mark)
            continue;
        
        for (auto iter1 = iter+1;iter1!=vec1.end();++iter1) {
            if (iter1->x > iter->a + 1) {
                break;
            } else if (iter1->x == iter->a) {
                continue;
            }
            
            if (iter1->y == iter->y && iter1->z == iter->z) {
                iter1->mark = true;
                iter->a = iter1->x;
            }
        }
        Grid g;
        g.x = iter->x;
        g.y = iter->y;
        g.z = iter->z;
        g.a = iter->a;
        vec2.push_back(std::move(g));
    }
    
    return vec2;
}


static std::vector<Grid> gridFromElement(tinyxml2::XMLElement *ele)
{
//    CCLOG("35");
    char num[4] = {0};
    int idx = 0;
    std::vector<Grid> vec;
    const char *ptr = ele->GetText();
    while(*ptr) {
        char c = *ptr;
        if (c == ',') {  // 逗号
            num[idx] = 0;
            Grid p;
            p.x = static_cast<int>(strtol(num, 0, 0));
            vec.push_back(std::move(p));
            idx = 0;
        } else if (c == '|') { // 垂线
            num[idx] = 0;
            Grid &p = vec.back();
            p.y = static_cast<int>(strtol(num, 0, 0));
            idx = 0;
        } else {
            num[idx] = c;
            ++idx;
        }
        
        ++ptr;
    }
    if (idx > 0) {
        num[idx] = 0;
        Grid &p = vec.back();
        p.y = static_cast<int>(strtol(num, 0, 0));
    }
    
    return mergeGrid(vec);
}

static cocos2d::Point gridCenterPos(long x, long y)
{
//    CCLOG("31");
    cocos2d::Point p;
    
    float totalH = m_gridHeight * m_gridNum;
    float hw = m_gridWidth/2;
    float hh = m_gridHeight/2;
    float startX = m_xoff + hw;
    float startY = kmapH - m_yoff - totalH/2;
    p.x = startX + hw * x + y*hw;
    p.y = startY + (x-y) * hh;
    
    return p;
}

static void processRobber(std::vector<tinyxml2::XMLElement *> &vec, std::string &luaTxt)
{
	//    CCLOG("32");
	luaTxt += "generals={";
	for (auto &ptr : vec) {
		luaTxt += "{";
		const tinyxml2::XMLAttribute *att = ptr->FirstAttribute();

		while (att) {
			if (std::strncmp(att->Name(), "iconClass", 9) == 0) {
				att = att->Next();
				continue;
			}

			luaTxt += att->Name();
			luaTxt += "=";
			luaTxt += att->Value();

			luaTxt += ",";
			att = att->Next();
		}

		const char *txt = ptr->GetText();
		char num[4] = {0};
		long x, y, idx = 0;
		while (*txt) {
			char c = *txt;
			if (c == ',') {
				num[idx] = 0;
				x = strtol(num, 0, 0);
				idx = 0;
			} else {
				num[idx] = c;
				++idx;
			}

			++txt;
		}
		num[idx] = 0;
		y = strtol(num, 0, 0);

		char nn[20];
		cocos2d::Point pos = gridCenterPos(x, y);
		luaTxt += "pos={x=";
		snprintf(nn, 20, "%.2f,y=%.2f",pos.x, pos.y);
		luaTxt += nn;
		luaTxt += "},";

		luaTxt += "},";

	}
	luaTxt += "},";
}

static void processGate(std::vector<tinyxml2::XMLElement *> &vec, std::string &luaTxt)
{
	//    CCLOG("33");
	luaTxt += "buildings={";
	for (auto &ptr : vec) {
		luaTxt += "{";
		const tinyxml2::XMLAttribute *att = ptr->FirstAttribute();
		float ox, oy;
		while (att) {
			if (std::strncmp(att->Name(), "ox", 2) == 0) {
				ox = att->FloatValue();
			} else if (std::strncmp(att->Name(), "oy", 2) == 0) {
				oy = att->FloatValue();
			} else if (std::strncmp(att->Name(), "icon", 4) == 0) {
				att = att->Next();
				continue;
			} else {
				luaTxt += att->Name();
				luaTxt += "=";
				luaTxt += att->Value();
				luaTxt += ",";
			}
			att = att->Next();
		}

		const char *txt = ptr->GetText();
		char num[4] = {0};
		long x, y, idx = 0;
		while (*txt) {
			if (*txt == ',') {
				num[idx] = 0;
				x = strtol(num, 0, 0);
				idx = 0;
			} else {
				num[idx] = *txt;
				++idx;
			}

			++txt;
		}
		num[idx] = 0;
		y = strtol(num, 0, 0);

		cocos2d::Point pos = gridCenterPos(x, y);
		char nn[20];
		snprintf(nn, 20, "%.2f,y=%.2f",pos.x+ox, pos.y-oy);
		luaTxt += "pos={x=";
		luaTxt += nn;
		luaTxt += "},";

		luaTxt += "},";
	}
	luaTxt += "},";
}

static void processMoveable(tinyxml2::XMLElement *ele, tinyxml2::XMLElement *root, tinyxml2::XMLDocument &doc)
{
	//    CCLOG("36");
	std::vector<Grid> vec1 = gridFromElement(ele);

	float hw = m_gridWidth/2;
	float hh = m_gridHeight/2;
	char nn[20] = {0};

	for (auto &grid : vec1) {
		cocos2d::Point p1 = gridCenterPos(grid.x, grid.y);
		cocos2d::Point p2 = gridCenterPos(grid.x, grid.z);
		cocos2d::Point p3 = gridCenterPos(grid.a, grid.y);
		cocos2d::Point p4 = gridCenterPos(grid.a, grid.z);

		snprintf(nn, 20, "%.2f,%.2f", p1.x-hw, p1.y);
		tinyxml2::XMLElement *rect = doc.NewElement("rectAngle");

		tinyxml2::XMLElement *point = doc.NewElement("point");
		point->LinkEndChild(doc.NewText(nn));
		rect->LinkEndChild(point);

		snprintf(nn, 20, "%.2f,%.2f", p3.x, p3.y + hh);
		point = doc.NewElement("point");
		point->LinkEndChild(doc.NewText(nn));
		rect->LinkEndChild(point);

		snprintf(nn, 20, "%.2f,%.2f", p4.x+hw, p4.y);
		point = doc.NewElement("point");
		point->LinkEndChild(doc.NewText(nn));
		rect->LinkEndChild(point);

		snprintf(nn, 20, "%.2f,%.2f", p2.x, p2.y-hh);
		point = doc.NewElement("point");
		point->LinkEndChild(doc.NewText(nn));
		rect->LinkEndChild(point);
		root->LinkEndChild(rect);
	}
}


static void processBuild(tinyxml2::XMLElement *ele, tinyxml2::XMLElement *root, tinyxml2::XMLDocument &doc)
{
	//    CCLOG("37");
	std::vector<Grid> vec1 = gridFromElement(ele);

	float hw = m_gridWidth/2;
	float hh = m_gridHeight/2;
	char nn[20] = {0};
	for (auto &grid :vec1) {
		cocos2d::Point p1 = gridCenterPos(grid.x, grid.y);
		cocos2d::Point p2 = gridCenterPos(grid.x, grid.z);
		cocos2d::Point p3 = gridCenterPos(grid.a, grid.y);
		cocos2d::Point p4 = gridCenterPos(grid.a, grid.z);

		snprintf(nn, 20, "%.2f,%.2f", p1.x-hw, p1.y);
		tinyxml2::XMLElement *rect = doc.NewElement("Build");
		root->LinkEndChild(rect);
		tinyxml2::XMLElement *point = doc.NewElement("point");
		point->LinkEndChild(doc.NewText(nn));
		rect->LinkEndChild(point);

		snprintf(nn, 20, "%.2f,%.2f", p3.x, p3.y + hh);
		point = doc.NewElement("point");
		point->LinkEndChild(doc.NewText(nn));
		rect->LinkEndChild(point);

		snprintf(nn, 20, "%.2f,%.2f", p4.x+hw, p4.y);
		point = doc.NewElement("point");
		point->LinkEndChild(doc.NewText(nn));
		rect->LinkEndChild(point);

		snprintf(nn, 20, "%.2f,%.2f", p2.x, p2.y-hh);
		point = doc.NewElement("point");
		point->LinkEndChild(doc.NewText(nn));
		rect->LinkEndChild(point);

	}
}

static void processRoot(tinyxml2::XMLElement *ele)
{
	const tinyxml2::XMLAttribute *att = ele->FirstAttribute();
	int w = 0;
	int h = 0;
	while (att) {
		if (std::strncmp(att->Name(), "background", 10) == 0) {
			m_bg = att->Value();
		} else if (std::strncmp(att->Name(), "gridHeight", 10) == 0) {
			m_gridHeight = att->FloatValue();
		} else if (std::strncmp(att->Name(), "gridWidth", 9) == 0) {
			m_gridWidth = att->FloatValue();
		} else if (std::strncmp(att->Name(), "height", 6) == 0) {
			h = att->IntValue();
		} else if (std::strncmp(att->Name(), "width", 5) == 0) {
			w = att->IntValue();
		} else if (std::strncmp(att->Name(), "xOffset", 7) == 0) {
			m_xoff = att->FloatValue();
		} else if (std::strncmp(att->Name(), "ident", 5) == 0) {
			m_ident = att->IntValue();
		} else if (std::strncmp(att->Name(), "yOffset", 7) == 0) {
			m_yoff = att->FloatValue();
		}

		att = att->Next();
	}
	m_gridNum = MAX(w, h);
}


int main (int argc, char **argv)
{
	if (argc < 3)
		return 0;

	std::cout << "generating " << argv[1] << std::endl;

	tinyxml2::XMLDocument tinyDoc;
	tinyDoc.LoadFile(argv[1]);

	tinyxml2::XMLElement *root = tinyDoc.RootElement();
	processRoot(root);

	std::string path(argv[1]);
	size_t idx = path.rfind("/");
	size_t idx1 = path.rfind(".");
	std::string fileName = path.substr(idx+1, idx1-idx-1);
	char nn[6] = {0};
	snprintf(nn, 6, "%d", m_ident);
	size_t idx4 = m_bg.rfind("/");
	size_t idx5 = m_bg.rfind(".");
	std::string luaTxt = "local C={id=";
	luaTxt += nn;
	luaTxt +=",mapPic=\""+m_bg.substr(idx4+1, idx5-idx4-1)+"\",";

	tinyxml2::XMLElement *ele = root->FirstChildElement();
	std::vector<tinyxml2::XMLElement *> rob;
	std::vector<tinyxml2::XMLElement *> gate;
	tinyxml2::XMLDocument wDoc;
	tinyxml2::XMLDeclaration *dec = wDoc.NewDeclaration("xml version=\"1.0\" encoding=\"utf-8\"");
	wDoc.LinkEndChild(dec);
	tinyxml2::XMLElement *rt = wDoc.NewElement("move");
	wDoc.LinkEndChild(rt);
	while (ele) {
		if (std::strncmp(ele->Name(), "Robber", 6) == 0) {
			rob.push_back(ele);
		} else if (std::strncmp(ele->Name(), "Gate", 4) == 0) {
			gate.push_back(ele);
		} else if (std::strncmp(ele->Name(), "Movable", 7) == 0) {
			processMoveable(ele, rt, wDoc);
		} else if (std::strncmp(ele->Name(), "Build", 6) == 0) {
			processBuild(ele, rt, wDoc);
		}
		ele = ele->NextSiblingElement();
	}
	processRobber(rob, luaTxt);
	processGate(gate, luaTxt);
	luaTxt += "}\nreturn C";

	std::string writePath = argv[2];
	std::string xmlPath = writePath+"move/"+path.substr(idx+1);
	//std::cout << xmlPath << std::endl;
	wDoc.SaveFile(xmlPath.c_str());

	std::string luaPath = writePath+fileName+".lua";

	FILE *fp = fopen(luaPath.c_str(), "wb+");
	fwrite(luaTxt.c_str(), luaTxt.size(), 1, fp);
	fflush(fp);


}
