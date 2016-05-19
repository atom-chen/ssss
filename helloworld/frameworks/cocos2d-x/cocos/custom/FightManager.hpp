//
//  FightManager.hpp
//  helloworld
//
//  Created by reid on 16/5/10.
//
//

#ifndef FightManager_hpp
#define FightManager_hpp

#include <stdio.h>
#include <vector>
#include <memory>
#include "Mutex.h"
#include "FightNode.hpp"

namespace sgzj {
    
    class FightManager : public cocos2d::Ref {
        
    public:
        
        static FightManager *getInstance();
        
        void addFightNode(FightNode *node);
        void removeFightNode(FightNode *node);
        
        void handleAttack(FightNode *att, FightNode *target, int dtype, float damage, bool back);
        void handleAOE(FightNode *att, int dtype, float damage, float range);
        
        void flushDamage();
        
    private:
        typedef cocos2d::Vector<FightNode *> nodeList;
        
        void doAddFightNode(FightNode *node);
        void doRemoveFightNode(FightNode *node);
        void doHandleAttack(FightNode *att, FightNode *target, int dtype, float damage, bool back);
        void doHandleAOE(FightNode *att, int dtype, float damage, float range);
        void doFlushDamage();
        
        nodeList m_nodeList;
        
    };
    
}

#endif /* FightManager_hpp */
