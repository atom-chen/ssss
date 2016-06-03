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
#include <memory>

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
        void relateTo(std::shared_ptr<Line> &line) { m_relation.push_back(line);};
        std::vector<std::shared_ptr<Line>> relatedLines() {return m_relation;};
        
    private:
        cocos2d::Point m_startPoint;
        cocos2d::Point m_endPoint;
        std::vector<std::shared_ptr<Line> > m_relation;
//        std::string m_name;
    };
    
    class RouteNode {
    public:
        typedef std::vector<std::shared_ptr<RouteNode> > routeList;
       
        typedef std::vector<std::shared_ptr<Line> > lineList;
        RouteNode(lineList &lines);
        ~RouteNode();
        
        bool isMarked() {return m_mark;};
        bool isContainPoint(cocos2d::Point &point);
        bool isTheSame(RouteNode *node) {return this == node;};
        bool isPointInLine(cocos2d::Point &point);
        float routeValueWithPoint(cocos2d::Point &start, cocos2d::Point &end);
        cocos2d::Point findInPoint(cocos2d::Point &start, cocos2d::Point &end, std::shared_ptr<Line> &line);
        
        std::shared_ptr<RouteNode> findNextRouteNode(cocos2d::Point &start, cocos2d::Point &end, cocos2d::Point *intersect);
        lineList allLines() {return m_lineList;};
        void clear();
        void reset();
        void mark() {m_mark = true;};
        
//        routeMap neighbours() {return m_neighbours;};
        
    private:
        lineList m_lineList;
//        routeMap m_neighbours;
        bool m_mark;
    };
    
    class RouteInfo {
    public:
        void setRouteNode(std::shared_ptr<RouteNode> &node) {m_node = node;};
        void setFrom(std::shared_ptr<RouteInfo> &from) {m_from = from;};
        void setInPoint(cocos2d::Point &point) {m_inPoint = point;};
//        void setOutPoint(cocos2d::Point &point) {m_outPoint = point;};
        void setValue(float value) {m_value = value;};
        
        std::shared_ptr<RouteNode> routeNode() {return m_node;};
        std::shared_ptr<RouteInfo> from() {return m_from;};
        cocos2d::Point inPoint() {return m_inPoint;};
//        cocos2d::Point outPoint() {return m_outPoint;};
        float value() {return m_value;};
        
    private:
        std::shared_ptr<RouteNode> m_node;
        std::shared_ptr<RouteInfo> m_from;
        cocos2d::Point m_inPoint;
        
        float m_value;
    };
    
    class PathNode {
    public:
        bool isContainNode(std::shared_ptr<RouteNode> &node);
        
//        void addPathValue(float value) {m_pathValue += value;};
        void addRouteNode(std::shared_ptr<RouteNode> &node) {m_nodeList.push_back(node);};
        void addLine(Line *line) {m_lineList.pushBack(line);};
        RouteNode::routeList routeNodeList() {return m_nodeList;};
        
    private:
//        float m_pathValue;
        cocos2d::Vector<Line *> m_lineList;
        RouteNode::routeList m_nodeList;
    };
    
    class RouteFinder : public cocos2d::Ref {
    public:
        typedef std::vector<cocos2d::Point > pointList;
        typedef cocos2d::Vector<Line *> pathList;
        void findRoute(cocos2d::Point &point);
        void addStartPoint(cocos2d::Point &point);
        
        void clear();
        
        pathList currentRoutePath();
        RouteNode::routeList routeNodeForLine(std::shared_ptr<Line> &line);
        
        
    private:
        RouteNode::routeList findRouteNodeList(cocos2d::Point &start, cocos2d::Point &end);
        void fillStraightRoute(cocos2d::Point &point);
        
        void fillRouteMap(std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node);
        std::shared_ptr<RouteNode> findRouteNode(cocos2d::Point &point);
        std::shared_ptr<RouteInfo> findRoutePath(cocos2d::Point &start, cocos2d::Point &end);
        void doFindRoute();
        void addRouteNode(std::vector<cocos2d::Point> &vec);
        RouteNode::routeList m_routeList;
        pointList m_startList;
        pointList m_endList;
        pathList m_pathList;
        pathList m_pathList1;
        typedef std::map<std::shared_ptr<Line>, std::shared_ptr<RouteNode> > routeMap;
        routeMap m_routeMap;
        RouteNode::lineList m_lineList;
        
        lrb::base::MutexLock m_mutex;
        lrb::base::MutexLock m_mutex1;
        lrb::base::MutexLock m_mutex2;
    };
    
    class RouteData : public cocos2d::Ref {
    public:
        void loadRouteConfig(std::string &path);
        static RouteData *getInstance();
        void reset();
    private:
        
    };
    
}


#endif /* RouteFinder_hpp */

