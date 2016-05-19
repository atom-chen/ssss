//
//  Caculater.hpp
//  helloworld
//
//  Created by reid on 16/5/9.
//
//

#ifndef Caculater_hpp
#define Caculater_hpp

#include <stdio.h>
#include <mutex>
#include <memory>
#include "base.h"
#include "EventLoop.h"


namespace sgzj {
    class Caculater : lrb::base::noncopyable {
    public:
        typedef lrb::base::EventLoop::Func Func;
        void caculate(Func &func);
        static Caculater *getInstance();
        
        void start();
        void resetEventLoop();
        
        ~Caculater();
        
    private:
        
        std::unique_ptr<lrb::base::EventLoop> m_loop;
        
    };
}


#endif /* Caculater_hpp */
