#include "EventLoop.h"
#include <sys/socket.h>
#include <fcntl.h>
#include <unistd.h>
#include <assert.h>

//namespace {
//
//	__thread lrb::base::EventLoop *t_loopInThisThread = NULL;
//
//}

using namespace lrb::base;

//EventLoop *EventLoop::currentThreadLoop()
//{
//	return t_loopInThisThread;
//}

EventLoop::EventLoop():
	m_quit(false),
	m_poller(new Poller())
{
//	assert(t_loopInThisThread == NULL);
//	t_loopInThisThread = this;
    m_threadId = pthread_self();
	createEventChannel();
}

EventLoop::~EventLoop()
{

}

void EventLoop::loop()
{
	while(!m_quit && !m_poller->empty()) {
		m_poller->poll();
	}
}

void EventLoop::runInLoop(Func &func, EventChannel::EventLevel lvl)
{	
	if (isCurrentThreadLoop()) {
        
		m_eventChannel->addFuncSafe(func, lvl);
	} else {
		m_eventChannel->addFunc(func, lvl);
        
		wakeup();
	}
}

void EventLoop::updateChannel(Channel *channel)
{
	m_poller->updateChannel(channel);
}

void EventLoop::removeChannel(Channel *channel)
{
	assert(isCurrentThreadLoop());
	m_poller->removeChannel(channel);
}

void EventLoop::createEventChannel() 
{
	int fds[2];
	assert(socketpair(AF_UNIX, SOCK_STREAM, 0, fds) == 0);
	
	int flags = fcntl(fds[0], F_GETFL);
	assert(flags != -1);
	assert(fcntl(fds[0], F_SETFL, flags | O_NONBLOCK) != -1);
	flags = fcntl(fds[1], F_GETFL);
	assert(flags != -1);
	assert(fcntl(fds[1], F_SETFL, flags | O_NONBLOCK) != -1);

	int len = 1;
	assert(setsockopt(fds[0], SOL_SOCKET, SO_SNDBUF, &len, sizeof(len)) == 0);
	assert(setsockopt(fds[1], SOL_SOCKET, SO_RCVBUF, &len, sizeof(len)) == 0);
	m_awakeFd = fds[0];

	m_eventChannel.reset(new EventChannel(this, fds[1]));
    std::function<void()> f = std::bind(&EventLoop::readEventChannel, this);
    m_eventChannel->setReadCallback(f);
	m_eventChannel->enableReading();
}

bool EventLoop::isCurrentThreadLoop() 
{
	return pthread_equal(m_threadId, pthread_self());
//    return true;
}

void EventLoop::wakeup() 
{
	char one = 1;
	write(m_awakeFd, &one, sizeof(one));	
}

void EventLoop::readEventChannel()
{
    char one;
    read(m_eventChannel->fd(), &one, sizeof(one));
}


