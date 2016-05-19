#ifndef LRB_BASE_POLLER_H
#define LRB_BASE_POLLER_H

#include "base.h"
#include "Channel.h"
#include <poll.h>
#include <vector>
#include <map>

namespace lrb {

	namespace base {

		class Poller : public noncopyable {
			public:
				bool empty() {return m_pfds.empty();};
				void poll();
				void updateChannel(Channel *channel);
				void addChannel(Channel *channel);
				void removeChannel(Channel *channel);
			private:
				typedef std::vector<pollfd> PollfdList;
				PollfdList m_pfds;
				typedef std::map<int, Channel*> ChannelMap;
				ChannelMap m_channelMap;
				typedef std::vector<Channel *> ChannelList;
		};
	}
}


#endif
