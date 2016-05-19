#include "Poller.h"
//#include "LogStream.h"
#include <errno.h>
#include <assert.h>

using namespace lrb::base;


void Poller::poll() 
{
	int n = ::poll(&*m_pfds.begin(), m_pfds.size(), -1);
	if (n < 0) {
//		if (errno != EINTR) {
//			LOGERR << "poll err! errno:" << errno;
//		}
	}

	ChannelList list;
	for (PollfdList::const_iterator pfd = m_pfds.begin();pfd != m_pfds.end();++pfd) {
		if (pfd->revents == 0) 
			continue;

		ChannelMap::const_iterator iter = m_channelMap.find(pfd->fd);	
		assert(iter != m_channelMap.end());
		Channel *channel = iter->second;
		assert(channel->fd() == pfd->fd);
		channel->setrevents(pfd->revents);
		list.push_back(channel);
	}

	for (ChannelList::const_iterator iter = list.begin();iter != list.end();++iter) {
		(*iter)->handleEvents();
	}
}

void Poller::updateChannel(Channel *channel)
{
	if (channel->index() < 0) {
		addChannel(channel);
	} else {
		assert(m_channelMap.find(channel->fd()) != m_channelMap.end());
		assert(m_channelMap[channel->fd()] == channel);
		int idx = channel->index();
		struct pollfd &pfd = m_pfds[idx];
		assert(pfd.fd == channel->fd());
		pfd.events = channel->events();
		pfd.revents = 0;
	}
}

void Poller::addChannel(Channel *channel)
{
	assert(m_channelMap.find(channel->fd()) == m_channelMap.end());
	pollfd pfd;
	pfd.fd = channel->fd();
	pfd.events = channel->events();
	pfd.revents = 0;
	m_pfds.push_back(pfd);
	int idx = m_pfds.size() - 1;
	channel->setIndex(idx);
	m_channelMap[pfd.fd] = channel;
}

void Poller::removeChannel(Channel *channel)
{
	assert(m_channelMap.find(channel->fd()) != m_channelMap.end());
	assert(m_channelMap[channel->fd()] == channel);
	int idx = channel->index();
	if (idx == m_pfds.size() -1) {
		m_pfds.pop_back();
	} else {
		int endfd = m_pfds.back().fd;
		iter_swap(m_pfds.begin() + idx, m_pfds.end()-1);
		m_channelMap[endfd]->setIndex(idx);
		m_pfds.pop_back();
	}
	m_channelMap.erase(channel->fd());
}




