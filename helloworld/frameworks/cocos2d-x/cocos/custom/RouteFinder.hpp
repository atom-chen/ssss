//
//  RouteFinder.hpp
//  helloworld
//
//  Created by reid on 16/5/9.
//
//

#ifndef RouteFinder_hpp
#define RouteFinder_hpp

#include <stdio.h>
#include "cocos2d.h"
#include "base.h"
#include "Mutex.h"
#include "tinyxml2/tinyxml2.h"
#include <memory>
#include <set>

namespace sgzj {
    
    class Line : public cocos2d::Ref {
    public:
        Line(cocos2d::Point &start, cocos2d::Point &end);
        ~Line();
        
//        inline void setName(std::string &name) {m_name = name;};
//        inline const std::string &getName() {return m_name;};
        inline cocos2d::Point &startPoint() {return m_startPoint;};
        inline cocos2d::Point &endPoint() {return m_endPoint;};
        static Line *create(cocos2d::Point &start, cocos2d::Point &end);
        void relateTo(const std::shared_ptr<Line> &line) { m_relation.insert(line);};
        std::set<std::shared_ptr<Line>> relatedLines() {return m_relation;};
        void removeRelation(Line *line);
        void clear();
        bool isTheSame(Line *line) {return this == line;};
        
    private:
        cocos2d::Point m_startPoint;
        cocos2d::Point m_endPoint;
        std::set<std::shared_ptr<Line>> m_relation;
//        std::vector<std::shared_ptr<Line> > m_relation;
//        std::string m_name;
    };
    
    class RouteNode {
    public:
        typedef std::vector<std::shared_ptr<RouteNode> > routeList;
       
        typedef std::vector<std::shared_ptr<Line> > lineList;
        RouteNode(lineList &lines, int type);
        ~RouteNode();
        
        bool isMarked() {return m_mark;};
        bool isContainPoint(cocos2d::Point &point);
        bool isTheSame(RouteNode *node) {return this == node;};
        bool isPointInLine(cocos2d::Point &point);
        bool isFindDone() {return m_findDone;};
//        float routeValueWithPoint(cocos2d::Point &start, cocos2d::Point &end);
//        cocos2d::Point findInPoint(cocos2d::Point &start, cocos2d::Point &end, std::shared_ptr<Line> &line);
        void updateValue1(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node, int idx);
        void updateValue(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node, int idx);
        void updateValue2(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node);
        void updateValue4(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node);
        
        void updateValueWithList21(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion);
        
        void updateValueWithList22(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion);
        
        void updateValueWithList2(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion);
        
        void updateValueWithList41(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion);
        
        void updateValueWithList42(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion);
        
        void updateValueWithList4(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion);
        
        std::shared_ptr<RouteNode> findNextRouteNode(cocos2d::Point &start, cocos2d::Point &end, cocos2d::Point *intersect);
        lineList &allLines() {return m_lineList;};
        void clear();
        void reset();
        
        
//        void setValue(float value) {m_value = value;};
//        void setFromList(std::vector<std::shared_ptr<RouteNode>> &list) {m_fromList = list;};
        
//        void setFrom(std::shared_ptr<RouteNode> &from) {m_from = from;};
        void setStartPoint(cocos2d::Point &point) {m_startPoint = point;};
//        std::weak_ptr<RouteNode> &from() {return m_from;};
        std::vector<std::shared_ptr<RouteNode>> &fromList() {return m_fromList;};
        float value() {return m_value;};
        float value1() {return m_value1;};
        cocos2d::Point &startPoint() {return m_startPoint;};
        void addInflexion(cocos2d::Point &p) {m_inflexion.push_back(p);};
        std::vector<cocos2d::Point> &inflexionList() {return m_inflexion;};
        
        void mark() {m_mark = true;};
        int type() {return m_type;};
        
//      routeMap neighbours() {return m_neighbours;};
        static const int kBuildMove = 1;
        static const int kNormalMove = 0;
        
    private:
        lineList m_lineList;
//        routeMap m_neighbours;
        bool m_mark;
//        std::weak_ptr<RouteNode> m_from;
        float m_value;
        float m_value1;
        int m_type;
        cocos2d::Point m_startPoint;
        cocos2d::Point m_topPoint;
        cocos2d::Point m_bottomPoint;
        cocos2d::Point m_fromTop;
        cocos2d::Point m_fromBot;
        
