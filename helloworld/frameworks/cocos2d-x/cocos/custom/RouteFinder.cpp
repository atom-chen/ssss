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
#include "platform/CCFileUtils.h"
#include <regex.h>


using namespace sgzj;

static lrb::base::MutexLock g_mutex;

Line::Line(cocos2d::Point &start, cocos2d::Point &end):
    m_startPoint(start),
    m_endPoint(end)
{
    CCLOG("1");
}

Line::~Line()
{
    CCLOG("2");
}

Line *Line::create(cocos2d::Point &start, cocos2d::Point &end)
{
    CCLOG("3");
    Line *line = new Line(start, end);
    line->autorelease();
    return line;
}

void Line::removeRelation(Line *line)
{
    CCLOG("4");
    std::set<std::shared_ptr<Line> >::iterator iter;
    for (iter = m_relation.begin();iter!=m_relation.end();++iter) {
        if ((*iter)->isTheSame(line)) {
            break;
        }
    }
    
//    std::iter_swap(iter, m_relation.end()-1);
//    m_relation.pop_back();
    m_relation.erase(iter);
    
}

void Line::clear()
{
    CCLOG("5");
    for (auto &line : m_relation) {
        line->removeRelation(this);
    }
    
    m_relation.clear();
}


RouteNode::RouteNode(RouteNode::lineList &lines, int type):
    m_value(0),
    m_value1(0),
    m_type(type),
    m_lineList(lines)
{
    CCLOG("6");
}

RouteNode::~RouteNode()
{
    CCLOG("routeNode instruct");
}

bool RouteNode::isContainPoint(cocos2d::Point &point)
{
    CCLOG("7");
    for (auto &line : m_lineList) {
        cocos2d::Point &start = line->startPoint();
        cocos2d::Point &end = line->endPoint();
        if (fabs(start.x - 730)<1 && fabs(start.y - 515)<1) {
            CCLOG("");
        }
        float c = (end-start).cross(point-start);
        
        if (c > 0)
            return false;
    }
    
    return true;
}

bool RouteNode::isPointInLine(cocos2d::Point &point)
{
    CCLOG("8");
    for (auto &line : m_lineList) {
        if (cocos2d::Point::isLineParallel(line->startPoint(), point, point, line->endPoint())) {
            return true;
        }
    }
    
    return false;
}

//float RouteNode::routeValueWithPoint(cocos2d::Point &start, cocos2d::Point &end)
//{
//    if (this->isContainPoint(end)) {
//        return start.getDistance(end);
//    }
//    
//    return 0;
//}

//cocos2d::Point RouteNode::findInPoint(cocos2d::Point &start, cocos2d::Point &end, std::shared_ptr<Line> &line)
//{
//    cocos2d::Point s;
//    cocos2d::Point e;
//    for (auto &tmp : m_lineList) {
//        cocos2d::Point ts = tmp->startPoint();
//        cocos2d::Point te = tmp->endPoint();
//        if (cocos2d::Point::isSegmentOverlap(ts, te, line->startPoint(), line->endPoint(), &s, &e)) {
//            if (cocos2d::Point::isSegmentIntersect(ts, te, start, end)) {
//                return cocos2d::Point::getIntersectPoint(ts, te, start, end);
//            } else {
//                cocos2d::Point p = end - start;
//                float cross1 = p.cross(ts-start);
//                float cross2 = p.cross(ts-end);
//                if (fabs(cross1) > fabs(cross2)) {
//                    return te;
//                } else if (cross1 == 0 && cross2 == 0) {
//                    if ((p.x > 0 && end.x > start.x) || (p.x < 0 && end.x < start.x))
//                        return ts;
//                    else
//                        return te;
//                } else {
//                    return ts;
//                }
//                
////                float d1 = tmp->startPoint().getDistance(start);
////                float d2 = tmp->startPoint().getDistance(end);
////                float d3 = tmp->endPoint().getDistance(start);
////                float d4 = tmp->endPoint().getDistance(end);
////                if (d1 + d2 < d3 + d4) {
////                    return tmp->startPoint();
////                } else {
////                    return tmp->endPoint();
////                }
//            }
//            break;
//        }
//    }
//    
//    return nullptr;
//}


