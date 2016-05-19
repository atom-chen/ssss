//
//  FightNode.hpp
//  helloworld
//
//  Created by reid on 16/5/10.
//
//

#ifndef FightNode_hpp
#define FightNode_hpp

#include <stdio.h>
#include <vector>
#include "cocos2d.h"
#include "Mutex.h"


namespace sgzj {
    
    class FightNode;
    class FightResult : public cocos2d::Ref {
    public:
        
        static FightResult *create(FightNode *att, FightNode *def, int dtype, float damage);
        
        int nodeId() {return m_nodeId;};
        float damage() {return m_damage;};
        bool isDead() {return m_isDead;};
        
    private:
        FightResult(FightNode *att, FightNode *def, int dtype, float damage);
        ~FightResult();
        
        int m_nodeId;
        float m_damage;
        bool m_isDead;
    };
    
    
    class FightNode : public cocos2d::Ref {
    public:
//        typedef struct {
//            int nodeId;
//            float damage;
//            bool isDead;
//        } FightResult;
        
        typedef cocos2d::Vector<FightResult *> resultList;
        
    private:
        cocos2d::Point m_standPos;
        
        float m_phyAttack;
        float m_phyDefence;
        float m_phyRatio;
        
        float m_magicAttack;
        float m_magicDefence;
        float m_magicRatio;
        
        float m_health;
        
        float m_damage;
        
        int m_nodeId;
        
        resultList m_result;
        
        lrb::base::MutexLock m_mutex;
        
        FightNode(int nodeId, float phyAtt, float phyDef, float phyRatio, float magicAtt, float magicDef, float magicRatio, float health);
        ~FightNode();
        
    public:
        
        static FightNode *create(int nodeId, float phyAtt, float phyDef, float phyRatio, float magicAtt, float magicDef, float magicRatio, float health = 0);
        
        void setStandPos(cocos2d::Point &pos) {m_standPos.x = pos.x; m_standPos.y = pos.y;};
        
        void AddFightResult(FightResult *result);
        
        void mergeDamage() {m_health -= m_damage;};
        
        void setDamage(float damage) {m_damage = damage;};
        float damage() {return m_damage;};
        
        int nodeId() {return m_nodeId;};
        float phyAttack() {return m_phyAttack;};
        float phyDefence() {return m_phyDefence;};
        float phyRatio() {return m_phyRatio;};
        
        float magicAttack() {return m_magicAttack;};
        float magicDefence() {return m_magicDefence;};
        float magicRatio() {return m_magicRatio;};
        
        float health() {return m_health;};
        
        bool isDead() {return m_health <= 0;};
        
        cocos2d::Point standPos() {return m_standPos;};
        
        resultList getResultList();
        
    };
}

#endif /* FightNode_hpp */
