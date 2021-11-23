
#include <cstdlib>

#include <string>
#include <iostream>

using std::string;

struct Config
{
   string filename;
   
};

/**
 * Read a single file in, and output "make" rules
 * 1. If produces a module
 * 2. The modules it depends on
 * Note, doing this right, doing headers, requires a macro preprocessor
 *
 * Syntax of note:
 * import core.speech; // Import a module
 * import <iostream>; // Import a system "header unit"

 * Module names: (note: export, and module cannot be used in a module name)
 * module-name:
 *    [module-name-qualifier] identifier ;
 * module-name-qualifier:
 *    identifier "." |
 *    module-name-qualifier identifier "." ;
 *
 * module-declaration:
 *    ["export"] "module" module-name [module-partition] [attribute-specifier-seq] ";" ;
 * module-partition:
 *    ":" module-name ;
 *
 * All imports appear before any delcarations
 */
int main(int argc, const char* const* argv)
{

   
   return EXIT_SUCCESS;
}