std::shared_ptr<RouteNode> RouteNode::findNextRouteNode(cocos2d::Point &start, cocos2d::Point &end, cocos2d::Point *intersect)
{
    CCLOG("9");
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
    CCLOG("10");
//    RouteNode::routeMap map;
//    m_neighbours.swap(map);
    for (auto &line : m_lineList)
        line->clear();
    
    m_lineList.clear();
}

void RouteNode::reset()
{
    CCLOG("11");
    m_mark = false;
    m_value = MAXFLOAT;
    m_value1 = 0;
    m_from.reset();
}

void RouteNode::updateValue(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node)
{
    CCLOG("12");
//    RouteData *instance = RouteData::getInstance();
//    instance->findRouteNode(end);
    cocos2d::Point &start = node->startPoint();
    cocos2d::Point sp1 = line->startPoint()-start;
    cocos2d::Point sp2 = line->endPoint()-start;
    std::shared_ptr<Line> &l1 = m_lineList[1];
    std::shared_ptr<Line> &l3 = m_lineList[3];
    cocos2d::Point lp1 = l1->startPoint()-start;
    cocos2d::Point lp2 = l1->endPoint()-start;
    cocos2d::Point ep1 = l3->startPoint()-start;
    cocos2d::Point ep2 = l3->endPoint()-start;
    
    float ag = (end-start).getAngle();
    float sag1 = sp1.getAngle();
    float lag1 = lp1.getAngle();
    float eag1 = ep1.getAngle();
    
    cocos2d::Point ed = line->startPoint();
    float min1 = sag1;
    if (min1 > lag1) {
        ed = l1->startPoint();
        min1 = lag1;
    }
    if (min1 > eag1) {
        ed = l3->startPoint();
        min1 = eag1;
    }
    
    if (ag > min1) {
        float value1 = node->value1() + start.getDistance(ed);
        float value = value1 + ed.getDistance(end);
        if (value < m_value) {
            m_startPoint = ed;
            m_value1 = value1;
            m_value = value;
            m_from = node;
        }
        return;
    }
    
    float sag2 = sp2.getAngle();
    float lag2 = lp2.getAngle();
    float eag2 = ep2.getAngle();
    
    min1 = sag2;
    if (min1 < lag2) {
        ed = l1->endPoint();
        min1 = lag2;
    }
    
    if (min1 < eag2) {
        ed = l3->endPoint();
        min1 = eag2;
    }
    
    if (ag < min1) {
        float value1 = node->value1() + start.getDistance(ed);
        float value = value1 + ed.getDistance(end);
        if (value < m_value) {
            m_startPoint = ed;
            m_value1 = value1;
            m_value = value;
            m_from = node;
        }
        return;
    }
    
    float value1 = node->value1();
    float value = value1 + start.getDistance(end);
    if (value < m_value) {
        m_startPoint = start;
        m_value1 = value1;
        m_value = value;
        m_from = node;
    }
    
}

void RouteFinder::setStartPoint(cocos2d::Point &point)
{
    CCLOG("13");
    lrb::base::MutexLockGuard lock(m_mutex);
    m_startPoint = point;
}

void RouteFinder::findRoute(cocos2d::Point &point)
{
    CCLOG("14");
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        m_endPoint = point;
    }
    
    std::function<void()> f = std::bind(&RouteFinder::doFindRoute, this);
    Caculater::getInstance()->caculate(f);
}

cocos2d::Point RouteFinder::startFindPoint()
{
    CCLOG("15");
    cocos2d::Point p;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        p = m_findStart;
    }
    return p;
}

cocos2d::Point RouteFinder::endFindPoint()
{
    CCLOG("16");
    cocos2d::Point p;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        p = m_findEnd;
    }
    return p;
}

void RouteFinder::fillStraightRoute(cocos2d::Point &start, cocos2d::Point &end)
{
    CCLOG("17");
    RouteNode::lineList list;
    RouteData *instance = RouteData::getInstance();
    std::shared_ptr<RouteNode> node = instance->findRouteNode(start);
    cocos2d::Point intersect;
    cocos2d::Point s = start;
    while(node) {
        
        node = node->findNextRouteNode(s, end, &intersect);
        s = intersect;
        
    }
    
    if (intersect != cocos2d::Vec2::ZERO) {
        std::shared_ptr<Line> line(new Line(start, intersect));
        list.push_back(line);
    }
    
    {
        lrb::base::MutexLockGuard lock(m_mutex2);
        m_pathList = std::move(list);
    }
}

