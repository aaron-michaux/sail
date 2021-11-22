
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

 * Write a makefile with CFLAGS/etc support
 * My run.sh sets the env and runs make
 
 
    std.regex provides the content of header <regex>
    std.filesystem provides the content of header <filesystem>
    std.memory provides the content of header <memory>
    std.threading provides the contents of headers <atomic>, <condition_variable>, <future>, <mutex>, <shared_mutex>, and <thread>
    std.core provides everything else in the C++ Standard Library

 * Modules and unity builds (??)

# make dep rule
 * Depends on a "scandep" program that:
   + indicates module dependencies (including system headers)
   + shows which files are required to generate a module
 * Make later imports the files as raw dependency rules
 * Bonus if it does headers at the same time (pass, resolve, include path)

