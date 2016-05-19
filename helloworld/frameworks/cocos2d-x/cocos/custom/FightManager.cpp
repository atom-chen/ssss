//
//  FightManager.cpp
//  helloworld
//
//  Created by reid on 16/5/10.
//
//

#include "FightManager.hpp"
#include "Caculater.hpp"


using namespace sgzj;

static FightManager *g_sgzj_fightmanager = NULL;
static lrb::base::MutexLock s_mutex;


FightManager *FightManager::getInstance()
{
    if (g_sgzj_fightmanager == nullptr) {
        
        lrb::base::MutexLockGuard lock(s_mutex);
        
        if (g_sgzj_fightmanager == nullptr) {
            g_sgzj_fightmanager = new FightManager();
        }
    }
    
    return g_sgzj_fightmanager;
}

void FightManager::addFightNode(FightNode *node)
{
    node->retain();
    std::function<void()> f = std::bind(&FightManager::doAddFightNode, this, node);
    Caculater::getInstance()->caculate(f);
}

void FightManager::doAddFightNode(FightNode *node)
{
    m_nodeList.pushBack(node);
    node->release();
}

void FightManager::removeFightNode(FightNode *node)
{
    std::function<void()> f = std::bind(&FightManager::doRemoveFightNode, this, node);
    Caculater::getInstance()->caculate(f);
}

void FightManager::doRemoveFightNode(FightNode *node)
{
    m_nodeList.eraseObject(node);
}

void FightManager::doHandleAttack(FightNode *att, FightNode *target, int dtype, float damage, bool back)
{
    FightResult *result = FightResult::create(att, target, dtype, damage);
    target->setDamage(result->damage());
    if (back) {
        target->AddFightResult(result);
    } else {
        att->AddFightResult(result);
    }
}

void FightManager::handleAttack(FightNode *att, FightNode *target, int dtype, float damage, bool back)
{
    
    std::function<void()> f = std::bind(&FightManager::doHandleAttack, this, att, target, dtype, damage, back);
    Caculater::getInstance()->caculate(f);

//    result.nodeId = target->nodeId();
//    if (dtype == kDamageTypePhy) {
//        result.damage = att->phyAttack() * ratio * target->phyDefence();
//    } else if (dtype == kDamageTypeMagic) {
//        result.damage = att->magicAttack() * ratio * target->magicDefence();
//    }
    
}

void FightManager::doHandleAOE(FightNode *att, int dtype, float damage, float range)
{
    for (FightNode *node : m_nodeList) {
        float distance = node->standPos().distance(att->standPos());
        if (distance <= range) {
            doHandleAttack(att, node, dtype, damage, false);
        }
    }
}

void FightManager::handleAOE(FightNode *att, int dtype, float damage, float range)
{
    std::function<void()> f = std::bind(&FightManager::handleAOE, this, att, dtype, damage, range);
    Caculater::getInstance()->caculate(f);
}

void FightManager::flushDamage()
{
    std::function<void()> f = std::bind(&FightManager::doFlushDamage, this);
    Caculater::getInstance()->caculate(f);
}

void FightManager::doFlushDamage()
{
    for (FightNode *node : m_nodeList) {
        node->mergeDamage();
    }
}