RouteNode::routeList RouteFinder::findRouteNodeList(cocos2d::Point &start, cocos2d::Point &end)
{
    CCLOG("18");
    RouteNode::routeList list;
    return list;
}

std::shared_ptr<RouteNode> RouteFinder::findRoutePath(cocos2d::Point &start, cocos2d::Point &end)
{
    CCLOG("19");
    pathList list;
    RouteData *instance = RouteData::getInstance();
    std::vector<std::shared_ptr<RouteNode> > rList;
    auto node = instance->findRouteNode(start);
    if (!node)
        return nullptr;
    
    node->setStartPoint(start);
    node->mark();
    rList.push_back(node);
    
    while(!rList.empty()) {
        auto bptr = rList.back();
        rList.pop_back();
        
        if (bptr->isContainPoint(end)) {
            return bptr;
        }
        
        for (auto &line : bptr->allLines()) {
            RouteNode::routeList nList = instance->routeNodeForLine(line);
            
            for (auto &n : nList) {
                if (n == bptr || n->from().lock() == bptr || (bptr->type() == RouteNode::kNormalMove && n->type() == RouteNode::kBuildMove))
                    continue;
                
                n->updateValue(end, line, bptr);
//                instance->findRouteNode(start);
//                if (n->isContainPoint(end)) {
//                    return n;
//                }
                
                if (!n->isMarked()) {
                    n->mark();
                    rList.push_back(n);
                }
            }
        }
//
        std::sort(rList.begin(), rList.end(), [](std::shared_ptr<RouteNode> &a, std::shared_ptr<RouteNode> &b){return a->value() > b->value();});
        
    }
    
    return nullptr;
}

void RouteFinder::doFindRoute()
{
    CCLOG("find route");
    cocos2d::Point start, end;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        if (m_findStart == m_startPoint && m_findEnd == m_endPoint)
            return;
        
        start = m_startPoint;
        end = m_endPoint;
        
    }
    
    RouteData *instance = RouteData::getInstance();
    instance->reset();
    std::shared_ptr<RouteNode> ptr = instance->findRouteNode(end);

    if (!ptr) {
        this->fillStraightRoute(start, end);
    } else {
        RouteNode::lineList list;
//        for (auto &start : m_startList) {
        
        std::shared_ptr<RouteNode> last = this->findRoutePath(start, end);
        if (!last) {
            CCLOG("find path fail startx: %f, starty: %f, endx: %f, endy: %f", start.x, start.y, end.x, end.y);
            return;
        }
        
//        instance->findRouteNode(start);
        
        cocos2d::Point &s = last->startPoint();
        std::shared_ptr<Line> line(new Line(s, end));
        list.push_back(line);
        
        while(last->from().lock()) {
            cocos2d::Point &s1 = last->startPoint();
            if (last->startPoint() != s) {
                std::shared_ptr<Line> l(new Line(s1, s));
                list.push_back(l);
            }
            
            last = last->from().lock();
        }
        
//            std::shared_ptr<RouteNode> f1(new RouteInfo);
//            f1->setInPoint(end);
//            std::shared_ptr<RouteInfo> f2 = last;
//            std::shared_ptr<RouteInfo> f3 = f2->from();
//            last = f1;
//            while (f3) {
//                cocos2d::Point p1 = f1->inPoint();
//                cocos2d::Point p2 = f2->inPoint();
//                cocos2d::Point p3 = f3->inPoint();
//                if (fabs((p2-p1).cross(p3-p2)) > 0.1) {
//                    cocos2d::Point p = last->inPoint();
//                    std::shared_ptr<Line> line(new Line(p, p2));
//                    list.push_back(line);
//                    last = f2;
//                }
//                f1 = f2;
//                f2 = f3;
//                f3 = f3->from();
//            }
//            cocos2d::Point plast = last->inPoint();
//            cocos2d::Point pend = f2->inPoint();
//        std::shared_ptr<Line> line(new Line(plast, pend));
//        list.push_back(line);
        
//        }
        {
            lrb::base::MutexLockGuard lock(m_mutex2);
            list.swap(m_pathList);
        }
    }
    
//    instance->findRouteNode(start);
    
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        m_findStart = start;
        m_findEnd = end;
    }
    
}

void RouteFinder::clear()
{
    CCLOG("20");
//    m_startList.clear();
//    m_endList.clear();
//    {
        lrb::base::MutexLockGuard lock(m_mutex2);
        m_pathList.clear();
        m_pathList1.clear();
//    }
//    m_routeMap.clear();
//    m_lineList.clear();
}

