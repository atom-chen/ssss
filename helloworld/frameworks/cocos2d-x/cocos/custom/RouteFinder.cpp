//
//  RouteFinder.cpp
//  helloworld
//
//  Created by reid on 16/5/9.
//
//

#include "RouteFinder.hpp"

#include <functional>
#include "Caculater.hpp"
#include "tinyxml2/tinyxml2.h"
#include "platform/CCFileUtils.h"
#include <regex.h>


using namespace sgzj;

static lrb::base::MutexLock g_mutex;

Line::Line(cocos2d::Point &start, cocos2d::Point &end):
    m_startPoint(start),
    m_endPoint(end)
{

}

Line::~Line()
{
    
}

Line *Line::create(cocos2d::Point &start, cocos2d::Point &end)
{
    Line *line = new Line(start, end);
    line->autorelease();
    return line;
}


RouteNode::RouteNode(RouteNode::lineList &lines):
    m_lineList(lines)
{
    
}

RouteNode::~RouteNode()
{
    CCLOG("routeNode instruct");
}

bool RouteNode::isContainPoint(cocos2d::Point &point)
{

    for (auto &line : m_lineList) {
        cocos2d::Point &start = line->startPoint();
        cocos2d::Point &end = line->endPoint();
        
        float c = (end-start).cross(point-start);
        
        if (c > 0)
            return false;
    }
    
    return true;
}

bool RouteNode::isPointInLine(cocos2d::Point &point)
{
    for (auto &line : m_lineList) {
        if (cocos2d::Point::isLineParallel(line->startPoint(), point, point, line->endPoint())) {
            return true;
        }
    }
    
    return false;
}

float RouteNode::routeValueWithPoint(cocos2d::Point &start, cocos2d::Point &end)
{
    if (this->isContainPoint(end)) {
        return start.getDistance(end);
    }
    
    return 0;
}

cocos2d::Point RouteNode::findInPoint(cocos2d::Point &start, cocos2d::Point &end, std::shared_ptr<Line> &line)
{
    cocos2d::Point s;
    cocos2d::Point e;
    for (auto &tmp : m_lineList) {
        if (cocos2d::Point::isSegmentOverlap(tmp->startPoint(), tmp->endPoint(), line->startPoint(), line->endPoint(), &s, &e)) {
            if (cocos2d::Point::isSegmentIntersect(tmp->startPoint(), tmp->endPoint(), start, end)) {
                return cocos2d::Point::getIntersectPoint(tmp->startPoint(), tmp->endPoint(), start, end);
            } else {
                float d1 = tmp->startPoint().getDistance(start);
                float d2 = tmp->startPoint().getDistance(end);
                float d3 = tmp->endPoint().getDistance(start);
                float d4 = tmp->endPoint().getDistance(end);
                if (d1 + d2 < d3 + d4) {
                    return tmp->startPoint();
                } else {
                    return tmp->endPoint();
                }
            }
            break;
        }
    }
    
    return nullptr;
}


std::shared_ptr<RouteNode> RouteNode::findNextRouteNode(cocos2d::Point &start, cocos2d::Point &end, cocos2d::Point *intersect)
{
    
    for (auto &line : m_lineList) {
        if (!cocos2d::Point::isLineParallel(line->startPoint(), start, start, line->endPoint()) &&
            cocos2d::Point::isSegmentIntersect(line->startPoint(), line->endPoint(), start, end)) {
//            routeList list = RouteFinder::getInstance()->routeNodeForLine(line);
            routeList list;
//            routeMap::const_iterator iter = m_neighbours.find(line);
//            if (iter != m_neighbours.end()) {
                cocos2d::Point sect = cocos2d::Point::getIntersectPoint(line->startPoint(), line->endPoint(), start, end);
                for (auto &node : list) {
                    if (node->isTheSame(this))
                        continue;
                    
                    if (node->isPointInLine(sect)) {
                        if (intersect != nullptr)
                            *intersect = sect;
                        return node;
                    }
//                }
            }
            
            return nullptr;
        }
    }
    
    return nullptr;
}

void RouteNode::clear()
{
//    RouteNode::routeMap map;
//    m_neighbours.swap(map);
}

void RouteNode::reset()
{
    m_mark = false;
}

void RouteFinder::addStartPoint(cocos2d::Point &point)
{
    m_startList.push_back(point);
}

void RouteFinder::findRoute(cocos2d::Point &point)
{
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        m_endList.push_back(point);
    }
    
    std::function<void()> f = std::bind(&RouteFinder::doFindRoute, this);
    Caculater::getInstance()->caculate(f);
}

std::shared_ptr<RouteNode> RouteFinder::findRouteNode(cocos2d::Point &point)
{
    for (auto &node : m_routeList) {
        if (node->isContainPoint(point))
            return node;
    }
    
    return nullptr;
}

