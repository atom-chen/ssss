#include "Channel.h"
#include "EventLoop.h"
#include <unistd.h>
#include <assert.h>


using namespace lrb::base;

Channel::Channel(EventLoop *loop, int fd):
	m_loop(loop), m_fd(fd), m_events(0), m_index(-1)
{

};

Channel::~Channel()
{

}

void Channel::handleEvents()
{
	if (m_revents & (POLLHUP | POLLNVAL | POLLERR)) {
		m_loop->removeChannel(this);
		if (m_closeCallback) m_closeCallback();
	} else if (m_revents & (POLLIN | POLLPRI)) {
        
		if (m_readCallback) m_readCallback();
	} else if (m_revents & POLLOUT) {
		if (m_writeCallback) m_writeCallback();
	}
}

void Channel::close()
{
	if (m_loop->isCurrentThreadLoop()) {
		::close(m_fd);
	} else {
		std::function<void()> f = std::bind(&Channel::close, this);
		m_loop->runInLoop(f);
	}
}

void Channel::enableReading()
{
	assert(m_loop->isCurrentThreadLoop());
	m_events |= (POLLIN | POLLPRI);
	m_loop->updateChannel(this);
}

void Channel::disableReading()
{
	assert(m_loop->isCurrentThreadLoop());
	m_events &=~(POLLIN | POLLPRI);
	m_loop->updateChannel(this);
}

void Channel::enableWriting()
{
	assert(m_loop->isCurrentThreadLoop());
	m_events |= POLLOUT;
	m_loop->updateChannel(this);
}

void Channel::disableWriting()
{
	assert(m_loop->isCurrentThreadLoop());
	m_events &= ~POLLOUT;
	m_loop->updateChannel(this);
}





