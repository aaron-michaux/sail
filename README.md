
# Sail

A personal pedagogical project with the following goals:
 
 * Learn C++20/23 best practices
 * Modules
 * Concepts
 * Practical use of Ranges
 * Use of coroutines, in particular, for generators
 * Spaceship operators
 * Strong types (using CRTP)
 * Better constexpr/consteval/constinit
 * More thought into serialization I/O
 * Better use of async/promises/futures
 * No raw points. (use dumb smart pointers: notowned and owned)

## Build System

 * Modules and unity builds (??) Probably a bust
 * Depends on a "scandep" program that:
   + indicates module dependencies (including system headers)
   + shows which files are required to generate a module
 * Make later imports the files as raw dependency rules
 * Bonus if it does headers at the same time (pass, resolve, include path)