        bool m_findDone;
        std::vector<std::shared_ptr<RouteNode>> m_fromList;
        std::vector<cocos2d::Point> m_inflexion;
        
    };
    
//    class RouteInfo {
//    public:
//        RouteInfo():m_value(0){};
//        ~RouteInfo(){};
//        void setRouteNode(std::shared_ptr<RouteNode> &node) {m_node = node;};
//        void setFrom(std::shared_ptr<RouteInfo> &from) {m_from = from;};
//        void setInPoint(cocos2d::Point &point) {m_inPoint = point;};
////        void setOutPoint(cocos2d::Point &point) {m_outPoint = point;};
//        void setValue(float value) {m_value = value;};
//        
//        std::shared_ptr<RouteNode> routeNode() {return m_node;};
//        std::shared_ptr<RouteInfo> from() {return m_from;};
//        cocos2d::Point inPoint() {return m_inPoint;};
////        cocos2d::Point outPoint() {return m_outPoint;};
//        float value() {return m_value;};
//        
//    private:
//        std::shared_ptr<RouteNode> m_node;
//        std::shared_ptr<RouteInfo> m_from;
//        cocos2d::Point m_inPoint;
//        
//        float m_value;
//    };
    
    
    class RouteFinder : public cocos2d::Ref {
    public:
        typedef std::vector<cocos2d::Point > pointList;
        typedef cocos2d::Vector<Line *> pathList;
    
        void findRoute(cocos2d::Point &point);
        void setStartPoint(cocos2d::Point &point);
        cocos2d::Point startFindPoint();
        cocos2d::Point endFindPoint();
        
        void clear();
        
        pathList &finalRoutePath();
        pathList &currentRoutePath();
        int findResult() {return m_findResult;};
        
        static RouteFinder *create();
        
    private:
        RouteNode::routeList findRouteNodeList(cocos2d::Point &start, cocos2d::Point &end);
        void fillStraightRoute(cocos2d::Point &start, cocos2d::Point &end);
        
        std::shared_ptr<RouteNode> findRoutePath(cocos2d::Point &start, cocos2d::Point &end);
        void doFindRoute();
        
        cocos2d::Point m_startPoint;
        cocos2d::Point m_endPoint;
        cocos2d::Point m_findStart;
        cocos2d::Point m_findEnd;
        
        RouteNode::lineList m_pathList;
        pathList m_pathList1;
        int m_findResult;
        
        lrb::base::MutexLock m_mutex;
//        lrb::base::MutexLock m_mutex1;
        lrb::base::MutexLock m_mutex2;
    };
    
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
    
    class RouteData : public cocos2d::Ref {
    public:
        std::shared_ptr<RouteNode> findRouteNode(cocos2d::Point &point);
        RouteNode::routeList routeNodeForLine(std::shared_ptr<Line> &line);
//        std::shared_ptr<RouteNode> findStartNode(cocos2d::Point &start);
        
        void loadRouteConfig(std::string &path);
        void loadRouteData(std::string &path);
        
        static RouteData *getInstance();
        void reset();
        void clear();
        
        void debugDraw(cocos2d::DrawNode *node);
        void generateConfig(std::string &path);
        
    private:
        void processRobber(std::vector<tinyxml2::XMLElement *> &vec, std::string &luaTxt);
        void processGate(std::vector<tinyxml2::XMLElement *> &vec, std::string &luaTxt);
        void processMoveable(tinyxml2::XMLElement *ele, tinyxml2::XMLElement *root, tinyxml2::XMLDocument &doc);
        void processBuild(tinyxml2::XMLElement *ele, tinyxml2::XMLElement *root, tinyxml2::XMLDocument &doc);
        void processRoot(tinyxml2::XMLElement *ele);
        
        void processBuildMove(tinyxml2::XMLElement *ele);
        void processNormalMove(tinyxml2::XMLElement *ele);
        
        void destroyNode(std::shared_ptr<RouteNode> &node);
        void fillRouteMap(std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node);
        void addRouteNode(std::vector<cocos2d::Point> &vec, int type = 0);
        cocos2d::Point gridCenterPos(long x, long y);
        
        typedef std::map<std::shared_ptr<Line>, std::shared_ptr<RouteNode> > routeMap;
        routeMap m_routeMap;
        RouteNode::routeList m_routeList;
        RouteNode::lineList m_lineList;
//        std::shared_ptr<Line> m_lineCheck;
        RouteNode::lineList m_lineList1;
        float m_gridHeight;
        float m_gridWidth;
        float m_gridNum;
        float m_xoff;
        float m_yoff;
        int m_ident;
        std::string m_bg;
        
        static const int kmapW = 2048;
        static const int kmapH = 1536;
    };
    
}


#endif /* RouteFinder_hpp */

