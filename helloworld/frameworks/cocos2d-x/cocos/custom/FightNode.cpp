//
//  FightNode.cpp
//  helloworld
//
//  Created by reid on 16/5/10.
//
//

#include "FightNode.hpp"


const int kDamageTypePhy = 1;
const int kDamageTypeMagic = 2;

using namespace sgzj;

FightResult::FightResult(FightNode *att, FightNode *def, int dtype, float damage):
    m_isDead(false)
{
    m_nodeId = def->nodeId();
    if (dtype == kDamageTypePhy) {
        m_damage = round(damage * def->phyRatio());
    } else if (dtype == kDamageTypeMagic) {
        m_damage = round(damage * def->magicRatio());
    }
    
    if (m_damage + def->damage() >= def->health()) {
        m_isDead = true;
    }
}

FightResult::~FightResult()
{
    
}

FightResult *FightResult::create(FightNode *att, FightNode *def, int dtype, float damage)
{
    FightResult *result = new FightResult(att, def, dtype, damage);
    result->autorelease();
    return result;
}



FightNode::FightNode(int nodeId, float phyAtt, float phyDef, float phyRatio, float magicAtt, float magicDef, float magicRatio, float health):
        m_nodeId(nodeId),
        m_phyAttack(phyAtt),
        m_phyDefence(phyDef),
        m_phyRatio(phyRatio),
        m_magicAttack(magicAtt),
        m_magicDefence(magicDef),
        m_magicRatio(magicRatio),
        m_health(health)
{
    
}

FightNode::~FightNode()
{
    
}

FightNode * FightNode::create(int nodeId, float phyAtt, float phyDef, float phyRatio, float magicAtt, float magicDef, float magicRatio, float health)
{
    FightNode *node = new FightNode(nodeId, phyAtt, phyDef, phyRatio, magicAtt, magicDef, magicRatio, health);
    node->autorelease();
    return node;
}

FightNode::resultList FightNode::getResultList()
{
    FightNode::resultList list;
    {
        lrb::base::MutexLockGuard lock(m_mutex);
        list = std::move(m_result);
    }
    
    return list;
}

void FightNode::AddFightResult(FightResult *result)
{
    lrb::base::MutexLockGuard lock(m_mutex);
    m_result.pushBack(result);
}





