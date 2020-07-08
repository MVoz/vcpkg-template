#include <cstdio>

extern "C" {

#include <openblas/openblas_config.h>
#include <openblas/cblas.h>
//#include "cblas.h"
//#include "../vcpkg/installed/x64-linux/include/openblas_common.h"
#include <cblas.h>
//#include "../vcpkg/installed/x64-linux/include/f2c.h"
//#include "../vcpkg/installed/x64-linux/include/clapack.h"
}

extern "C" int cheev_();

int main()
{

    //char * c = NULL;
    //integer * i = NULL;
    //complex * comp = NULL;
    //real * r = NULL;
    //auto test = cheev_(c,c, i, comp, i, r, comp, i, r, i);
     auto test = cheev_();
    puts("test");
}