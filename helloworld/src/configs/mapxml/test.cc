#include <string>
#include <iostream>

int main(int argc, char **argv)
{


	std::string path="configs/map/3.xml";
	int idx = path.rfind("/");
	std::string move = path.insert(idx+1, "move/");

	std::cout << path << std::endl;
	std::cout << move << std::endl;
}
