//
//  Caculater.cpp
//  helloworld
//
//  Created by reid on 16/5/9.
//
//

#include "Caculater.hpp"
#include <thread>
#include "cocos2d.h"


using namespace sgzj;
using namespace lrb::base;

static Caculater g_sgzj_caculater;

Caculater::~Caculater()
{
    m_loop->quit();
}

static void CaculaterThread()
{
    Caculater *instance = Caculater::getInstance();
    instance->resetEventLoop();
    
}

void Caculater::start()
{
    if (m_loop)
        return;
    
    auto th = std::thread(CaculaterThread);
    th.detach();
}

void Caculater::resetEventLoop()
{
    m_loop.reset(new EventLoop());
    m_loop->loop();
}

void Caculater::caculate(Func &func)
{
    m_loop->runInLoop(func);
}

Caculater *Caculater::getInstance()
{
    return &g_sgzj_caculater;
}


