#include "Helper.h"

int main(int argc, char *argv[])
{
	NameHelper helper(argv[1]);
	helper.writeRenameEx();

	return 0;
}