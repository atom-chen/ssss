#ifndef LRB_BASE_CHANNEL_H
#define LRB_BASE_CHANNEL_H


#include "base.h"
//#include "base/EventLoop.h"
#include <poll.h>
#include <functional>


namespace lrb {

	namespace base {

		class EventLoop;	
		class Channel : public noncopyable {

			friend class Poller;
			public:
				typedef std::function<void()> EventCallback;

				Channel(EventLoop *loop, int fd);
				virtual ~Channel();
				int fd() {return m_fd;};
				void enableReading();
				void disableReading();
				void enableWriting();
				void disableWriting();
				void close();

				void setReadCallback(EventCallback &cb) {m_readCallback = cb;};
				void setWriteCallback(EventCallback &cb) {m_writeCallback = cb;};
				void setCloseCallback(EventCallback &cb) {m_closeCallback = cb;};

			protected:
				virtual void handleEvents();

			private:
				short events() {return m_events;};
				void setrevents(short revents) {m_revents = revents;};
				void setIndex(int idx) {m_index = idx;};
				int index() {return m_index;};

				EventLoop *m_loop;
				int m_fd;
				short m_events;
				short m_revents;
				int m_index;
				EventCallback m_readCallback;
				EventCallback m_writeCallback;
				EventCallback m_closeCallback;
		};
	}
}


#endif
