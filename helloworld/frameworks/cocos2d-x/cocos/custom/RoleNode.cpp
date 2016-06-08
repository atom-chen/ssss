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
    CCLOG("45");
    m_finder->release();
}

bool RoleNode::init()
{
    CCLOG("46");
    if (Node::init()) {
        m_finder = new RouteFinder();
        return m_finder != nullptr;
    }
    
    return false;
}

void RoleNode::setStartPoint(cocos2d::Point &point)
{
    CCLOG("47");
    m_finder->setStartPoint(point);
}

void RoleNode::findRoute(cocos2d::Point &point)
{
    CCLOG("48");
    m_finder->findRoute(point);
}

void RoleNode::drawRoutePath(cocos2d::DrawNode *node)
{
    CCLOG("49");
    cocos2d::Point start = m_finder->startFindPoint();
    cocos2d::Point end = m_finder->endFindPoint();
    if (m_pathStart == start && m_pathEnd == end)
        return;
    
    node->clear();
    node->setLineWidth(5);
    RouteNode::lineList list = m_finder->currentRoutePath();
    for (auto &line : list) {
        node->drawLine(line->startPoint(), line->endPoint(), cocos2d::Color4F(0,0,1,1));
    }
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