void RouteFinder::fillStraightRoute(cocos2d::Point &point)
{
    pathList list;
    for (auto &start : m_startList) {
        for (auto &n : m_routeList) {
            n->reset();
        }
        std::shared_ptr<RouteNode> node = this->findRouteNode(start);
        cocos2d::Point intersect;
        cocos2d::Point s = start;
        do {
            
            node = node->findNextRouteNode(s, point, &intersect);
            s = intersect;
            
        }while(node != nullptr);
        
        if (intersect != cocos2d::Vec2::ZERO) {
            Line *line = Line::create(start, intersect);
            list.pushBack(line);
        }
        
    }
    
    {
        lrb::base::MutexLockGuard lock(m_mutex2);
        m_pathList = std::move(list);
    }
}

RouteNode::routeList RouteFinder::findRouteNodeList(cocos2d::Point &start, cocos2d::Point &end)
{
    RouteNode::routeList list;
    return list;
}

bool PathNode::isContainNode(std::shared_ptr<RouteNode> &node)
{
    for (auto &n : m_nodeList) {
        if (n == node) {
            return true;
        }
    }
    
    return false;
}

std::shared_ptr<RouteInfo> RouteFinder::findRoutePath(cocos2d::Point &start, cocos2d::Point &end)
{
    pathList list;
    
    std::vector<std::shared_ptr<RouteInfo> > rList;
    auto node = this->findRouteNode(start);
    node->mark();
    std::shared_ptr<RouteInfo> info(new RouteInfo);
    info->setRouteNode(node);
    info->setInPoint(start);
    rList.push_back(info);
    
    while(!rList.empty()) {
        auto back = rList.back();
        rList.pop_back();
        std::shared_ptr<RouteNode> bptr = back->routeNode();
        if (bptr->isContainPoint(end)) {
            return back;
        }
        
        cocos2d::Point inp = back->inPoint();
        for (auto &line : bptr->allLines()) {
            RouteNode::routeList nList = routeNodeForLine(line);
            for (auto &n : nList) {
//        for (auto &pair : bptr->neighbours()) {
//            for (auto &n : pair.second) {
                if (n == bptr)
                    continue;
                
                if (!n->isMarked()) {
                    n->mark();
                    std::shared_ptr<RouteInfo> in(new RouteInfo);
                    in->setRouteNode(n);
                    in->setFrom(back);
                    
                    cocos2d::Point p = n->findInPoint(inp, end, line);
                    in->setInPoint(p);
                    float dis1 = p.getDistance(inp);
                    float dis2 = p.getDistance(end);
                    in->setValue(dis1 + dis2);
                    rList.push_back(in);
                }
            }
        }
//
        std::sort(rList.begin(), rList.end(), [](std::shared_ptr<RouteInfo> &a, std::shared_ptr<RouteInfo> &b){return a->value() > b->value();});
        
    }
    
    return nullptr;
}

void RouteFinder::doFindRoute()
{
    if (m_endList.empty()) {
        return;
    }
    
    cocos2d::Point point;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
//        CCLOG("point len-%lu", m_endList.size());
        point = m_endList.back();
        m_endList.clear();
    }
    
    std::shared_ptr<RouteNode> ptr = this->findRouteNode(point);
    if (ptr == nullptr) {
        this->fillStraightRoute(point);
    } else {
        pathList list;
        for (auto &start : m_startList) {
            for (auto &n : m_routeList) {
                n->reset();
            }
            std::shared_ptr<RouteInfo> last = this->findRoutePath(start, point);
            if (!last)
                continue;
            std::shared_ptr<RouteInfo> f1(new RouteInfo);
            f1->setInPoint(point);
            std::shared_ptr<RouteInfo> f2 = last;
            std::shared_ptr<RouteInfo> f3 = f2->from();
            last = f1;
            while (f3) {
                cocos2d::Point p1 = f1->inPoint();
                cocos2d::Point p2 = f2->inPoint();
                cocos2d::Point p3 = f3->inPoint();
                if (std::abs((p2-p1).cross(p3-p2)) > 0.1) {
                    cocos2d::Point p = last->inPoint();
                    Line *line = Line::create(p, p2);
                    list.pushBack(line);
                    last = f2;
                }
                f1 = f2;
                f2 = f3;
                f3 = f3->from();
            }
            cocos2d::Point plast = last->inPoint();
            cocos2d::Point pend = f2->inPoint();
            Line *line = Line::create(plast, pend);
            list.pushBack(line);
            
        }
        {
            lrb::base::MutexLockGuard lock(m_mutex2);
            m_pathList=std::move(list);
        }
    }
}

void RouteFinder::clear()
{
    m_startList.clear();
    m_endList.clear();
    {
        lrb::base::MutexLockGuard lock(m_mutex2);
        m_pathList.clear();
        m_pathList1.clear();
    }
//    m_routeMap.clear();
//    m_lineList.clear();
}

