#if TARGET_OS_IPHONE

extern "C" int percentage() {
    return 0;
}

#else

#include "vmaware.hpp"

extern "C" int percentage() {
    return (int)VM::percentage();
}

#endif