RouteNode::lineList &RouteFinder::currentRoutePath()
{
    CCLOG("21");
    {
        lrb::base::MutexLockGuard lock(m_mutex2);
        if (!m_pathList.empty()) {
            m_pathList1.swap(m_pathList);
            m_pathList.clear();
        }
    }
    
    return m_pathList1;
    //    return m_pathList;
}

RouteFinder *RouteFinder::create()
{
    CCLOG("22");
    RouteFinder *finder = new RouteFinder();
    finder->autorelease();
    return finder;
}

RouteNode::routeList RouteData::routeNodeForLine(std::shared_ptr<Line> &line)
{
//    RouteNode::routeMap::iterator iter = m_routeMap.find(line);
//    if (iter == m_routeMap.end()) {
//        RouteNode::routeList l;
//        return l;
//    }
//    return iter->second;
    CCLOG("23");
    RouteNode::routeList list;
    for (auto &l : line->relatedLines()) {
        routeMap::iterator iter = m_routeMap.find(l);
        if (iter != m_routeMap.end()) {
            list.push_back(iter->second);
        }
    }
    return list;
}

void RouteData::fillRouteMap(std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node)
{
//    RouteNode::routeMap::iterator iter = m_routeMap.find(line);
//    if (iter == m_routeMap.end()) {
//        RouteNode::routeList l;
//        l.push_back(node);
//        m_routeMap[line] = l;
//    } else {
//        iter->second.push_back(node);
//    }
    CCLOG("24");
    m_routeMap[line] = node;

}

void RouteData::addRouteNode(std::vector<cocos2d::Point> &vec, int type)
{
    CCLOG("25");
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
    
//    RouteNode::lineList::reverse_iterator iter;
//    for (iter = m_lineList.rbegin();iter != m_lineList.rend(); ++iter) {
//        cocos2d::Point ps = (*iter)->startPoint();
//        cocos2d::Point pe = (*iter)->endPoint();
//        
//        if (cocos2d::Point::isSegmentOverlap(ps, pe, p4, p1, &s, &e)) {
//            line4->relateTo((*iter));
//            (*iter)->relateTo(line4);
//        }
//    }
    
    for (routeMap::iterator iter=m_routeMap.begin();iter!=m_routeMap.end();++iter) {
        const std::shared_ptr<Line> &l = iter->first;
        cocos2d::Point ps = l->startPoint();
        cocos2d::Point pe = l->endPoint();
        
        if (cocos2d::Point::isSegmentOverlap(ps, pe, p1, p2, &s, &e)) {
            line1->relateTo(l);
            l->relateTo(line1);
        }
        
        if (cocos2d::Point::isSegmentOverlap(ps, pe, p2, p3, &s, &e)) {
            line2->relateTo(l);
            l->relateTo(line2);
        }
        
        if (cocos2d::Point::isSegmentOverlap(ps, pe, p3, p4, &s, &e)) {
            line3->relateTo(l);
            l->relateTo(line3);
        }
        
        if (cocos2d::Point::isSegmentOverlap(ps, pe, p4, p1, &s, &e)) {
            line4->relateTo(l);
            l->relateTo(line4);
        }
    }
    
//    for (iter = m_lineList1.rbegin();iter != m_lineList1.rend(); ++iter) {
//        cocos2d::Point ps = (*iter)->startPoint();
//        cocos2d::Point pe = (*iter)->endPoint();
//        
//        if (cocos2d::Point::isSegmentOverlap(ps, pe, p1, p2, &s, &e)) {
//            line1->relateTo((*iter));
//            (*iter)->relateTo(line1);
//        }
//    }
    
    m_lineList.push_back(line1);
    m_lineList.push_back(line2);
    m_lineList.push_back(line3);
    m_lineList.push_back(line4);
    
    RouteNode::lineList list;
    list.push_back(line1);
    list.push_back(line2);
    list.push_back(line3);
    list.push_back(line4);
    std::shared_ptr<RouteNode> node(new RouteNode(list, type));
    
    fillRouteMap(line1, node);
    fillRouteMap(line2, node);
    fillRouteMap(line3, node);
    fillRouteMap(line4, node);
    
    m_routeList.push_back(std::move(node));
    
}

