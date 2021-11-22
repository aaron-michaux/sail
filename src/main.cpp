
// #include <iostream>

import Test1;

// ------------------------------------------------------------------------ main

int main(int argc, const char* const* argv)
{
   std::cout << greeting() << " world!\n";
   return 0;
}

// nice ionice -c3 /opt/cc/gcc-11.2.0/bin/gcc -x c++-system-header -std=c++2b -fno-rtti
// -fmodules-ts -nostdinc++ -isystem/opt/cc/gcc-11.2.0/include/c++/11.2.0
// -isystem/opt/cc/gcc-11.2.0/include/c++/11.2.0/x86_64-pc-linux-gnu
// -isystem/opt/cc/gcc-11.2.0/include iostream
