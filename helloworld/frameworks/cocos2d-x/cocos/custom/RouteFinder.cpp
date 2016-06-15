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
//    CCLOG("1");
}

Line::~Line()
{
//    CCLOG("2");
}

Line *Line::create(cocos2d::Point &start, cocos2d::Point &end)
{
//    CCLOG("3");
    Line *line = new Line(start, end);
    line->autorelease();
    return line;
}

void Line::removeRelation(Line *line)
{
//    CCLOG("4");
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
//    CCLOG("5");
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
//    CCLOG("6");
}

RouteNode::~RouteNode()
{
//    CCLOG("routeNode instruct");
}

bool RouteNode::isContainPoint(cocos2d::Point &point)
{
//    CCLOG("7");
    for (auto &line : m_lineList) {
        cocos2d::Point &start = line->startPoint();
        cocos2d::Point &end = line->endPoint();
//        if (fabs(start.x - 730)<1 && fabs(start.y - 515)<1) {
//            CCLOG("");
//        }
        float c = (end-start).cross(point-start);
        
        if (c > 0)
            return false;
    }
    
    return true;
}

bool RouteNode::isPointInLine(cocos2d::Point &point)
{
//    CCLOG("8");
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
//    CCLOG("9");
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
//    CCLOG("10");
//    RouteNode::routeMap map;
//    m_neighbours.swap(map);
//    m_fromList.clear();
    for (auto &line : m_lineList)
        line->clear();
    
    m_lineList.clear();
}

void RouteNode::reset()
{
//    CCLOG("11");
    m_mark = false;
    m_value = MAXFLOAT;
    m_value1 = 0;
    m_fromList.clear();
    m_findDone = false;
//    m_from.reset();
    m_topPoint = cocos2d::Vec2::ZERO;
    m_bottomPoint = cocos2d::Vec2::ZERO;
    m_fromTop = cocos2d::Vec2::ZERO;
    m_fromBot = cocos2d::Vec2::ZERO;
    m_inflexion.clear();
}

void RouteNode::updateValue1(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node, int idx)
{
    std::shared_ptr<Line> &l1 = m_lineList[0];
    std::shared_ptr<Line> &l3 = m_lineList[2];
    
    cocos2d::Point start = node->startPoint();
    cocos2d::Point md1 = l1->startPoint().getMidpoint(l1->endPoint());
    cocos2d::Point md2 = l3->startPoint().getMidpoint(l3->endPoint());
    if (idx == 1) {
        float value1 = node->value1() + start.getDistance(md2);
        float value = value1 + md2.getDistance(end);
        if (value < m_value) {
            m_startPoint = md2;
            m_value1 = value1;
            m_value = value;
//            m_fromList = node->fromList();
//            m_fromList.push_back(node);
//            m_pList = node->startPointList();
//            m_pList.push_back(md2);
//            m_from = node;
            m_topPoint = cocos2d::Vec2::ZERO;
            m_bottomPoint = cocos2d::Vec2::ZERO;
            m_fromTop = cocos2d::Vec2::ZERO;
            m_fromBot = cocos2d::Vec2::ZERO;
            m_fromList.clear();
            m_inflexion.push_back(md2);
            m_mark = false;
        }

    } else if (idx == 3) {
        float value1 = node->value1() + start.getDistance(md1);
        float value = value1 + md1.getDistance(end);
        if (value < m_value) {
            m_startPoint = md1;
            m_value1 = value1;
            m_value = value;
//            m_fromList = node->fromList();
//            m_fromList.push_back(node);
//            m_pList = node->startPointList();
//            m_pList.push_back(md1);
//            m_from = node;
            m_topPoint = cocos2d::Vec2::ZERO;
            m_bottomPoint = cocos2d::Vec2::ZERO;
            m_fromTop = cocos2d::Vec2::ZERO;
            m_fromBot = cocos2d::Vec2::ZERO;
            m_inflexion.push_back(md1);
            m_fromList.clear();
            m_mark = false;
        }
    }
    
    if (isContainPoint(end)) {
        m_findDone = true;
    }
}

