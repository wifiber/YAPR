

#include <uart.h>
#include <shell.h>
#include <wrc.h>


int main(void)
{
        
        uart_init_hw();
        shell_init();
        
    while(1){
        shell_interactive();

    }
        
}




/* needed ... */
void _irq_entry(void)
{}
