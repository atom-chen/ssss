#ifndef LRB_BASE_EVENTLOOP_H
#define LRB_BASE_EVENTLOOP_H

#include "base.h"
#include "Mutex.h"
#include "Poller.h"
#include "EventChannel.h"
#include <memory>
#include <vector>
#include <functional>

namespace lrb {

	namespace base {
//可以由使用者自己控制创建全局loop，在其他线程获得使用
		class EventLoop : public noncopyable {
			friend class Channel;
			public:

				typedef std::function<void()> Func;

				EventLoop();
				~EventLoop();
				void loop();
				void quit() {m_quit = true;};
				void runInLoop(Func &func, EventChannel::EventLevel lvl = EventChannel::Normal);
				
//				static EventLoop *currentThreadLoop();
			private:
				void updateChannel(Channel *channel);
				void removeChannel(Channel *channel);
				void createEventChannel();
				bool isCurrentThreadLoop();
				void wakeup();
            
                void readEventChannel();

				bool m_quit;
				int m_awakeFd;
				MutexLock m_lock;
				std::unique_ptr<Poller> m_poller;
				std::unique_ptr<EventChannel> m_eventChannel;
            
                pthread_t m_threadId;

		};
	}
}


#endif
