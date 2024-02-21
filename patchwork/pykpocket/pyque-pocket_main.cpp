#include "pygbag.h"
#include <stdio.h>
extern "C" void pykpy_begin ();
extern "C" em_callback_func *main_iteration (void);
extern "C" void pykpy_end ();
extern bool em_running;

int
main ()
{
    puts("pykpy_begin");
    pykpy_begin();
    emscripten_set_main_loop ((em_callback_func)main_iteration, 0, 1);
    pykpy_end();
    puts("pykpy_end");
    return 0;
}
