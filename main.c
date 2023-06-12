#include <stdio.h>
#include <libknet.h>
#include "config.h"

int main(void)
{
	knet_handle_t knet_h;
	int logfds[2];
	int ret = 0;

	logfds[0] = 0;
	logfds[1] = 0;

	knet_h = knet_handle_new(1, logfds[1], KNET_LOG_ERR);

	if (knet_h) {
		printf("Hello World etc!\n");
		knet_handle_free(knet_h);
		ret = 0;
	} else {
		printf("Knet didn´t work!!\n");
		ret = -1;
	}
	return ret;
}
