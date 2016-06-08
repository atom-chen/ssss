#include <string>
#include <iostream>
#include <memory>
#include <vector>
#include <map>

int main(int argc, char **argv)
{

	std::shared_ptr<int> p(new int(3));
	std::shared_ptr<int> p1(new int(3));

	std::map<std::shared_ptr<int>, int> map;
	map[p] = 10;
	map[p1] = 11;
	map.erase(p1);
	std::cout << map[p] << std::endl;
	std::cout << map[p1] << std::endl;
}