void RouteNode::updateValueWithList2(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion)
{
    std::vector<std::shared_ptr<RouteNode>>::iterator iter;
    for (iter = fromList.begin(); iter!= fromList.end();++iter) {
        if ((*iter)->isContainPoint(next)) {
            break;
        }
    }
    
    ++iter;
    if (iter==fromList.end() || !(*iter)->isContainPoint(next)) {
        --iter;
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator firstIter = iter;
//    lineList &list = (*iter)->allLines();
//    std::shared_ptr<Line> &l1 = list[3];
    cocos2d::Point top1 = (*iter)->m_fromTop;
    cocos2d::Point bot1 = (*iter)->m_fromBot;
    
    std::vector<std::shared_ptr<RouteNode>>::iterator iter1 = iter + 1;
    if (iter1 != fromList.end()) {
        top1 = (*iter1)->m_fromTop;
        bot1 = (*iter1)->m_fromBot;
    }
    
    if (top1 == cocos2d::Vec2::ZERO && bot1 == cocos2d::Vec2::ZERO) {
        lineList &list = (*iter)->allLines();
        std::shared_ptr<Line> &l1 = list[1];
        top1 = l1->startPoint();
        bot1 = l1->endPoint();
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator last;
    for (last = iter, ++iter;iter!=fromList.end();++last,++iter) {
        lineList &ll1 = (*iter)->allLines();
        std::shared_ptr<Line> &line1 = ll1[3];
        lineList &ll2 = (*last)->allLines();
        std::shared_ptr<Line> &line2 = ll2[1];
        
        if ((top1-next).cross(line1->endPoint()-next) < 0) {
            top1 = line1->endPoint();
        }
        
        if ((top1-next).cross(line2->startPoint()-next) < 0) {
            top1 = line2->startPoint();
        }
        
        if ((bot1-next).cross(line1->startPoint()-next) > 0) {
            bot1 = line1->startPoint();
        }
        
        if ((bot1-next).cross(line2->endPoint()-next) > 0) {
            bot1 = line2->endPoint();
        }
    }
    
    if ((tp1-next).cross(bot1-next) > 0) {
        vec.push_back(next);
        float v1 = bot1.getDistance(next) + value1;
        updateValueWithList2(end, vec, bot1, v1, fromList, tp1, bp1, inflexion);
        return;
    }
    
    if ((bp1-next).cross(top1-next) < 0) {
        vec.push_back(next);
//        vec.push_back(top1);
        float v1 = top1.getDistance(next) + value1;
        updateValueWithList2(end, vec, top1, v1, fromList, tp1, bp1, inflexion);
        return;
    }
    
    cocos2d::Point finalTP, finalBP;
    if ((top1-next).cross(tp1-next) > 0) {
        finalTP = top1;
    } else {
        finalTP = tp1;
    }
    
    if ((bot1-next).cross(bp1-next) < 0) {
        finalBP = bot1;
    } else {
        finalBP = bp1;
    }
    
    std::vector<std::shared_ptr<RouteNode>> flist(firstIter, fromList.end());
    
    float v1 =0;
    float value = MAXFLOAT;
    if ((end-next).cross(finalTP-next) < 0) {
        v1 = value1 + finalTP.getDistance(next);
        value = v1 + finalTP.getDistance(end);
        if (m_findDone) {
            vec.push_back(next);
            updateValueWithList22(end, vec, finalTP, v1, fromList, tp1, bp1, inflexion);
        } else if (value < m_value) {
            m_inflexion = inflexion;
            m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
            m_inflexion.push_back(next);
            m_startPoint = next;
//            m_fromList = node->fromList();
//            m_fromList.push_back(node);
            m_fromList = flist;
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_fromTop = tp1;
            m_fromBot = bp1;
            m_value1 = value1;
            m_value = value;
            m_mark = false;
        }
//        if (m_findDone) {
//            m_inflexion.push_back(finalTP);
//        }
        return;
    }
    if ((end-next).cross(finalBP-next) > 0) {
        v1 = value1 + finalBP.getDistance(next);
        value = value1 + finalBP.getDistance(end);
        if (m_findDone) {
            vec.push_back(next);
            updateValueWithList22(end, vec, finalBP, v1, fromList, tp1, bp1, inflexion);
        } else if (value < m_value) {
            m_inflexion = inflexion;
            m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
            m_inflexion.push_back(next);
            m_startPoint = next;
//            m_fromList = node->fromList();
//            m_fromList.push_back(node);
            m_fromList = flist;
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_fromTop = tp1;
            m_fromBot = bp1;
            m_value1 = value1;
            m_value = value;
            m_mark = false;
        }
//        if (m_findDone) {
//            m_inflexion.push_back(finalBP);
//        }
        return;
    }
    
    v1 = value1;
    value = value1 + next.getDistance(end);
    if (value < m_value) {
        m_inflexion = inflexion;
        m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
        m_inflexion.push_back(next);
        m_startPoint = next;
//        m_fromList = node->fromList();
//        m_fromList.push_back(node);
        m_fromList = flist;
        m_topPoint = finalTP;
        m_bottomPoint = finalBP;
        m_fromTop = tp1;
        m_fromBot = bp1;
        m_value1 = value1;
        m_value = value;
        m_mark = false;
    }
    
}

void RouteNode::updateValueWithList21(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion)
{
    std::vector<std::shared_ptr<RouteNode>>::iterator iter;
    for (iter = fromList.begin(); iter!= fromList.end();++iter) {
        if ((*iter)->isContainPoint(next)) {
            break;
        }
    }
    
    ++iter;
    if (iter==fromList.end() || !(*iter)->isContainPoint(next)) {
        --iter;
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator nIter = fromList.end()-1;
//    lineList &list = (*iter)->allLines();
//    std::shared_ptr<Line> &l1 = list[1];
    cocos2d::Point top1 = (*iter)->m_fromTop;
    cocos2d::Point bot1 = (*iter)->m_fromBot;
    
    std::vector<std::shared_ptr<RouteNode>>::iterator iter1 = iter + 1;
    if (iter1 != fromList.end()) {
        top1 = (*iter1)->m_fromTop;
        bot1 = (*iter1)->m_fromBot;
    }
    
    if (top1 == cocos2d::Vec2::ZERO && bot1 == cocos2d::Vec2::ZERO) {
        lineList &list = (*iter)->allLines();
        std::shared_ptr<Line> &l1 = list[1];
        top1 = l1->startPoint();
        bot1 = l1->endPoint();
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator last;
    for (last = iter, ++iter;iter!=fromList.end();++last,++iter) {
        lineList &ll1 = (*iter)->allLines();
        std::shared_ptr<Line> &line1 = ll1[1];
        lineList &ll2 = (*last)->allLines();
        std::shared_ptr<Line> &line2 = ll2[3];
        
        if ((top1-next).cross(line1->startPoint()-next) > 0) {
            top1 = line1->startPoint();
        }
        
        if ((top1-next).cross(line2->endPoint()-next) > 0) {
            top1 = line2->endPoint();
        }
        
        if ((bot1-next).cross(line1->endPoint()-next) < 0) {
            bot1 = line1->endPoint();
        }
        
        if ((bot1-next).cross(line2->startPoint()-next) < 0) {
            bot1 = line2->startPoint();
        }
    }

    float c = (bot1-next).cross(tp1-next);
    if (c > 0 || (c == 0 && bot1.y > tp1.y)) {
        float v1 = value1 + bot1.getDistance(next);
        if (bot1 != (*nIter)->m_fromBot) {
            vec.push_back(next);
            updateValueWithList21(end, vec, bot1, v1, fromList, tp1, bp1, inflexion);
        } else {
            float v2 = v1 + bot1.getDistance(tp1);
            float value = v2 + tp1.getDistance(end);
            if (value < m_value) {
                m_inflexion = inflexion;
                m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
                m_inflexion.push_back(next);
                if (next != bot1)
                    m_inflexion.push_back(bot1);
                m_inflexion.push_back(tp1);
                m_startPoint = tp1;
                //        m_fromList = node->fromList();
                //        m_fromList.push_back(node);
                m_fromList.clear();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp1;
                m_fromBot = bp1;
                m_value1 = v2;
                m_value = value;
                m_mark = false;
            }
        }
    } else {
        float v1 = value1 + top1.getDistance(next);
        if (top1 != (*nIter)->m_fromTop) {
            vec.push_back(next);
            updateValueWithList21(end, vec, top1, v1, fromList, tp1, bp1, inflexion);
        } else {
            float v2 = v1 + top1.getDistance(bp1);
            float value = v2 + bp1.getDistance(end);
            if (value < m_value) {
                m_inflexion = inflexion;
                m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
                m_inflexion.push_back(next);
                if (next != top1)
                    m_inflexion.push_back(top1);
                m_inflexion.push_back(bp1);
                m_startPoint = bp1;
                //        m_fromList = node->fromList();
                //        m_fromList.push_back(node);
                m_fromList.clear();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp1;
                m_fromBot = bp1;
                m_value1 = v2;
                m_value = value;
                m_mark = false;
            }
        }
    }
}

void RouteNode::updateValueWithList22(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion)
{
    std::vector<std::shared_ptr<RouteNode>>::iterator iter;
    for (iter = fromList.begin(); iter!= fromList.end();++iter) {
        if ((*iter)->isContainPoint(next)) {
            break;
        }
    }
    
    ++iter;
    if (iter==fromList.end() || !(*iter)->isContainPoint(next)) {
        --iter;
    }
    
    //    lineList &list = (*iter)->allLines();
    //    std::shared_ptr<Line> &l1 = list[3];
    cocos2d::Point top1 = (*iter)->m_fromTop;
    cocos2d::Point bot1 = (*iter)->m_fromBot;
    
    std::vector<std::shared_ptr<RouteNode>>::iterator iter1 = iter + 1;
    if (iter1 != fromList.end()) {
        top1 = (*iter1)->m_fromTop;
        bot1 = (*iter1)->m_fromBot;
    }
    
    if (top1 == cocos2d::Vec2::ZERO && bot1 == cocos2d::Vec2::ZERO) {
        lineList &list = (*iter)->allLines();
        std::shared_ptr<Line> &l1 = list[1];
        top1 = l1->startPoint();
        bot1 = l1->endPoint();
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator last;
    for (last = iter, ++iter;iter!=fromList.end();++last,++iter) {
        lineList &ll1 = (*iter)->allLines();
        std::shared_ptr<Line> &line1 = ll1[3];
        lineList &ll2 = (*last)->allLines();
        std::shared_ptr<Line> &line2 = ll2[1];
        
        if ((top1-next).cross(line1->endPoint()-next) < 0) {
            top1 = line1->endPoint();
        }
        
        if ((top1-next).cross(line2->startPoint()-next) < 0) {
            top1 = line2->startPoint();
        }
        
        if ((bot1-next).cross(line1->startPoint()-next) > 0) {
            bot1 = line1->startPoint();
        }
        
        if ((bot1-next).cross(line2->endPoint()-next) > 0) {
            bot1 = line2->endPoint();
        }
    }
    
    if ((top1-next).cross(tp1-next) <= 0) {
        top1 = tp1;
    }
    
    if ((bot1-next).cross(bp1-next) >= 0) {
        bot1 = bp1;
    }

    if ((top1-next).cross(end-next) > 0) {
        vec.push_back(next);
        float v1 = value1 + next.getDistance(top1);
        updateValueWithList22(end, vec, top1, v1, fromList, tp1, bp1, inflexion);
        return;
    }
    
    if ((bot1-next).cross(end-next) < 0) {
        vec.push_back(next);
        float v1 = value1 + next.getDistance(bot1);
        updateValueWithList22(end, vec, bot1, v1, fromList, tp1, bp1, inflexion);
        return;
    }
    
    m_inflexion = inflexion;
    m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
    m_inflexion.push_back(next);
    
}

void RouteNode::updateValue2(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node)
{
    cocos2d::Point start = node->startPoint();
    //    float
    std::shared_ptr<Line> &l3 = m_lineList[3];
    cocos2d::Point top = node->m_topPoint;
    cocos2d::Point bot = node->m_bottomPoint;
    
    cocos2d::Point &lineSP = line->startPoint();
    cocos2d::Point &lineEP = line->endPoint();
    cocos2d::Point &lSP3 = l3->startPoint();
    cocos2d::Point &lEP3 = l3->endPoint();
    
    if (isContainPoint(end)) {
        m_findDone = true;
    }
    
    if (top == cocos2d::Vec2::ZERO && bot == cocos2d::Vec2::ZERO) {
        if (lineSP.y > lineEP.y) {
            top = lineSP;
            bot = lineEP;
        } else {
            top = lineEP;
            bot = lineSP;
        }
    }
    
    cocos2d::Point tp, bp;
    if (lEP3.y < lineSP.y) {
        tp = lEP3;
    } else {
        tp = lineSP;
    }
    if (lineEP.y > lSP3.y) {
        bp = lineEP;
    } else {
        bp = lSP3;
    }
    
    if (fabs((top-start).cross(bot-start)) < FLT_EPSILON) {
        if (tp.y > start.y && bp.y > start.y) {
            float value1 = node->value1() + bp.getDistance(start);
            float value = value1 + bp.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp;
                m_fromBot = bp;
                m_inflexion.push_back(bp);
                m_startPoint = bp;
                m_fromList.clear();
                m_value1 = value1;
                m_value = value;
                m_mark = false;
            }
        } else if (tp.y < start.y && bp.y < start.y) {
            float value1 = node->value1() + tp.getDistance(start);
            float value = value1 + tp.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp;
                m_fromBot = bp;
                m_inflexion.push_back(tp);
                m_startPoint = tp;
                m_fromList.clear();
                m_value1 = value1;
                m_value = value;
                m_mark = false;
            }
        } else {
            float value1 = node->value1();
            float value = value1 + start.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_startPoint = node->startPoint();
                m_fromList = node->fromList();
                m_fromList.push_back(node);
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp;
                m_fromBot = bp;
                m_value1 = node->value1();
                m_value = value;
                m_mark = false;
            }
        }
        
        return;
    }
    
    if ((lineSP-start).cross(lineEP-start) > 0) {
        if ((bot-start).cross(tp-start) > 0) {
            float value1 = node->value1() + bot.getDistance(start);
            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
            fl.push_back(node);
            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            updateValueWithList21(end, sl, bot, value1, fl, tp, bp, node->inflexionList());
        } else {
            float value1 = node->value1() + top.getDistance(start);
            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
            fl.push_back(node);
            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            updateValueWithList21(end, sl, top, value1, fl, tp, bp, node->inflexionList());
        }
        
//        float value1 = 0;
//        float value = MAXFLOAT;
//        cocos2d::Point in1;
//        cocos2d::Point in2;
//        cocos2d::Point in3;
//        if ((bot-start).cross(tp-start) > 0) {
//            value1 = node->value1() + bot.getDistance(start) + bot.getDistance(node->m_fromBot) + node->m_fromBot.getDistance(tp);
//            in1 = bot;
//            in2 = node->m_fromBot;
//            in3 = tp;
//            value = value1 + tp.getDistance(end);
//        } else {
//            in1 = top;
//            in2 = node->m_fromTop;
//            in3 = bp;
//            value1 = node->value1() + top.getDistance(start) + top.getDistance(node->m_fromTop) + node->m_fromTop.getDistance(bp);
//            value = value1 + bp.getDistance(end);
//        }
//        
//        if (value < m_value) {
//            m_inflexion = node->inflexionList();
//            m_topPoint = cocos2d::Vec2::ZERO;
//            m_bottomPoint = cocos2d::Vec2::ZERO;
//            m_fromTop = tp;
//            m_fromBot = bp;
//            m_inflexion.push_back(in1);
//            if (in1 != in2 && in2 != cocos2d::Vec2::ZERO)
//                m_inflexion.push_back(in2);
//            m_inflexion.push_back(in3);
//            m_startPoint = in3;
//            m_fromList.clear();
//            m_value1 = value1;
//            m_value = value;
//            m_mark = false;
//        }
        return;
    }
    
    float value1 = 0;
    float value = MAXFLOAT;
    cocos2d::Point in1;
    cocos2d::Point in2;
    cocos2d::Point in3;
    if ((bot-start).cross(tp-start) < 0) {
        value1 = node->value1() + bot.getDistance(start);
//        m_fromList = node->fromList();
//        m_fromList.push_back(node);
        std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
        fl.push_back(node);
        std::vector<cocos2d::Point> sl;
//        sl.push_back(start);
        updateValueWithList2(end, sl, bot, value1, fl, tp, bp, node->inflexionList());
        
//        cocos2d::Point ins;
//        if ((node->m_fromBot-bot).cross(tp-bot) < 0) {
//            value1 = node->value1() + bot.getDistance(start) + bot.getDistance(node->m_fromBot) + node->m_fromBot.getDistance(tp);
//            in2 = node->m_fromBot;
//            ins = in2;
//        } else {
//            value1 = node->value1() + bot.getDistance(start) + bot.getDistance(tp);
//            ins = bot;
//            
//        }
//        
//        in1 = bot;
//        in3 = tp;
//        value = value1 + tp.getDistance(end);
//        if (value < m_value) {
//            m_inflexion = node->inflexionList();
//            m_topPoint = cocos2d::Vec2::ZERO;
//            m_bottomPoint = cocos2d::Vec2::ZERO;
//            m_inflexion.push_back(in1);
//            if (in2 != cocos2d::Vec2::ZERO)
//                m_inflexion.push_back(in2);
//            if (in3 != cocos2d::Vec2::ZERO)
//                m_inflexion.push_back(in3);
//            m_fromTop = tp;
//            m_fromBot = bp;
//            m_startPoint = in3;
//            m_value1 = value1;
//            m_value = value;
//            m_mark = false;
//        }
        
        return;
    }
    
    in2 = cocos2d::Vec2::ZERO;
    if ((top-start).cross(bp-start) > 0) {
        
        value1 = node->value1() + top.getDistance(start);
//        m_fromList = node->fromList();
//        m_fromList.push_back(node);
        std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
        fl.push_back(node);
        std::vector<cocos2d::Point> sl;
//        sl.push_back(start);
        updateValueWithList2(end, sl, top, value1, fl, tp, bp, node->inflexionList());
        
//        if ((node->m_fromTop - top).cross(bp-top) > 0) {
//            in2 = node->m_fromTop;
//            value1 = node->value1() + top.getDistance(start) + top.getDistance(node->m_fromTop) + node->m_fromTop.getDistance(bp);
//        } else {
//            value1 = node->value1() + top.getDistance(start) + top.getDistance(bp);
//        }
//        in1 = top;
//        in3 = bp;
//        value = value1 + bp.getDistance(end);
//        if (value < m_value) {
//            m_inflexion = node->inflexionList();
//            m_topPoint = cocos2d::Vec2::ZERO;
//            m_bottomPoint = cocos2d::Vec2::ZERO;
//            m_inflexion.push_back(in1);
//            if (in2 != cocos2d::Vec2::ZERO)
//                m_inflexion.push_back(in2);
//            m_inflexion.push_back(in3);
//            m_fromTop = tp;
//            m_fromBot = bp;
//            m_startPoint = in3;
//            m_value1 = value1;
//            m_value = value;
//            m_mark = false;
//        }
       
        return;
    }
    
    cocos2d::Point finalTP, finalBP;
    if ((tp-start).cross(top-start) >= 0) {
        finalTP = tp;
    } else {
        finalTP = top;
    }
    
    if ((bp-start).cross(bot-start) > 0) {
        finalBP = bot;
    } else {
        finalBP = bp;
    }
    
    if ((end-start).cross(finalTP-start) < 0) {
        value1 = node->value1() + finalTP.getDistance(start);
        value = value1 + finalTP.getDistance(end);
        if (m_findDone) {
            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
            fl.push_back(node);
            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            updateValueWithList22(end, sl, finalTP, value1, fl, tp, bp, node->inflexionList());
            //            m_inflexion.push_back(finalTP);
            
        } else if (value < m_value) {
            m_inflexion = node->inflexionList();
            m_startPoint = node->startPoint();
            m_fromList = node->fromList();
            m_fromList.push_back(node);
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_fromTop = tp;
            m_fromBot = bp;
            m_value1 = node->value1();
            m_value = value;
            m_mark = false;
        }
        return;
    }
    if ((end-start).cross(finalBP-start) > 0) {
        value1 = node->value1() + finalBP.getDistance(start);
        value = value1 + finalBP.getDistance(end);
        if (m_findDone) {
            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
            fl.push_back(node);
            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            updateValueWithList22(end, sl, finalBP, value1, fl, tp, bp, node->inflexionList());
        } else if (value < m_value) {
            m_inflexion = node->inflexionList();
            m_startPoint = node->startPoint();
            m_fromList = node->fromList();
            m_fromList.push_back(node);
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_fromTop = tp;
            m_fromBot = bp;
            m_value1 = node->value1();
            m_value = value;
            m_mark = false;
        }
//        if (m_findDone) {
//            m_inflexion.push_back(finalBP);
//        }
        return;
    }
    
    value1 = node->value1();
    value = value1 + start.getDistance(end);
    if (value < m_value) {
        m_inflexion = node->inflexionList();
        m_startPoint = node->startPoint();
        m_fromList = node->fromList();
        m_fromList.push_back(node);
        m_topPoint = finalTP;
        m_bottomPoint = finalBP;
        m_fromTop = tp;
        m_fromBot = bp;
        m_value1 = node->value1();
        m_value = value;
        m_mark = false;
    }
   
}

void RouteNode::updateValueWithList41(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion)
{
    std::vector<std::shared_ptr<RouteNode>>::iterator iter;
    for (iter = fromList.begin(); iter!= fromList.end();++iter) {
        if ((*iter)->isContainPoint(next)) {
            break;
        }
    }
    
    ++iter;
    if (iter==fromList.end() || !(*iter)->isContainPoint(next)) {
        --iter;
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator nIter = fromList.end()-1;
//    lineList &list = (*iter)->allLines();
//    std::shared_ptr<Line> &l1 = list[3];
    
    cocos2d::Point top1 = (*iter)->m_fromTop;
    cocos2d::Point bot1 = (*iter)->m_fromBot;
    
    std::vector<std::shared_ptr<RouteNode>>::iterator iter1 = iter + 1;
    if (iter1 != fromList.end()) {
        top1 = (*iter1)->m_fromTop;
        bot1 = (*iter1)->m_fromBot;
    }
    
    if (top1 == cocos2d::Vec2::ZERO && bot1 == cocos2d::Vec2::ZERO) {
        lineList &list = (*iter)->allLines();
        std::shared_ptr<Line> &l1 = list[3];
        top1 = l1->endPoint();
        bot1 = l1->startPoint();
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator last;
    for (last = iter, ++iter;iter!=fromList.end();++last,++iter) {
        lineList &ll1 = (*iter)->allLines();
        std::shared_ptr<Line> &line1 = ll1[3];
        lineList &ll2 = (*last)->allLines();
        std::shared_ptr<Line> &line2 = ll2[1];
        
        if ((top1-next).cross(line1->endPoint()-next) < 0) {
            top1 = line1->endPoint();
        }
        
        if ((top1-next).cross(line2->startPoint()-next) < 0) {
            top1 = line2->startPoint();
        }
        
        if ((bot1-next).cross(line1->startPoint()-next) > 0) {
            bot1 = line1->startPoint();
        }
        
        if ((bot1-next).cross(line2->endPoint()-next) > 0) {
            bot1 = line2->endPoint();
        }
    }
    
    float c = (bot1-next).cross(tp1-next);
    if (c < 0 || (c == 0 && bot1.y > tp1.y)) {
        float v1 = value1 + bot1.getDistance(next);
        if (bot1 != (*nIter)->m_fromBot) {
            vec.push_back(next);
            updateValueWithList41(end, vec, bot1, v1, fromList, tp1, bp1, inflexion);
        } else {
            float v2 = v1 + bot1.getDistance(tp1);
            float value = v2 + tp1.getDistance(end);
            if (value < m_value) {
                m_inflexion = inflexion;
                m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
                m_inflexion.push_back(next);
                if (next != bot1)
                    m_inflexion.push_back(bot1);
                m_inflexion.push_back(tp1);
                m_startPoint = tp1;
                //        m_fromList = node->fromList();
                //        m_fromList.push_back(node);
                m_fromList.clear();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp1;
                m_fromBot = bp1;
                m_value1 = v2;
                m_value = value;
                m_mark = false;
            }
        }
    } else {
        float v1 = value1 + top1.getDistance(next);
        if (top1 != (*nIter)->m_fromTop) {
            vec.push_back(next);
            updateValueWithList41(end, vec, top1, v1, fromList, tp1, bp1, inflexion);
        } else {
            float v2 = v1 + top1.getDistance(bp1);
            float value = v2 + bp1.getDistance(end);
            if (value < m_value) {
                m_inflexion = inflexion;
                m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
                m_inflexion.push_back(next);
                if (next != top1)
                    m_inflexion.push_back(top1);
                m_inflexion.push_back(bp1);
                m_startPoint = bp1;
                //        m_fromList = node->fromList();
                //        m_fromList.push_back(node);
                m_fromList.clear();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp1;
                m_fromBot = bp1;
                m_value1 = v2;
                m_value = value;
                m_mark = false;
            }
        }
    }
}

void RouteNode::updateValueWithList42(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion)
{
    std::vector<std::shared_ptr<RouteNode>>::iterator iter;
    for (iter = fromList.begin(); iter!= fromList.end();++iter) {
        if ((*iter)->isContainPoint(next)) {
            break;
        }
    }
    
    ++iter;
    if (iter==fromList.end() || !(*iter)->isContainPoint(next)) {
        --iter;
    }
    

    //    lineList &list = (*iter)->allLines();
    //    std::shared_ptr<Line> &l1 = list[1];
    cocos2d::Point top1 = (*iter)->m_fromTop;
    cocos2d::Point bot1 = (*iter)->m_fromBot;
    
    std::vector<std::shared_ptr<RouteNode>>::iterator iter1 = iter + 1;
    if (iter1 != fromList.end()) {
        top1 = (*iter1)->m_fromTop;
        bot1 = (*iter1)->m_fromBot;
    }
    
    if (top1 == cocos2d::Vec2::ZERO && bot1 == cocos2d::Vec2::ZERO) {
        lineList &list = (*iter)->allLines();
        std::shared_ptr<Line> &l1 = list[3];
        top1 = l1->endPoint();
        bot1 = l1->startPoint();
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator last;
    for (last = iter, ++iter;iter!=fromList.end();++last,++iter) {
        lineList &ll1 = (*iter)->allLines();
        std::shared_ptr<Line> &line1 = ll1[1];
        lineList &ll2 = (*last)->allLines();
        std::shared_ptr<Line> &line2 = ll2[3];
        
        if ((top1-next).cross(line1->startPoint()-next) > 0) {
            top1 = line1->startPoint();
        }
        
        if ((top1-next).cross(line2->endPoint()-next) > 0) {
            top1 = line2->endPoint();
        }
        
        if ((bot1-next).cross(line1->endPoint()-next) < 0) {
            bot1 = line1->endPoint();
        }
        
        if ((bot1-next).cross(line2->startPoint()-next) < 0) {
            bot1 = line2->startPoint();
        }
    }
    
    if ((top1-next).cross(tp1-next) >= 0) {
        top1 = tp1;
    }
    
    if ((bot1-next).cross(bp1-next) <= 0) {
        bot1 = bp1;
    }

    if ((top1-next).cross(end-next) < 0) {
        vec.push_back(next);
        float v1 = value1 + top1.getDistance(next);
        updateValueWithList42(end, vec, top1, v1, fromList, tp1, bp1, inflexion);
        return;
    }
    
    if ((bot1-next).cross(end-next) > 0) {
        vec.push_back(next);
        float v1 = value1 + bot1.getDistance(next);
        updateValueWithList42(end, vec, bot1, v1, fromList, tp1, bp1, inflexion);
        return;
    }
    
    m_inflexion = inflexion;
    m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
    m_inflexion.push_back(next);
    
}

void RouteNode::updateValueWithList4(cocos2d::Point &end, std::vector<cocos2d::Point> &vec, cocos2d::Point &next, float value1, std::vector<std::shared_ptr<RouteNode>> &fromList, cocos2d::Point &tp1, cocos2d::Point &bp1, std::vector<cocos2d::Point> &inflexion)
{
    std::vector<std::shared_ptr<RouteNode>>::iterator iter;
    for (iter = fromList.begin(); iter!= fromList.end();++iter) {
        if ((*iter)->isContainPoint(next)) {
            break;
        }
    }
    
    ++iter;
    if (iter==fromList.end() || !(*iter)->isContainPoint(next)) {
        --iter;
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator firstIter = iter;
//    lineList &list = (*iter)->allLines();
//    std::shared_ptr<Line> &l1 = list[1];
    cocos2d::Point top1 = (*iter)->m_fromTop;
    cocos2d::Point bot1 = (*iter)->m_fromBot;
    
    std::vector<std::shared_ptr<RouteNode>>::iterator iter1 = iter + 1;
    if (iter1 != fromList.end()) {
        top1 = (*iter1)->m_fromTop;
        bot1 = (*iter1)->m_fromBot;
    }
    
    if (top1 == cocos2d::Vec2::ZERO && bot1 == cocos2d::Vec2::ZERO) {
        lineList &list = (*iter)->allLines();
        std::shared_ptr<Line> &l1 = list[3];
        top1 = l1->endPoint();
        bot1 = l1->startPoint();
    }
    
    std::vector<std::shared_ptr<RouteNode>>::iterator last;
    for (last = iter, ++iter;iter!=fromList.end();++last,++iter) {
        lineList &ll1 = (*iter)->allLines();
        std::shared_ptr<Line> &line1 = ll1[1];
        lineList &ll2 = (*last)->allLines();
        std::shared_ptr<Line> &line2 = ll2[3];
        
        if ((top1-next).cross(line1->startPoint()-next) > 0) {
            top1 = line1->startPoint();
        }
        
        if ((top1-next).cross(line2->endPoint()-next) > 0) {
            top1 = line2->endPoint();
        }
        
        if ((bot1-next).cross(line1->endPoint()-next) < 0) {
            bot1 = line1->endPoint();
        }
        
        if ((bot1-next).cross(line2->startPoint()-next) < 0) {
            bot1 = line2->startPoint();
        }
    }
    
    if ((tp1-next).cross(bot1-next) < 0) {
        vec.push_back(next);
        float v1 = bot1.getDistance(next) + value1;
        updateValueWithList4(end, vec, bot1, v1, fromList, tp1, bp1, inflexion);
        return;
    }
    
    if ((bp1-next).cross(top1-next) > 0) {
        vec.push_back(next);
        float v1 = top1.getDistance(next) + value1;
        updateValueWithList4(end, vec, top1, v1, fromList, tp1, bp1, inflexion);
        return;
    }
    
    cocos2d::Point finalTP, finalBP;
    if ((top1-next).cross(tp1-next) < 0) {
        finalTP = top1;
    } else {
        finalTP = tp1;
    }
    
    if ((bot1-next).cross(bp1-next) <= 0) {
        finalBP = bp1;
    } else {
        finalBP = bot1;
    }
    
    std::vector<std::shared_ptr<RouteNode>> flist(firstIter, fromList.end());
    
    float v1 =0;
    float value = MAXFLOAT;
    if ((end-next).cross(finalTP-next) > 0) {
        v1 = value1 + finalTP.getDistance(next);
        value = v1 + finalTP.getDistance(end);
        if (m_findDone) {
//            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
//            fl.push_back(node);
//            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            vec.push_back(next);
            updateValueWithList42(end, vec, finalTP, v1, fromList, tp1, bp1, inflexion);
        } else if (value < m_value) {
            m_inflexion = inflexion;
            m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
            m_inflexion.push_back(next);
            m_startPoint = next;
            //            m_fromList = node->fromList();
            //            m_fromList.push_back(node);
            m_fromList = flist;
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_fromTop = tp1;
            m_fromBot = bp1;
            m_value1 = value1;
            m_value = value;
            m_mark = false;
        }
//        if (m_findDone) {
//            m_inflexion.push_back(finalTP);
//        }
        return;
    }
    if ((end-next).cross(finalBP-next) < 0) {
        v1 = value1 + finalBP.getDistance(next);
        value = value1 + finalBP.getDistance(end);
        if (m_findDone) {
            vec.push_back(next);
            updateValueWithList42(end, vec, finalBP, v1, fromList, tp1, bp1, inflexion);
        } else if (value < m_value) {
            m_inflexion = inflexion;
            m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
            m_inflexion.push_back(next);
            m_startPoint = next;
            //            m_fromList = node->fromList();
            //            m_fromList.push_back(node);
            m_fromList = flist;
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_fromTop = tp1;
            m_fromBot = bp1;
            m_value1 = value1;
            m_value = value;
            m_mark = false;
        }
//        if (m_findDone) {
//            m_inflexion.push_back(finalBP);
//        }
        return;
    }
    
    v1 = value1;
    value = value1 + next.getDistance(end);
    if (value < m_value) {
        m_inflexion = inflexion;
        m_inflexion.insert(m_inflexion.end(), vec.begin(), vec.end());
        m_inflexion.push_back(next);
        m_startPoint = next;
        //        m_fromList = node->fromList();
        //        m_fromList.push_back(node);
        m_fromList = flist;
        m_topPoint = finalTP;
        m_bottomPoint = finalBP;
        m_fromTop = tp1;
        m_fromBot = bp1;
        m_value1 = value1;
        m_value = value;
        m_mark = false;
    }
    
}

void RouteNode::updateValue4(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node)
{
    cocos2d::Point start = node->startPoint();
    //    float
    std::shared_ptr<Line> &l1 = m_lineList[1];
    cocos2d::Point top = node->m_topPoint;
    cocos2d::Point bot = node->m_bottomPoint;
    cocos2d::Point &lineSP = line->startPoint();
    cocos2d::Point &lineEP = line->endPoint();
    cocos2d::Point &lSP1 = l1->startPoint();
    cocos2d::Point &lEP1 = l1->endPoint();
    
    if (top == cocos2d::Vec2::ZERO && bot == cocos2d::Vec2::ZERO) {
        if (lineSP.y > lineEP.y) {
            top = lineSP;
            bot = lineEP;
        } else {
            top = lineEP;
            bot = lineSP;
        }
    }
    
    if (isContainPoint(end)) {
        m_findDone = true;
    }
    
    cocos2d::Point tp, bp;
    
    if (lineEP.y  > lSP1.y) {
        tp = lSP1;
    } else {
        tp = lineEP;
    }
    if (lineSP.y > lEP1.y) {
        bp = lineSP;
    } else {
        bp = lEP1;
    }
    
    if (fabs((top-start).cross(bot-start)) < FLT_EPSILON) {
        if (tp.y > start.y && bp.y > start.y) {
            float value1 = node->value1() + bp.getDistance(start);
            float value = value1 + bp.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp;
                m_fromBot = bp;
                m_inflexion.push_back(bp);
                m_startPoint = bp;
                m_value1 = value1;
                m_value = value;
                m_mark = false;
            }
        } else if (tp.y < start.y && bp.y < start.y) {
            float value1 = node->value1() + tp.getDistance(start);
            float value = value1 + tp.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromTop = tp;
                m_fromBot = bp;
                m_inflexion.push_back(tp);
                m_startPoint = tp;
                m_value1 = value1;
                m_value = value;
                m_mark = false;
            }
        } else {
            float value1 = node->value1();
            float value = value1 + start.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_startPoint = node->startPoint();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_fromList = node->fromList();
                m_fromList.push_back(node);
                m_fromTop = tp;
                m_fromBot = bp;
                m_value1 = node->value1();
                m_value = value;
                m_mark = false;
            }
        }
        return;
    }
    
    if ((lineSP-start).cross(lineEP-start) > 0) {
        
        if ((bot-start).cross(tp-start) < 0) {
            float value1 = node->value1() + bot.getDistance(start);
            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
            fl.push_back(node);
            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            updateValueWithList41(end, sl, bot, value1, fl, tp, bp, node->inflexionList());
        } else {
            float value1 = node->value1() + top.getDistance(start);
            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
            fl.push_back(node);
            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            updateValueWithList41(end, sl, top, value1, fl, tp, bp, node->inflexionList());
        }
        
//        float value1 = 0;
//        float value = MAXFLOAT;
//        cocos2d::Point in1;
//        cocos2d::Point in2;
//        cocos2d::Point in3;
//        if ((bot-start).cross(tp-start) < 0) {
//            value1 = node->value1() + bot.getDistance(start) + bot.getDistance(node->m_fromBot) + node->m_fromBot.getDistance(tp);
//            in1 = bot;
//            in2 = node->m_fromBot;
//            in3 = tp;
//            value = value1 + tp.getDistance(end);
//        } else {
//            in1 = top;
//            in2 = node->m_fromTop;
//            in3 = bp;
//            value1 = node->value1() + top.getDistance(start) + top.getDistance(node->m_fromTop) + node->m_fromTop.getDistance(bp);
//            value = value1 + bp.getDistance(end);
//        }
//        if (value < m_value) {
//            m_inflexion = node->inflexionList();
//            m_topPoint = cocos2d::Vec2::ZERO;
//            m_bottomPoint = cocos2d::Vec2::ZERO;
//            m_fromTop = tp;
//            m_fromBot = bp;
//            m_inflexion.push_back(in1);
//            if (in1 != in2 && in2 != cocos2d::Vec2::ZERO)
//                m_inflexion.push_back(in2);
//            m_inflexion.push_back(in3);
//            m_startPoint = in3;
//            m_value1 = value1;
//            m_value = value;
//            m_mark = false;
//        }
        return;
    }
    
    float value1 = 0;
    float value = MAXFLOAT;
    cocos2d::Point in1;
    cocos2d::Point in2;
    cocos2d::Point in3;
    if ((bot-start).cross(tp-start) > 0) {
        
        value1 = node->value1() + bot.getDistance(start);
        //        m_fromList = node->fromList();
        //        m_fromList.push_back(node);
        std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
        fl.push_back(node);
        std::vector<cocos2d::Point> sl;
//        sl.push_back(start);
        updateValueWithList4(end, sl, bot, value1, fl, tp, bp, node->inflexionList());
//        if ((node->m_fromBot-bot).cross(tp-bot) > 0) {
//            value1 = node->value1() + bot.getDistance(start) + bot.getDistance(node->m_fromBot) + node->m_fromBot.getDistance(tp);
//            in2 = node->m_fromBot;
//        } else {
//            value1 = node->value1() + bot.getDistance(start) + bot.getDistance(tp);
//        }
//        
//        in1 = bot;
//        in3 = tp;
//        value = value1 + tp.getDistance(end);
//        if (value < m_value) {
//            m_inflexion = node->inflexionList();
//            m_topPoint = cocos2d::Vec2::ZERO;
//            m_bottomPoint = cocos2d::Vec2::ZERO;
//            m_inflexion.push_back(in1);
//            if (in2 != cocos2d::Vec2::ZERO)
//                m_inflexion.push_back(in2);
//            m_inflexion.push_back(in3);
//            m_fromTop = tp;
//            m_fromBot = bp;
//            m_startPoint = in3;
//            m_value1 = value1;
//            m_value = value;
//            m_mark = false;
//        }
        return;
    }
    
    in2 = cocos2d::Vec2::ZERO;
    if ((top-start).cross(bp-start) < 0) {
        
        value1 = node->value1() + top.getDistance(start);
        //        m_fromList = node->fromList();
        //        m_fromList.push_back(node);
        std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
        fl.push_back(node);
        std::vector<cocos2d::Point> sl;
//        sl.push_back(start);
        updateValueWithList4(end, sl, top, value1, fl, tp, bp, node->inflexionList());
//        if ((node->m_fromTop - top).cross(bp-top) < 0) {
//            in2 = node->m_fromTop;
//            value1 = node->value1() + top.getDistance(start) + top.getDistance(node->m_fromTop) + node->m_fromTop.getDistance(bp);
//        } else {
//            value1 = node->value1() + top.getDistance(start) + top.getDistance(bp);
//        }
//        in1 = top;
//        in3 = bp;
//        value = value1 + bp.getDistance(end);
//        if (value < m_value) {
//            m_inflexion = node->inflexionList();
//            m_topPoint = cocos2d::Vec2::ZERO;
//            m_bottomPoint = cocos2d::Vec2::ZERO;
//            m_inflexion.push_back(in1);
//            if (in2 != cocos2d::Vec2::ZERO)
//                m_inflexion.push_back(in2);
//            m_inflexion.push_back(in3);
//            m_fromTop = tp;
//            m_fromBot = bp;
//            m_startPoint = in3;
//            m_value1 = value1;
//            m_value = value;
//            m_mark = false;
//        }
        return;
    }

    cocos2d::Point finalTP, finalBP;
    if ((tp-start).cross(top-start) <= 0) {
        finalTP = tp;
    } else {
        finalTP = top;
    }
    
    if ((bp-start).cross(bot-start) < 0) {
        finalBP = bot;
    } else {
        finalBP = bp;
    }
    
    if ((end-start).cross(finalTP-start) > 0) {
        value1 = node->value1() + finalTP.getDistance(start);
        value = value1 + finalTP.getDistance(end);
        if (m_findDone) {
            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
            fl.push_back(node);
            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            updateValueWithList42(end, sl, finalTP, value1, fl, tp, bp, node->inflexionList());
        } else if (value < m_value) {
            m_inflexion = node->inflexionList();
            m_startPoint = node->startPoint();
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_fromTop = tp;
            m_fromBot = bp;
            m_fromList = node->fromList();
            m_fromList.push_back(node);
            m_value1 = node->value1();
            m_value = value;
            m_mark = false;
        }
//        if (m_findDone) {
//            m_inflexion.push_back(finalTP);
//        }
        return;
    }
    if ((end-start).cross(finalBP-start) < 0) {
        value1 = node->value1() + finalBP.getDistance(start);
        value = value1 + finalBP.getDistance(end);
        if (m_findDone) {
            std::vector<std::shared_ptr<RouteNode>> fl = node->fromList();
            fl.push_back(node);
            std::vector<cocos2d::Point> sl;
//            sl.push_back(start);
            updateValueWithList42(end, sl, finalBP, value1, fl, tp, bp, node->inflexionList());
        } else if (value < m_value) {
            m_inflexion = node->inflexionList();
            m_startPoint = node->startPoint();
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_fromList = node->fromList();
            m_fromList.push_back(node);
            m_fromTop = tp;
            m_fromBot = bp;
            m_value1 = node->value1();
            m_value = value;
            m_mark = false;
        }
//        if (m_findDone) {
//            m_inflexion.push_back(finalBP);
//        }
        return;
    }
    
    value1 = node->value1();
    value = value1 + start.getDistance(end);
    if (value < m_value) {
        m_inflexion = node->inflexionList();
        m_startPoint = node->startPoint();
        m_fromList = node->fromList();
        m_fromList.push_back(node);
        m_topPoint = finalTP;
        m_bottomPoint = finalBP;
        m_fromTop = tp;
        m_fromBot = bp;
        m_value1 = node->value1();
        m_value = value;
        m_mark = false;
    }
}

void RouteNode::updateValue(cocos2d::Point &end, std::shared_ptr<Line> &line, std::shared_ptr<RouteNode> &node, int idx)
{
//    CCLOG("12");
    cocos2d::Point start = node->startPoint();
//    float
    std::shared_ptr<Line> &l1 = m_lineList[1];
    std::shared_ptr<Line> &l3 = m_lineList[3];
    cocos2d::Point &top = node->m_topPoint;
    cocos2d::Point &bot = node->m_bottomPoint;
    cocos2d::Point &lineSP = line->startPoint();
    cocos2d::Point &lineEP = line->endPoint();
    cocos2d::Point &lSP1 = l1->startPoint();
    cocos2d::Point &lEP1 = l1->endPoint();
    cocos2d::Point &lSP3 = l3->startPoint();
    cocos2d::Point &lEP3 = l3->endPoint();
    
    float topAngle = 0, botAngle = 0;
    if (top != cocos2d::Vec2::ZERO || bot != cocos2d::Vec2::ZERO) {
        topAngle = (top-start).getAngle();
        botAngle = (bot-start).getAngle();
    } else {
        if (idx == 2) {
            topAngle = (lSP1-start).getAngle();
            botAngle = (lEP1-start).getAngle();
        } else {
            topAngle = (lEP3-start).getAngle();
            botAngle = (lSP3-start).getAngle();
        }
    }
    
    float ag = (end-start).getAngle();
    float lineTop = 0, lineBot = 0, mTop = 0, mBot = 0;
    
    if (idx == 2) {
        lineTop = (line->startPoint()-start).getAngle();
        lineBot = (line->endPoint()-start).getAngle();
        mTop = (l3->endPoint()-start).getAngle();
        mBot = (l3->startPoint()-start).getAngle();
    } else {
        lineTop = (line->endPoint()-start).getAngle();
        lineBot = (line->startPoint()-start).getAngle();
        mTop = (l1->startPoint()-start).getAngle();
        mBot = (l1->endPoint()-start).getAngle();
    }
    
    if (idx == 2 && (topAngle > M_PI_2 || topAngle < -M_PI_2)) {
        float value1 = 0;
        float value = MAXFLOAT;
        cocos2d::Point in1;
        cocos2d::Point in2;
        if ((topAngle < 0 && mTop < 0 && mTop > topAngle) ||
            (topAngle > 0 && (mTop < 0 || mTop > topAngle))) {
            in1 = bot;
            in2 = lEP3;
            value1 = node->value1() + bot.getDistance(start) + bot.getDistance(lEP3);
            value = value1 + lEP3.getDistance(end);
        } else {
            in1 = top;
            in2 = lSP3;
            value1 = node->value1() + top.getDistance(start) + top.getDistance(lSP3);
            value = value1 + lSP3.getDistance(end);
        }
        
        if (value < m_value) {
            m_inflexion = node->inflexionList();
            m_topPoint = cocos2d::Vec2::ZERO;
            m_bottomPoint = cocos2d::Vec2::ZERO;
            m_inflexion.push_back(in1);
            m_inflexion.push_back(in2);
            m_startPoint = in2;
            m_value1 = value1;
            m_value = value;
            m_mark = false;
        }
        return;
    }
    
    if (idx == 4 && topAngle < M_PI_2 && topAngle > -M_PI_2) {
        float value1 = 0;
        float value = MAXFLOAT;
        cocos2d::Point in1;
        cocos2d::Point in2;
        if (topAngle > mTop) {
            in1 = bot;
            in2 = lSP1;
            value1 = node->value1() + bot.getDistance(lSP1) + bot.getDistance(start);
            value = value1 + lSP1.getDistance(end);
        } else {
            in1 = top;
            in2 = lEP1;
            value1 = node->value1() + top.getDistance(start) + top.getDistance(lEP1);
            value = value1 + lEP1.getDistance(end);
        }
        if (value < m_value) {
            m_inflexion = node->inflexionList();
            m_topPoint = cocos2d::Vec2::ZERO;
            m_bottomPoint = cocos2d::Vec2::ZERO;
            m_inflexion.push_back(in1);
            m_inflexion.push_back(in2);
            m_startPoint = in2;
            m_value1 = value1;
            m_value = value;
            m_mark = false;
        }
        return;
    }
    
    cocos2d::Point tp, bp;
    float topa = 0, bota = 0;
    if (idx == 2) {
        if (lineTop > mTop) {
            tp = lEP3;
            topa = mTop;
        } else {
            tp = lineSP;
            topa = lineTop;
        }
        if (lineBot > mBot) {
            bp = lineEP;
            bota = lineBot;
        } else {
            bp = lSP3;
            bota = mBot;
        }
        
        float value1 = 0;
        float value = MAXFLOAT;
        cocos2d::Point in1;
        cocos2d::Point in2;
        if (topa < botAngle) {
            in1 = bot;
            in2 = lEP3;
            value1 = node->value1() + bot.getDistance(start) + bot.getDistance(lEP3);
            value = value1 + lEP3.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_inflexion.push_back(in1);
                m_inflexion.push_back(in2);
                m_startPoint = in2;
                m_value1 = value1;
                m_value = value;
                m_mark = false;
            }
            return;
        }
        
        if (bota > topAngle) {
            in1 = top;
            in2 = lSP3;
            value1 = node->value1() + top.getDistance(start) + top.getDistance(lSP3);
            value = value1 + lSP3.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_topPoint = cocos2d::Vec2::ZERO;
                m_bottomPoint = cocos2d::Vec2::ZERO;
                m_inflexion.push_back(in1);
                m_inflexion.push_back(in2);
                m_startPoint = in2;
                m_value1 = value1;
                m_value = value;
                m_mark = false;
            }
            return;
        }
        
        float finalTop = 0, finalBot = 0;
        cocos2d::Point finalTP, finalBP;
        if (topa > topAngle) {
            finalTP = top;
            finalTop = topAngle;
        } else {
            finalTP = tp;
            finalTop = topa;
        }
        
        if (bota > botAngle) {
            finalBP = bp;
            finalBot = bota;
        } else {
            finalBP = bot;
            finalBot = botAngle;
        }
        
        if (ag > finalTop) {
            value1 = node->value1() + finalTP.getDistance(start);
            value = value1 + finalTP.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_startPoint = node->startPoint();
                m_topPoint = finalTP;
                m_bottomPoint = finalBP;
                m_value1 = node->value1();
                m_value = value;
                m_mark = false;
            }
            return;
        }
        if (ag < finalBot) {
            value1 = node->value1() + finalBP.getDistance(start);
            value = value1 + finalBP.getDistance(end);
            if (value < m_value) {
                m_inflexion = node->inflexionList();
                m_startPoint = node->startPoint();
                m_topPoint = finalTP;
                m_bottomPoint = finalBP;
                m_value1 = node->value1();
                m_value = value;
                m_mark = false;
            }
            return;
        }
        
        value1 = node->value1();
        value = value1 + start.getDistance(end);
        if (value < m_value) {
            m_inflexion = node->inflexionList();
            m_startPoint = node->startPoint();
            m_topPoint = finalTP;
            m_bottomPoint = finalBP;
            m_value1 = node->value1();
            m_value = value;
            m_mark = false;
        }
        
    } else {
        if (lineTop > mTop) {
            tp = lEP3;
            topa = mTop;
        } else {
            tp = lineSP;
            topa = lineTop;
        }
        if (lineBot > mBot) {
            bp = lineEP;
            bota = lineBot;
        } else {
            bp = lSP3;
            bota = mBot;
        }

    }
    
    
    
}

