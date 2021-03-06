#include <ctll/fixed_string.hpp>

void empty_symbol() { }

static constexpr auto Pattern = ctll::fixed_string{ LR"(^\s*(\d+)\s+:(\S):$(\S+?)$(\S+?)$(\S+))" };

static_assert(Pattern.size() == 38);

// ordinary string is taken as array of bytes
#ifdef CTRE_STRING_IS_UTF8
static_assert(ctll::fixed_string("ฤลกฤ").size() == 3);
static_assert(ctll::fixed_string("๐").size() == 1);
static_assert(ctll::fixed_string("๐")[0] == L'๐');
#else
static_assert(ctll::fixed_string("ฤลกฤ").size() == 6); // it's just a bunch of bytes
static_assert(ctll::fixed_string("๐").size() == 4); // it's just a bunch of bytes
#endif

#if __cpp_char8_t
// u8"" is utf-8 encoded
static_assert(ctll::fixed_string(u8"ฤลกฤ").size() == 3);
static_assert(ctll::fixed_string(u8"๐").size() == 1);
static_assert(ctll::fixed_string(u8"๐")[0] == L'๐');
#endif

// u"" is utf-16
static_assert(ctll::fixed_string(u"ฤลกฤ").size() == 3);
static_assert(ctll::fixed_string(u"๐").size() == 1);

// U"" is utf-32
static_assert(ctll::fixed_string(U"ฤลกฤ").size() == 3);
static_assert(ctll::fixed_string(U"๐").size() == 1);

// everything is converted into utf-32

