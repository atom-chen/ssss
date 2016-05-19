#ifndef LRB_BASE_EVENTCHANNEL_H
#define LRB_BASE_EVENTCHANNEL_H


#include "Channel.h"
#include "Mutex.h"
#include <functional>
#include <vector>


namespace lrb {

	namespace base {

		class EventChannel : public Channel {
			public:
				enum EventLevel {
					Normal,
					High
				};

				typedef std::function<void()> Func;
				
				EventChannel(EventLoop *loop, int fd);
				virtual ~EventChannel();
				void addFunc(Func &func, EventLevel lvl);
				void addFuncSafe(Func &func, EventLevel lvl);

			private:
				typedef std::vector<Func> funcList;

				void handleEvents();
				
				MutexLock m_lock;
				funcList m_funcsNormal;
				funcList m_funcsHigh;
		};
	}
}


#endif
