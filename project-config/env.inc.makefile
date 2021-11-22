
include project-config/toolchains/$(TOOLCHAIN_NAME).inc.makefile

# -------------------------------------------------------------------------------------------- Logic

# This is the "toolchain" file to be included
TARGETDIR?=build/$(TOOLCHAIN_NAME)-$(TOOLCHAIN_CONFIG)
BUILDDIR?=/tmp/build-$(USER)/$(TOOLCHAIN_NAME)-$(TOOLCHAIN_CONFIG)/$(TARGET)
GCMDIR:=$(BUILDDIR)/gcm.cache
OBJECTS:=$(addprefix $(BUILDDIR)/, $(patsubst %.cpp, %.o, $(SOURCES)))
DEPFILES:=$(addsuffix .d, $(OBJECTS))

# Static libcpp
ifeq ($(STATIC_LIBCPP), 1)
LINK_LIBCPP:=$(LINK_LIBCPP_A)
else
LINK_LIBCPP:=$(LINK_LIBCPP_SO)
endif

# Add asan|usan|tsan|debug|release
ifeq ($(TOOLCHAIN_CONFIG), asan)
CFLAGS_1:=-O0 $(C_W_FLAGS) $(F_FLAGS) $(D_FLAGS) $(ASAN_FLAGS)
CXXFLAGS_1:=-O0 $(W_FLAGS) $(F_FLAGS) $(D_FLAGS) $(ASAN_FLAGS)
LDFLAGS_1:=$(LINK_LIBCPP) $(L_FLAGS) $(ASAN_LINK)
else ifeq ($(TOOLCHAIN_CONFIG), usan)
CFLAGS_1:=-O0 $(C_W_FLAGS) $(F_FLAGS) $(S_FLAGS) $(USAN_FLAGS)
CXXFLAGS_1:=-O0 $(W_FLAGS) $(F_FLAGS) $(S_FLAGS) $(USAN_FLAGS)
LDFLAGS_1:=$(LINK_LIBCPP) $(L_FLAGS) $(USAN_LINK)
else ifeq ($(TOOLCHAIN_CONFIG), tsan)
CFLAGS_1:=-O1 $(C_W_FLAGS) $(F_FLAGS) $(S_FLAGS) $(TSAN_FLAGS)
CXXFLAGS_1:=-O1 $(W_FLAGS) $(F_FLAGS) $(S_FLAGS) $(TSAN_FLAGS)
LDFLAGS_1:=$(LINK_LIBCPP) $(L_FLAGS) $(TSAN_LINK)
else ifeq ($(TOOLCHAIN_CONFIG), debug)
CFLAGS_1:=-O0 $(C_W_FLAGS) $(F_FLAGS) $(D_FLAGS) $(GDB_FLAGS)
CXXFLAGS_1:=-O0 $(W_FLAGS) $(F_FLAGS) $(D_FLAGS) $(GDB_FLAGS)
LDFLAGS_1:=$(LINK_LIBCPP) $(L_FLAGS)
else ifeq ($(TOOLCHAIN_CONFIG), release)
CFLAGS_1:=-O3 $(C_W_FLAGS) $(F_FLAGS) $(R_FLAGS)
CXXFLAGS_1:=-O3 $(W_FLAGS) $(F_FLAGS) $(R_FLAGS)
LDFLAGS_1:=$(LINK_LIBCPP) $(L_FLAGS)
else
$(error Unknown configuration: $(TOOLCHAIN_CONFIG))
endif

# Add LTO
ifeq ($(LTO), 1)
CFLAGS_2:=$(CFLAGS_1) $(LTO_FLAGS)
CXXFLAGS_2:=$(CXXFLAGS_1) $(LTO_FLAGS)
LDFLAGS_2:=$(LDFLAGS_1) $(LTO_LINK)
else
CFLAGS_2:=$(CFLAGS_1)
CXXFLAGS_2:=$(CXXFLAGS_1)
LDFLAGS_2:=$(LDFLAGS_1)
endif

# Final flags
CFLAGS_F:=$(CFLAGS_2) $(CFLAGS) $(CPPFLAGS)
CXXFLAGS_F:=-std=c++20 $(CXXFLAGS_2) $(CPP_INC) $(CXXFLAGS) $(CPPFLAGS)
LDFLAGS_F:=$(LDFLAGS_2)

# Visual feedback rules
ifeq ($(VERBOSE), 1)
ISVERBOSE:=verbose
BANNER:=$(shell printf "\# \e[1;37m-- ~ \e[1;37m\e[4m")
BANEND:=$(shell printf "\e[0m\e[1;37m ~ --\e[0m")
RECIPETAIL:=\n
else
ISVERBOSE:=
BANNER:=$(shell printf " \e[36m\e[1m⚡\e[0m ")
BANEND:=
RECIPETAIL:=
endif

# This must appear before SILENT
default: all

# Will be silent unless VERBOSE is set to 1
$(ISVERBOSE).SILENT:



