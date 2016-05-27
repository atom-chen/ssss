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

static float cross(cocos2d::Point &A, cocos2d::Point &B, cocos2d::Point &C, cocos2d::Point &D)
{
    return (D.y - C.y) * (B.x - A.x) - (D.x - C.x) * (B.y - A.y);
}

bool RouteNode::isContainPoint(cocos2d::Point &point)
{

    for (auto &line : m_lineList) {
        cocos2d::Point &start = line->startPoint();
        cocos2d::Point &end = line->endPoint();
        
        float c = cross(start, end, start, point);
        
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
    
    for (auto &tmp : m_lineList) {
        if (cocos2d::Point::isSegmentOverlap(tmp->startPoint(), tmp->endPoint(), line->startPoint(), line->endPoint())) {
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
            routeMap::const_iterator iter = m_neighbours.find(line);
            if (iter != m_neighbours.end()) {
                cocos2d::Point sect = cocos2d::Point::getIntersectPoint(line->startPoint(), line->endPoint(), start, end);
                for (auto &node : iter->second) {
                    if (node->isPointInLine(sect)) {
                        if (intersect != nullptr)
                            *intersect = sect;
                        return node;
                    }
                }
            }
            
            return nullptr;
        }
    }
    
    return nullptr;
}

void RouteNode::clear()
{
    RouteNode::routeMap map;
    m_neighbours.swap(map);
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
        std::shared_ptr<RouteNode> node = this->findRouteNode(start);
        cocos2d::Point intersect = cocos2d::Vec2::ZERO;
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
    
    m_pathList = std::move(list);
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
        for (auto &pair : bptr->neighbours()) {
            for (auto &n : pair.second) {
                if (!n->isMarked()) {
                    n->mark();
                    std::shared_ptr<RouteInfo> in(new RouteInfo);
                    in->setRouteNode(n);
                    in->setFrom(back);
                    std::shared_ptr<Line> line = pair.first;
                    cocos2d::Point p = n->findInPoint(inp, end, line);
                    in->setInPoint(p);
                    float dis1 = p.getDistance(inp);
                    float dis2 = p.getDistance(end);
                    in->setValue(dis1 + dis2);
                    rList.push_back(in);
                }
            }
        }
        
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
    pointList empty;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        point = m_endList.back();
        m_endList.clear();
    }
    
    std::shared_ptr<RouteNode> ptr = this->findRouteNode(point);
    if (ptr == nullptr) {
        this->fillStraightRoute(point);
    } else {
        pathList list;
        for (auto &start : m_startList) {
            std::shared_ptr<RouteInfo> last = this->findRoutePath(start, point);
            std::shared_ptr<RouteInfo> f1 = last;
            std::shared_ptr<RouteInfo> f2 = f1->from();
            std::shared_ptr<RouteInfo> f3 = f2->from();
            while (f3) {
                if (!cocos2d::Point::isLineParallel(f1->inPoint(), f2->inPoint(), f2->inPoint(), f3->inPoint())) {
                    cocos2d::Point p1 = last->inPoint();
                    cocos2d::Point p2 = f2->inPoint();
                    Line *line = Line::create(p1, p2);
                    list.pushBack(line);
                    last = f2;
                }
                f1 = f2;
                f2 = f3;
                f3 = f3->from();
            }
        
//            list.pushBack(pathList);
        }
        
        m_pathList = std::move(list);
    }
    
}

void RouteFinder::clear()
{
    m_startList.clear();
    m_endList.clear();
    m_pathList.clear();
}

static RouteFinder *g_routefinder_instance = nullptr;
RouteFinder *RouteFinder::getInstance()
{
    if (g_routefinder_instance == nullptr) {
        lrb::base::MutexLockGuard lock(g_mutex);
        if (g_routefinder_instance == nullptr) {
            g_routefinder_instance = new RouteFinder();
        }
    }
    return g_routefinder_instance;
}