RouteNode::routeList RouteFinder::routeNodeForLine(std::shared_ptr<Line> &line)
{
//    RouteNode::routeMap::iterator iter = m_routeMap.find(line);
//    if (iter == m_routeMap.end()) {
//        RouteNode::routeList l;
//        return l;
//    }
//    return iter->second;
    RouteNode::routeList list;
    for (auto &l : line->relatedLines()) {
        routeMap::iterator iter = m_routeMap.find(l);
        if (iter != m_routeMap.end()) {
            list.push_back(iter->second);
        }
    }
    return list;
}

RouteFinder::pathList RouteFinder::currentRoutePath()
{
    
    {
        lrb::base::MutexLockGuard lock(m_mutex2);
        m_pathList1=m_pathList;
    }
    return m_pathList1;
//    return m_pathList;
}

void RouteFinder::fillRouteMap(std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node)
{
//    RouteNode::routeMap::iterator iter = m_routeMap.find(line);
//    if (iter == m_routeMap.end()) {
//        RouteNode::routeList l;
//        l.push_back(node);
//        m_routeMap[line] = l;
//    } else {
//        iter->second.push_back(node);
//    }
    m_routeMap[line] = node;

}

void RouteFinder::addRouteNode(std::vector<cocos2d::Point> &vec)
{
    cocos2d::Point &p1 = vec[0];
    cocos2d::Point &p2 = vec[1];
    cocos2d::Point &p3 = vec[2];
    cocos2d::Point &p4 = vec[3];
    std::shared_ptr<Line> line1(new Line(p1, p2));
    std::shared_ptr<Line> line2(new Line(p2, p3));
    std::shared_ptr<Line> line3(new Line(p3, p4));
    std::shared_ptr<Line> line4(new Line(p4, p1));
    cocos2d::Point s;
    cocos2d::Point e;
    for (auto &l : m_lineList) {
        if (cocos2d::Point::isSegmentOverlap(l->startPoint(), l->endPoint(), line4->startPoint(), line4->endPoint(), &s, &e)) {
            line4->relateTo(l);
            l->relateTo(line4);
        }
    }
    
    m_lineList.push_back(line2);
    
    RouteNode::lineList list;
    list.push_back(line1);
    list.push_back(line2);
    list.push_back(line3);
    list.push_back(line4);
    std::shared_ptr<RouteNode> node(new RouteNode(list));
    
    fillRouteMap(line1, node);
    fillRouteMap(line2, node);
    fillRouteMap(line3, node);
    fillRouteMap(line4, node);
    
    m_routeList.push_back(node);
    
}

void RouteFinder::loadRouteConfig(std::string &path)
{
    clear();
    tinyxml2::XMLDocument tinyDoc;
    std::string fullPath = cocos2d::FileUtils::getInstance()->fullPathForFilename(path);
    tinyDoc.LoadFile(fullPath.c_str());
    tinyxml2::XMLElement *ele = tinyDoc.RootElement();
    
    char num[6] = {0};
    
    const char *txt = ele->GetText();
    const char *ptr = txt;
    char idx=0;
    std::vector<cocos2d::Point> vec;
    
    while(*ptr) {
        char c = *ptr;
        if (c == 44) {  // 逗号
            num[idx] = 0;
            cocos2d::Point p;
            p.x = strtof(num, 0);
            vec.push_back(p);
            idx = -1;
        } else if (c == 124) { // 垂线
            num[idx] = 0;
            cocos2d::Point &p = vec.back();
            p.y = strtof(num, 0);
            idx = -1;
        } else if (c == 59) { //分号
            num[idx] = 0;
            cocos2d::Point &p4 = vec.back();
            p4.y = strtof(num, 0);
            addRouteNode(vec);
            vec.clear();
            idx = -1;
        } else {
            num[idx] = c;
        }
        
        idx = (idx + 1)%5;
        ++ptr;
    }

}

void RouteData::generateMoveFile(std::string &path)
{
    std::string move = path;
    int idx = move.rfind("/");
    if (idx == std::string::npos) {
        idx = 0;
    }
    move.insert(idx + 1, "move/");
    
    bool exist = cocos2d::FileUtils::getInstance()->isFileExist(move);
    if (exist)
        return;
    
    tinyxml2::XMLDocument doc;
    std::string fullpath = cocos2d::FileUtils::getInstance()->fullPathForFilename(path);
    doc.LoadFile(fullpath.c_str());
    tinyxml2::XMLElement *root = doc.RootElement();
    
    
    
}

void RouteData::loadRouteConfig(std::string &path)
{
    
    
    
}

static RouteData *g_routedata_instance = nullptr;
RouteData *RouteData::getInstance()
{
    if (g_routedata_instance == nullptr) {
        lrb::base::MutexLockGuard lock(g_mutex);
        if (g_routedata_instance == nullptr) {
            g_routedata_instance = new RouteData();
        }
    }
    return g_routedata_instance;
}