void RouteData::debugDraw(cocos2d::DrawNode *node)
{
    CCLOG("26");
    for (auto &r : m_routeList) {
        cocos2d::Point ll[4];
        int idx = 0;
        for (auto &l : r->allLines()) {
//            node->drawLine(l->startPoint(), l->endPoint(), cocos2d::Color4F(1,1,1,1));
            ll[idx] = l->startPoint();
            ++idx;
        }
        
        if (r->type() == 1) {
//            node->drawSolidPoly(ll, 4, cocos2d::Color4F(0,1,0,1));
            node->drawPoly(ll, 4, true, cocos2d::Color4F(0,1,0,1));
        } else {
//            node->drawSolidPoly(ll, 4, cocos2d::Color4F(1,0,0,1));
            node->drawPoly(ll, 4, true, cocos2d::Color4F(1,1,1,1));
        }
        
    }
    node->drawLine(cocos2d::Point(654.650024, 517.349976), cocos2d::Point(951.122558, 1063.51501), cocos2d::Color4F(0,0,1,1));
}

//void RouteData::generateMoveFile(std::string &path)
//{
//    std::string move = path;
//    int idx = move.rfind("/");
//    if (idx == std::string::npos) {
//        idx = 0;
//    }
//    move.insert(idx + 1, "move/");
//    
//    bool exist = cocos2d::FileUtils::getInstance()->isFileExist(move);
//    if (exist)
//        return;
//    
//    tinyxml2::XMLDocument doc;
//    std::string fullpath = cocos2d::FileUtils::getInstance()->fullPathForFilename(path);
//    doc.LoadFile(fullpath.c_str());
//    tinyxml2::XMLElement *root = doc.RootElement();
//    
//    
//    
//}

std::shared_ptr<RouteNode> RouteData::findRouteNode(cocos2d::Point &point)
{
    CCLOG("27");
    for (auto &node : m_routeList) {
        if (node->isContainPoint(point))
            return node;
    }
    
    return nullptr;
}


void RouteData::clear()
{
    CCLOG("28");
    while (!m_routeList.empty()) {
        destroyNode(m_routeList.back());
    }
}

void RouteData::reset()
{
    CCLOG("29");
    for (auto &n : m_routeList)
        n->reset();
}

void RouteData::destroyNode(std::shared_ptr<RouteNode> &node)
{
    CCLOG("30");
    for (auto &line : node->allLines()) {
        m_routeMap.erase(line);
    }
    
    RouteNode::routeList::iterator iter;
    for (iter = m_routeList.begin();iter!=m_routeList.end();++iter) {
        if ((*iter) == node)
            break;
    }
    
    node->clear();
    
    m_routeList.erase(iter);
    
    
    
}

cocos2d::Point RouteData::gridCenterPos(long x, long y)
{
    CCLOG("31");
    cocos2d::Point p;
    
    float totalH = m_gridHeight * m_gridNum;
    float hw = m_gridWidth/2;
    float hh = m_gridHeight/2;
    float startX = m_xoff + hw;
    float startY = RouteData::kmapH - m_yoff - totalH/2;
    p.x = startX + hw * x + y*hw;
    p.y = startY + (x-y) * hh;
    
    return p;
}

