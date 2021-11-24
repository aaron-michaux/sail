
#include <iostream>

module;

export module my.mod.foo;
//export module my.mod.foo:bar;
//module foobar;

export import <iostream>;
import foo:spanish;

export import other.module;
export import :zap;

#include foo
#define bar

import :spanish;

int main(int, char**)
{
   std::cout << "This is hello\n";
   return 0;
}
