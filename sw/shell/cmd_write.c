/*
 * This work is part of the White Rabbit project
 *
 * Copyright (C) 2012 CERN (www.cern.ch)
 * Original Author: Alessandro Rubini <rubini@gnudd.com>
 * Modified for use with YAPR Project
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */
#include <stdlib.h>
#include <string.h>
#include <wrc.h>
#include <shell.h>
#include <util.h>


static int cmd_write(const char *args[])
{
    
    volatile int *p = (int *)strtoul(args[0], NULL, 16);
    int val = strtoul(args[1], NULL, 16);
    
    int i = 0;
    int read_byte = -1;
    pp_printf("Address: %08x\nValue  : %08x\nCurrent: %08x\n", p, val, *p);
    
    if (p < (int *)0x8000){
        cprintf(C_RED, "Instruction Mem Address Space\n");
        cprintf(C_RED, "Press 1 to confirm, any else exits: ");
        read_byte = uart_read_byte();
        while (read_byte == -1){
            read_byte = uart_read_byte();
        }
        if (read_byte == 49){
            pp_printf("\nWriting Value...\n");
            *p = val;
            pp_printf("Address : %08x\nCurrent : %08x\nAssigned: %08x\n", p, *p, val);
            if (val == *p){
                cprintf(C_GREEN, "Success!\n\n");
            } else {
                cprintf(C_RED, "Fail!\n\n");
            }
        } else {
            pp_printf("\nExiting without writing...(Pressed: %02d)\n", read_byte);
        }
        
    } else {
        pp_printf("Writing Value...\n");
        *p = val;
        pp_printf("Address : %08x\nCurrent : %08x\nAssigned: %08x\n", p, *p, val);
            if (val == *p){
                cprintf(C_GREEN, "Success!\n\n");
            } else {
                cprintf(C_RED, "Fail!\n\n");
            }
    }

	return 0;
}

DEFINE_WRC_COMMAND(write) = {
	.name = "write",
	.exec = cmd_write,
};
