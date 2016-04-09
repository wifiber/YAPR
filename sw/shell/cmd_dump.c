/*
 * This work is part of the White Rabbit project
 *
 * Copyright (C) 2012 CERN (www.cern.ch)
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */
#include <stdlib.h>
#include <string.h>
#include <wrc.h>
#include <shell.h>


static int cmd_dump(const char *args[])
{
    
    volatile int *p = (int *)strtol(args[0], NULL, 16);
    
    int i = 0;
    pp_printf(" Start : %08x\n Length: %08x (x4: %08x)\n Finish: %08x\n\n" \
            , strtol(args[0], NULL, 16), atoi(args[1]), (atoi(args[1])*4) \
            , (strtol(args[0], NULL, 16) + (atoi(args[1])*4)));
    
    for (i; i <= atoi(args[1]); i++){
        pp_printf("Address: %08x - Value: %08x\n", p, *p);
        p++;
    }
	return 0;
}

DEFINE_WRC_COMMAND(dump) = {
	.name = "dump",
	.exec = cmd_dump,
};
