#include <stdio.h>
#include "config.h"


void test(int var)
{
	int a=var;
	printf("test %d\n", a);
}

int main(void)
{
	int ret = 0;
//	int testvar;

	printf("Hello World without knet\n");
//	test(testvar);

	return ret;
}
