//
//  RoleNode.hpp
//  cocos2d_libs
//
//  Created by reid on 16/6/6.
//
//

#ifndef RoleNode_hpp
#define RoleNode_hpp

#include <stdio.h>
#include "cocos2d.h"
#include "RouteFinder.hpp"


namespace sgzj {
    
    class RoleNode : public cocos2d::Node {
    public:

        static RoleNode *create();
        ~RoleNode();
        void setStartPoint(cocos2d::Point &point);
        void findRoute(cocos2d::Point &point);
        void drawRoutePath();
        void setDrawNode(cocos2d::DrawNode *node);
        RouteFinder::pathList &currentPath() {return m_finder->finalRoutePath();};
        bool isFindDone() {return m_finder->isFindDone();};
        static bool isPointCanReach(cocos2d::Point &p);
        void clearPath();
        void drawNodeRect(cocos2d::Point &p1, cocos2d::Point &p2, cocos2d::Point &p3, cocos2d::Point &p4);
        
    private:
        virtual bool init() override;
        cocos2d::Point m_pathStart;
        cocos2d::Point m_pathEnd;
        RouteFinder *m_finder;
        cocos2d::DrawNode *m_drawNode;
    };
}



#endif /* RoleNode_hpp */