void RouteData::processRobber(std::vector<tinyxml2::XMLElement *> &vec, std::string &luaTxt)
{
    CCLOG("32");
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

void RouteData::processGate(std::vector<tinyxml2::XMLElement *> &vec, std::string &luaTxt)
{
    CCLOG("33");
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

static std::vector<Grid> mergeGrid(std::vector<Grid> &vec) {
    CCLOG("34");
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
            if (iter1->a > iter->x + 1) {
                break;
            } else if (iter1->a == iter->x) {
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
    CCLOG("35");
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

void RouteData::processMoveable(tinyxml2::XMLElement *ele, tinyxml2::XMLElement *root, tinyxml2::XMLDocument &doc)
{
    CCLOG("36");
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

void RouteData::processBuild(tinyxml2::XMLElement *ele, tinyxml2::XMLElement *root, tinyxml2::XMLDocument &doc)
{
    CCLOG("37");
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

void RouteData::processRoot(tinyxml2::XMLElement *ele)
{
    CCLOG("38");
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

void RouteData::generateConfig(std::string &path)
{
    CCLOG("39");
    std::string move = path;
    size_t idx = move.rfind("/");
    move.insert(idx+1, "move/");
    
    cocos2d::FileUtils *instance = cocos2d::FileUtils::getInstance();
//    if (instance->isFileExist(move))
//        return;
    
    tinyxml2::XMLDocument tinyDoc;
    std::string fullPath = instance->fullPathForFilename(path);
    std::string writePath = instance->getWritablePath()+path.substr(idx+1);
    tinyDoc.LoadFile(fullPath.c_str());
    tinyxml2::XMLElement *root = tinyDoc.RootElement();
    processRoot(root);
    
    size_t idx1 = path.rfind(".");
    std::string fileName = path.substr(idx+1, idx1-idx-1);
    
    char nn[6] = {0};
    snprintf(nn, 6, "%d", m_ident);
    size_t idx4=m_bg.rfind("/");
    size_t idx5=m_bg.rfind(".");
    std::string luaTxt = "cc.exports.mapConfig"+fileName+"={id="+nn+",mapPic=\""+m_bg.substr(idx4+1, idx5-idx4-1)+"\",";
    
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
    luaTxt += "}";
    
    wDoc.SaveFile(writePath.c_str());
    
    std::string lua = writePath;
    size_t idx2 = lua.rfind(".");
    lua = lua.replace(idx2, -1, ".lua");
    
    FILE *fp = fopen(lua.c_str(), "wb+");
    fwrite(luaTxt.c_str(), luaTxt.size(), 1, fp);
    fflush(fp);
    
    CCLOG("done");
}


static cocos2d::Point stringToPoint(const char *str)
{
    CCLOG("40");
    cocos2d::Point p;
    char num[10] = {0};
    int idx = 0;
    while (*str) {
        char c = *str;
        if (c == ',') {
            num[idx] = 0;
            p.x = strtof(num, 0);
            idx = 0;
        } else {
            num[idx] = c;
            ++idx;
        }
        ++str;
    }
    p.y = strtof(num, 0);
    return p;
}

void RouteData::processBuildMove(tinyxml2::XMLElement *ele)
{
    CCLOG("41");
    std::vector<cocos2d::Point> vec;
    tinyxml2::XMLElement *pe = ele->FirstChildElement();
    while (pe) {
        cocos2d::Point p = stringToPoint(pe->GetText());
        if (p.x < 0 || p.y < 0)
            return;
        
        vec.push_back(p);
        pe = pe->NextSiblingElement();
    }
    
    addRouteNode(vec, 1);
}

void RouteData::processNormalMove(tinyxml2::XMLElement *ele)
{
    CCLOG("42");
    std::vector<cocos2d::Point> vec;
    tinyxml2::XMLElement *pe = ele->FirstChildElement();
    while (pe) {
        cocos2d::Point p = stringToPoint(pe->GetText());
        if (p.x < 0 || p.y < 0)
            return;
        
        vec.push_back(p);
        pe = pe->NextSiblingElement();
    }
    
    addRouteNode(vec);
}

void RouteData::loadRouteData(std::string &path)
{
    CCLOG("43");
    clear();
    tinyxml2::XMLDocument tinyDoc;
    std::string fullPath = cocos2d::FileUtils::getInstance()->fullPathForFilename(path);
    tinyDoc.LoadFile(fullPath.c_str());
    tinyxml2::XMLElement *root = tinyDoc.RootElement();
    tinyxml2::XMLElement *ele = root->FirstChildElement();
    while (ele) {
        if (strncmp(ele->Name(), "Build", 5) == 0) {
            processBuildMove(ele);
        } else if (strncmp(ele->Name(), "rectAngle", 9) == 0) {
            processNormalMove(ele);
        }
        
        ele = ele->NextSiblingElement();
    }
    
    m_lineList.clear();
//    m_lineCheck.reset();
//    m_lineList1.clear();
}

void RouteData::loadRouteConfig(std::string &path)
{
    CCLOG("44");
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
            vec.push_back(std::move(p));
            idx = 0;
        } else if (c == 124) { // 垂线
            num[idx] = 0;
            cocos2d::Point &p = vec.back();
            p.y = strtof(num, 0);
            idx = 0;
        } else if (c == 59) { //分号
            num[idx] = 0;
            cocos2d::Point &p4 = vec.back();
            p4.y = strtof(num, 0);
            addRouteNode(vec);
            vec.clear();
            idx = 0;
        } else {
            num[idx] = c;
            ++idx;
        }
        
        ++ptr;
    }

    
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









