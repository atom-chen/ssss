#ifndef LRB_BASE_MUTEX_LOCK_H
#define LRB_BASE_MUTEX_LOCK_H



#include "base.h"
#include <pthread.h>
#include <assert.h>

namespace lrb {

	namespace base {

		class MutexLock : public noncopyable {
			public:
				MutexLock() {assert(pthread_mutex_init(&_mutex, NULL)==0);};
				~MutexLock() {assert(pthread_mutex_destroy(&_mutex)==0);};
				void lock() {assert(pthread_mutex_lock(&_mutex)==0);};
				void unlock() {assert(pthread_mutex_unlock(&_mutex)==0);};
				pthread_mutex_t *getPthreadMutex() {return &_mutex;};
			private:
				pthread_mutex_t _mutex;
		};

		class MutexLockGuard : public noncopyable {
			public:
				explicit MutexLockGuard(MutexLock &mutex):_mutex(mutex) {_mutex.lock();};
				~MutexLockGuard() {_mutex.unlock();};
			private:
				MutexLock& _mutex;
		};
	}
}

#define MutexLockGuard(x) error "Missing guard object name"

#endif