void RouteFinder::setStartPoint(cocos2d::Point &point)
{
//    CCLOG("13");
    lrb::base::MutexLockGuard lock(m_mutex);
    m_startPoint = point;
}

void RouteFinder::findRoute(cocos2d::Point &point)
{
//    CCLOG("14");
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        m_endPoint = point;
    }
    
    std::function<void()> f = std::bind(&RouteFinder::doFindRoute, this);
    Caculater::getInstance()->caculate(f);
}

cocos2d::Point RouteFinder::startFindPoint()
{
//    CCLOG("15");
    cocos2d::Point p;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        p = m_findStart;
    }
    return p;
}

cocos2d::Point RouteFinder::endFindPoint()
{
//    CCLOG("16");
    cocos2d::Point p;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        p = m_findEnd;
    }
    return p;
}

void RouteFinder::fillStraightRoute(cocos2d::Point &start, cocos2d::Point &end)
{
//    CCLOG("17");
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
//    CCLOG("18");
    RouteNode::routeList list;
    return list;
}

std::shared_ptr<RouteNode> RouteFinder::findRoutePath(cocos2d::Point &start, cocos2d::Point &end)
{
//    CCLOG("19");
    pathList list;
    RouteData *instance = RouteData::getInstance();
    std::vector<std::shared_ptr<RouteNode> > rList;
    auto node = instance->findRouteNode(start);
    if (!node)
        return nullptr;
    
    node->setStartPoint(start);
    
//    node->addStartPoint(start);
    node->mark();
    rList.push_back(node);
    std::set<std::shared_ptr<RouteNode>> rset;
    while(!rList.empty()) {
        auto bptr = rList.back();
        rList.pop_back();
        rset.erase(bptr);
        
        int idx = 0;
        for (auto &line : bptr->allLines()) {
            RouteNode::routeList nList = instance->routeNodeForLine(line);
            if (line->startPoint().x == 255 && line->startPoint().y == 1160) {
                int a = 1;
                a++;
            }
            ++idx;
            int ftype = bptr->type();
            for (auto &n : nList) {
                if (n == bptr || (ftype == RouteNode::kNormalMove && n->type() == RouteNode::kBuildMove))
                    continue;
                
                switch (idx) {
                    case 1:
                    case 3:
                        n->updateValue1(end, line, bptr, idx);
                        break;
                        
                    case 2:
                        n->updateValue2(end, line, bptr);
                        break;
                        
                    case 4:
                        n->updateValue4(end, line, bptr);
                        break;
                        
                    default:
                        break;
                }
//                if (idx == 1 || idx == 3) {
//                    n->updateValue1(end, line, bptr, idx);
//                } else {
//                    n->updateValue(end, line, bptr, idx);
//                }
                if (n->isFindDone()) {
                    return n;
                }
                
                if (!n->isMarked()) {
                    n->mark();
                    if (rset.insert(n).second)
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
//    CCLOG("find route");
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
        
//        cocos2d::Point &s = last->startPoint();
        std::vector<cocos2d::Point> &pl = last->inflexionList();
        cocos2d::Point ed = end;
        
        while (!pl.empty()) {
            cocos2d::Point &p1 = pl.back();
            std::shared_ptr<Line> line(new Line(p1, ed));
            list.push_back(line);
            ed = p1;
            pl.pop_back();
        }
        std::shared_ptr<Line> line(new Line(start, ed));
        list.push_back(line);
//        CCLOG("startx-%f, starty-%f, endx-%f, endy-%f", s.x, s.y, end.x, end.y);
        
//        while(last->from().lock()) {
//            cocos2d::Point &s1 = last->startPoint();
//            if (last->startPoint() != s) {
//                CCLOG("startx-%f, starty-%f", s1.x, s1.y);
//                std::shared_ptr<Line> l(new Line(s1, s));
//                list.push_back(l);
//                s = s1;
//            }
//            
//            last = last->from().lock();
//        }
        
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
//    CCLOG("20");
//    m_startList.clear();
//    m_endList.clear();
//    {
        m_pathList1.clear();
        lrb::base::MutexLockGuard lock(m_mutex2);
        m_pathList.clear();
    
//    }
//    m_routeMap.clear();
//    m_lineList.clear();
}

RouteFinder::pathList &RouteFinder::finalRoutePath()
{
    bool flag = false;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        if (m_startPoint != m_findStart || m_endPoint != m_findEnd) {
            flag = true;
        }
    }
    if (flag) {
        m_pathList1.clear();
        return m_pathList1;
    }
    
    return currentRoutePath();
}

RouteFinder::pathList &RouteFinder::currentRoutePath()
{
//    CCLOG("21");
    {
        lrb::base::MutexLockGuard lock(m_mutex2);
        if (!m_pathList.empty()) {
//            m_pathList1.swap(m_pathList);
            m_pathList1.clear();
            for (auto &l : m_pathList) {
                sgzj::Line *line = Line::create(l->startPoint(), l->endPoint());
                m_pathList1.pushBack(line);
            }
            m_pathList.clear();
            
        }
    }
    
    return m_pathList1;
    //    return m_pathList;
}

RouteFinder *RouteFinder::create()
{
//    CCLOG("22");
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
//    CCLOG("23");
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
//    CCLOG("24");
    m_routeMap[line] = node;

}

void RouteData::addRouteNode(std::vector<cocos2d::Point> &vec, int type)
{
//    CCLOG("25");
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
    
    for (auto &l : m_lineList) {
        cocos2d::Point ps = l->startPoint();
        cocos2d::Point pe = l->endPoint();
        
        if (cocos2d::Point::isSegmentOverlap(ps, pe, p1, p2, &s, &e)) {
            if (s != e) {
                line1->relateTo(l);
                l->relateTo(line1);
            }
        }
        
        if (cocos2d::Point::isSegmentOverlap(ps, pe, p3, p4, &s, &e)) {
            if (s != e) {
                line3->relateTo(l);
                l->relateTo(line3);
            }
        }
    }
    
    for (auto &l : m_lineList1) {
        cocos2d::Point ps = l->startPoint();
        cocos2d::Point pe = l->endPoint();

        if (cocos2d::Point::isSegmentOverlap(ps, pe, p2, p3, &s, &e)) {
            if (s != e) {
                line2->relateTo(l);
                l->relateTo(line2);
            }
        }
        
        if (cocos2d::Point::isSegmentOverlap(ps, pe, p4, p1, &s, &e)) {
            if (s != e) {
                line4->relateTo(l);
                l->relateTo(line4);
            }
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
    m_lineList.push_back(line3);
    m_lineList1.push_back(line2);
    m_lineList1.push_back(line4);
    
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
//    CCLOG("26");
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
//    node->drawLine(cocos2d::Point(580, 515), cocos2d::Point(951.122558, 1063.51501), cocos2d::Color4F(0,0,1,1));
//    node->drawLine(cocos2d::Point(680, 485), cocos2d::Point(951.122558, 1063.51501), cocos2d::Color4F(0,0,1,1));
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
//    CCLOG("27");
    for (auto &node : m_routeList) {
        if (node->isContainPoint(point))
            return node;
    }
    
    return nullptr;
}


void RouteData::clear()
{
//    CCLOG("28");
    while (!m_routeList.empty()) {
        destroyNode(m_routeList.back());
    }
}

void RouteData::reset()
{
//    CCLOG("29");
    for (auto &n : m_routeList)
        n->reset();
}

void RouteData::destroyNode(std::shared_ptr<RouteNode> &node)
{
//    CCLOG("30");
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
//    CCLOG("31");
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

void RouteData::processGate(std::vector<tinyxml2::XMLElement *> &vec, std::string &luaTxt)
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

void RouteData::processMoveable(tinyxml2::XMLElement *ele, tinyxml2::XMLElement *root, tinyxml2::XMLDocument &doc)
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

void RouteData::processBuild(tinyxml2::XMLElement *ele, tinyxml2::XMLElement *root, tinyxml2::XMLDocument &doc)
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

void RouteData::processRoot(tinyxml2::XMLElement *ele)
{
//    CCLOG("38");
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
//    CCLOG("39");
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
//    CCLOG("40");
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
//    CCLOG("41");
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
//    CCLOG("42");
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
//    CCLOG("43");
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
    m_lineList1.clear();
}

void RouteData::loadRouteConfig(std::string &path)
{
//    CCLOG("44");
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









