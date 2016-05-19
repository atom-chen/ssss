#include "EventChannel.h"

using namespace lrb::base;

EventChannel::EventChannel(EventLoop *loop, int fd) : 
	Channel(loop, fd) 
{

};

EventChannel::~EventChannel()
{

}



void EventChannel::handleEvents()
{
    while(true) {
        funcList highList;
        {
            MutexLockGuard lock(m_lock);
            if (m_funcsHigh.empty()) {
                break;
            }
            highList.swap(m_funcsHigh);
        }
        
        for (funcList::iterator iter = highList.begin();iter != highList.end(); ++iter) {
            (*iter)();
        }
    }

    while(true) {
        funcList normalList;
        {
            MutexLockGuard lock(m_lock);
            if (m_funcsNormal.empty()) {
                break;
            }
            normalList.swap(m_funcsNormal);
        }
        
        for (funcList::iterator iter = normalList.begin(); iter != normalList.end(); ++iter) {
            (*iter)();
        }
    }
	
	Channel::handleEvents();
}

void EventChannel::addFunc(Func &func, EventLevel lvl)
{
	MutexLockGuard lock(m_lock);
	addFuncSafe(func, lvl);
}

void EventChannel::addFuncSafe(Func &func, EventLevel lvl)
{
	switch (lvl) {
		case Normal:
			m_funcsNormal.push_back(func);
			break;
		
		case High:
			m_funcsHigh.push_back(func);
			break;

		default:
			break;
	}

}

