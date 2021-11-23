
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

#include <cstdlib>
#include <string>
#include <string_view>
#include <iostream>
#include <filesystem>
#include <fstream>
#include <stdexcept>
#include <vector>

#define FMT_HEADER_ONLY
#include <fmt/format.h>
#include <ctre/ctre.hpp>

// -------------------------------------------------------------------------- Declarations

using std::string;
using std::string_view;
using std::cout;
using std::cerr;
using std::endl;
using std::runtime_error;
using std::vector;
using fmt::format;

struct Config
{
   string_view filename;

   bool show_help = false;
   bool has_error = false;
};

void process_file(string_view filename);
void show_help(const char * argv0);
Config parse_command_line(int, const char* const*);

// -------------------------------------------------------------------------- process_file

void process_file(string_view filename)
{
   // State processing variables
   bool in_global_module_fragment = false;
   bool in_module_purview = false;
   bool is_module_interface_unit = false;
   bool is_module_implementation_unit = false;
   bool is_module_interface_partition = false;
   bool is_module_implementation_partition = false;
   bool found_processing_end = false;

   string module_name = "";
   vector<string> deps;

   auto emit_depends_on_module = [&] (string dependency) {
      deps.push_back(std::move(dependency));
   };
   
   // Process a single line
   auto process_line = [&] (string_view line, const int lineno) {
      //cout << lineno << ": " << line << endl;

      // Do we have an empty line?
      if(ctre::match<"^\\s*$">(line)) {
         // continue
      }
      
      // Do we have a preprocessor directive?
      else if(ctre::match<"^\\s*#.*$">(line)) {
         // Discard preprocessor directives. Yes this is a bug.
      }

      // Is this the start of the global module fragment?
      else if(ctre::match<"^\\s*module\\s*;\\s*$">(line)) { 
         if(in_global_module_fragment || in_module_purview) 
            throw runtime_error(format("global module fragment at line #{} has invalide locations!", lineno));
         in_global_module_fragment = true;
      }
            
      // Do we have a module declaration?
      else if(const auto match = ctre::match<"^\\s*export\\s+module\\s+([a-zA-Z0-9_\\.:]+)\\s*;\\s*$">(line); match) {
         in_global_module_fragment = false;
         in_module_purview = true;
         module_name = match.get<1>().to_string();
      }
      
      // Do we have a module implementation (without export)? 
      else if(const auto match = ctre::match<"^\\s*module\\s+([a-zA-Z0-9_\\.:]+)\\s*;\\s*$">(line); match) {
         if(match.get<1>().to_view() == ":private") {
            // The beginning of the private module fragment... end processing
            found_processing_end = true;
            return;
         }
         
         in_global_module_fragment = false;
         in_module_purview = true;         
         module_name = match.get<1>().to_string();         
         emit_depends_on_module(module_name); // Implicitly depends on its module interface
      }

      // Are we importing a module?
      else if(const auto match = ctre::match<"^\\s*(export\\s+)?import\\s+([a-zA-Z0-9_\\.:\"<>]+)\\s*;\\s*$">(line); match) {
         const bool is_export_import = match.get<1>().to_view().size() > 0; // Affects dependencies
         const bool is_header_fragment = match.get<2>().to_view().at(0) == '<'
            || match.get<2>().to_view().at(0) == '"';
         const bool is_partition = match.get<2>().to_view().at(0) == ':';
         if(is_partition && !in_module_purview) {
            throw runtime_error(format("attempt to import a module partition '{}' before the module declaration", match.get<2>().to_view()));
         }

         const auto dependency = (is_partition)
            ? format("{}{}", module_name, match.get<2>().to_view())
            : match.get<2>().to_string();
         emit_depends_on_module(dependency); // Depends on this module
         return;
      }

      else {
         found_processing_end = true; // Don't bother looking further into the file
      }
   };
   
   // Read the file line-by-line
   std::ifstream infile(filename.data());
   std::string line;
   int lineno = 0;
   while (std::getline(infile, line) && !found_processing_end) {
      process_line(line, ++lineno);
   }

   // Output the dependencies
   if(deps.size() > 0) {
      cout << format("{}:", filename);
      for(const auto& dependency: deps) {
         cout << format(" {}", dependency);
      }
      cout << endl;
   }

}

// ----------------------------------------------------------------------------- show_help

void show_help(const char *)
{
   cout << R"V0G0N(

   Usage: scandeps <filename>

)V0G0N";
}

// -------------------------------------------------------------------- parse_command_line

Config parse_command_line(int argc, const char* const* argv)
{
   Config conf;
   
   for(int i = 1; i < argc; ++i) {
      auto arg = string_view(argv[i]);
      if(arg == "-h" || arg == "--help") {
         conf.show_help = true;
         return conf; // Early return... no need to look at other switches
      }
   }

   for(int i = 1; i < argc; ++i) {
      auto arg = string_view(argv[i]);
      if(conf.filename.size() == 0) {
         conf.filename = arg;
      } else {
         cerr << "ERROR: attempt to set input file to '" << arg << "'"
              << " but it was already set to '" << conf.filename << "'"
              << endl;
         conf.has_error = true;
      }
   }

   if(conf.filename.size() == 0) {
      cerr << "ERROR: must specify a filename to process!" << endl;
      conf.has_error = true;
   } else if(!std::filesystem::exists(conf.filename)) {
      cerr << "ERROR: file not found '" << conf.filename << "'" << endl;
      conf.has_error = true;
   }
   
   return conf;
}

// ---------------------------------------------------------------------------------- main

int main(int argc, const char* const* argv)
{
   const auto conf = parse_command_line(argc, argv);
   if(conf.has_error) {
      cerr << "Aborting due to previous errors..." << endl;
      return EXIT_FAILURE;
   }
   if(conf.show_help) {
      show_help(argv[0]);
      return EXIT_SUCCESS;
   }

   try {
      process_file(conf.filename);
   } catch(std::exception& e) {
      cerr << "Exception processing file '" << conf.filename << "': " << e.what() << endl;
      return EXIT_FAILURE;
   }
   
   return EXIT_SUCCESS;
}
