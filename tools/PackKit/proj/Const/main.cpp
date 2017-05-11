#include "Helper.h"

int main(int argc, char *argv[])
{
	NameHelper helper(argv[1]);
	helper.writeConst(argv[2]);

	return 0;
}