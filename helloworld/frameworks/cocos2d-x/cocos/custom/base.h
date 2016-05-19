#ifndef LRB_BASE_H
#define LRB_BASE_H



namespace lrb {

	namespace base {

		class noncopyable {
			protected:
				noncopyable(){};
				~noncopyable(){};
			private:
				noncopyable(const noncopyable &);
				const noncopyable & operator = (const noncopyable &);

		};
	}

}


#endif
