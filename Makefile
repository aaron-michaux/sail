
# These will be set from the outside
TARGET?=sail
#SOURCES?=$(shell find src -type f -name '*.cpp' -o -name '*.cppm')
SOURCES:=main.cpp
TOOLCHAIN_NAME?=gcc-11
TOOLCHAIN_CONFIG?=asan
STATIC_LIBCPP?=0
VERBOSE?=0
LTO?=0

# -------------------------------------------------------- Check that we're in the correct directory
# Every shell command is executed in the same invocation
MKFILE_PATH:=$(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR:=$(patsubst %/,%,$(dir $(MKFILE_PATH)))
ifneq ("$(MKFILE_DIR)", "$(CURDIR)")
$(error Should run from $(MKFILE_DIR) not $(CURDIR))
endif

# -------------------------------------------------- Include makefile environment and standard rules

include project-config/env.inc.makefile

# -------------------------------------------------------------------------------------------- Rules
# Standard Rules
.PHONY: clean info deps

#include /tmp/build-amichaux/gcc-11.2.0-asan/sail/src/main.o.d
#include test1.o.d

all: $(TARGETDIR)/$(TARGET)

# Symlink the gcm.cache directory, so that we can
# maintain different caches for different build configs
gcmdir:
	@mkdir -p $(GCMDIR)
	@rm -f gcm.cache
	@ln -s $(GCMDIR) gcm.cache

# For building libstdc++ headers
gcm.cache$(STDHDR_DIR)/%.gcm: $(STDHDR_DIR)/% | gcmdir
	@echo -e '$(BANNER)c++-system-header iostream$(BANEND)'
	$(CXX) -x c++-system-header $(CXXFLAGS_F) iostream
	@printf '%s' '$(RECIPETAIL)'

$(BUILDDIR)/%.o.d: %.cpp
	@echo "$(BANNER)deps $<$(BANEND)"
	mkdir -p $(dir $@)
	$(CXX) -x c++ $(CXXFLAGS_F) -Mno-modules -MMD -MF $@ $< 1>/dev/null
	@printf '%s' '$(RECIPETAIL)'

$(BUILDDIR)/%.o: %.cpp
	@echo "$(BANNER)c++ $<$(BANEND)"
	mkdir -p $(dir $@)
	$(CXX) -x c++ $(CXXFLAGS_F) -Mno-modules -MMD -MF $@.d -c $< -o $@
	@printf '%s' '$(RECIPETAIL)'

$(TARGETDIR)/$(TARGET): $(OBJECTS)
	@echo "$(BANNER)link $(TARGET)$(BANEND)"
	mkdir -p $(dir $@)
	$(CC) -o $@ $^ $(LDFLAGS_F)
	@printf '%s' '$(RECIPETAIL)'

$(BUILDDIR)/deps.makefile.inc: $(DEPFILES)
	cat $(DEPFILES) > $@

deps: | $(BUILDDIR)/deps.makefile.inc
	@:

clean:
	@echo rm -rf $(BUILDDIR) $(TARGETDIR)
	@rm -rf $(BUILDDIR) $(TARGETDIR)

info:
	@echo "CURDIR:      $(CURDIR)"
	@echo "MKFILE_DIR:  $(MKFILE_DIR)"
	@echo "TARGET:      $(TARGET)"
	@echo "TARGETDIR:   $(TARGETDIR)"
	@echo "CONFIG:      $(TOOLCHAIN_CONFIG)"
	@echo "VERBOSE:     $(VERBOSE)"
	@echo "CC:          $(CC)"
	@echo "CFLAGS:      $(CFLAGS_F)"
	@echo "CXXFLAGS:    $(CXXFLAGS_F)"
	@echo "LDFLAGS:     $(LDFLAGS_F)"
	@echo "SOURCES:"
	@echo "$(SOURCES)" | sed 's,^,   ,'
	@echo "OBJECTS:"
	@echo "$(OBJECTS)" | sed 's,^,   ,'
	@echo "DEPFILES:"
	@echo "$(DEPFILES)" | sed 's,^,   ,'


