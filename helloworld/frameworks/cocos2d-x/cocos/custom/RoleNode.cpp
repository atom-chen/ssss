//
//  RoleNode.cpp
//  cocos2d_libs
//
//  Created by reid on 16/6/6.
//
//

#include "RoleNode.hpp"


using namespace sgzj;

RoleNode::~RoleNode()
{
//    CCLOG("45");
    m_finder->release();
}

bool RoleNode::init()
{
//    CCLOG("46");
    if (Node::init()) {
        m_finder = new RouteFinder();
        return m_finder != nullptr;
    }
    
    return false;
}

void RoleNode::setStartPoint(cocos2d::Point &point)
{
//    CCLOG("47");
    m_finder->setStartPoint(point);
}

void RoleNode::findRoute(cocos2d::Point &point)
{
//    CCLOG("48");
    m_finder->findRoute(point);
}

void RoleNode::setDrawNode(cocos2d::DrawNode *node)
{
    m_drawNode = node;
}

bool RoleNode::isPointCanReach(cocos2d::Point &p)
{
    std::shared_ptr<RouteNode> node = RouteData::getInstance()->findRouteNode(p);
    return node != nullptr;
}

void RoleNode::drawNodeRect(cocos2d::Point &p1, cocos2d::Point &p2, cocos2d::Point &p3, cocos2d::Point &p4)
{
    m_drawNode->clear();
    const cocos2d::Point &p = this->getPosition();
    const cocos2d::Point &an = this->getAnchorPoint();
    const cocos2d::Size &s = this->getContentSize();
    
    cocos2d::Point pp1(p.x-s.width*an.x, p.y-s.height*an.y);
    cocos2d::Point pp2(p.x+s.width*(1-an.x), p.y+s.height*(1-an.y));
//    cocos2d::Point pp1 = this->convertToWorldSpace(cocos2d::Point(0,0));
//    cocos2d::Point pp2 = this->convertToWorldSpace(cocos2d::Point(s.width, s.height));
    m_drawNode->drawRect(pp1, pp2, cocos2d::Color4F(1,0,0,1));
    cocos2d::Node *parent = this->getParent();
    
    m_drawNode->drawRect(parent->convertToNodeSpace(p1), parent->convertToNodeSpace(p2), parent->convertToNodeSpace(p3), parent->convertToNodeSpace(p4), cocos2d::Color4F(0,0,1,1));
    
}

void RoleNode::drawRoutePath()
{
//    CCLOG("49");
    cocos2d::Point start = m_finder->startFindPoint();
    cocos2d::Point end = m_finder->endFindPoint();
    if (m_pathStart == start && m_pathEnd == end)
        return;
    
    m_pathStart = start;
    m_pathEnd = end;
    m_drawNode->clear();
    m_drawNode->setLineWidth(5);
    RouteFinder::pathList list = m_finder->finalRoutePath();
    for (auto &line : list) {
        m_drawNode->drawLine(line->startPoint(), line->endPoint(), cocos2d::Color4F(0,0,1,1));
    }
}

void RoleNode::clearPath()
{
    m_drawNode->clear();
}

RoleNode *RoleNode::create()
{
    RoleNode *node = new RoleNode();
    if (node && node->init()) {
        node->autorelease();
        return node;
    }
    
    CC_SAFE_DELETE(node);
    return nullptr;
}


