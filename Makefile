
# These will be set from the outside
TARGET?=sail
SOURCES?=$(shell find src2 -type f -name '*.cpp' -o -name '*.cppm')
#SOURCES:=main.cpp
TOOLCHAIN_NAME?=gcc-11
TOOLCHAIN_CONFIG?=asan
STATIC_LIBCPP?=0
VERBOSE?=0
LTO?=0

# Configure includes

CXX_CONTRIB_INC:=-isystemcontrib/include
CXXFLAGS:=$(CXXFLAGS) $(CXX_CONTRIB_INC)

# -------------------------------------------------------- Check that we're in the correct directory
# Every shell command is executed in the same invocation
MKFILE_PATH:=$(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR:=$(patsubst %/,%,$(dir $(MKFILE_PATH)))
ifneq ("$(MKFILE_DIR)", "$(CURDIR)")
$(error Should run from $(MKFILE_DIR) not $(CURDIR))
endif

# -------------------------------------------------- Include makefile environment and standard rules

include project-config/env.inc.makefile

# gcm.cache/speech.gcm: $(BUILDDIR)/src2/speech.o
# gcm.cache/speech-english.gcm: $(BUILDDIR)/src2/speech_english.o 
# gcm.cache/speech-spanish.gcm: $(BUILDDIR)/src2/speech_spanish.o	
# $(BUILDDIR)/src2/speech.o: gcm.cache/speech-english.gcm gcm.cache/speech-spanish.gcm
# $(BUILDDIR)/src2/main.o: src2/main.cpp gcm.cache/speech.gcm gcm.cache$(STDHDR_DIR)/iostream.gcm gcm.cache$(STDHDR_DIR)/cstdlib.gcm

# gcm.cache/speech.gcm: $(BUILDDIR)/src2/speech.o
# $(BUILDDIR)/src2/speech.o: gcm.cache/speech-english.gcm gcm.cache/speech-spanish.gcm

# gcm.cache/speech-english.gcm: $(BUILDDIR)/src2/speech_english.o
# $(BUILDDIR)/src2/speech_english.o:

# $(BUILDDIR)/src2/main.o: gcm.cache/speech.gcm gcm.cache$(STDHDR_DIR)/iostream.gcm gcm.cache$(STDHDR_DIR)/cstdlib.gcm

# gcm.cache/speech-spanish.gcm: $(BUILDDIR)/src2/speech_spanish.o
# $(BUILDDIR)/src2/speech_spanish.o:

include $(MODDEP_FILES)
# include $(DEP_FILES)

# -------------------------------------------------------------------------------------------- Rules
# Standard Rules
.PHONY: clean info deps test-scan module-deps

#include /tmp/build-amichaux/gcc-11.2.0-asan/sail/src/main.o.d
#include test1.o.d

all: $(TARGETDIR)/$(TARGET)

bin/scandeps: project-config/scandeps.cpp
	@echo "$(BANNER)make scandeps$(BANEND)"
	@echo $(CXX) -x c++ -std=c++20 -Wall -Wextra -pedantic $(CXX_CONTRIB_INC) $< -lm -lstdc++ -o $@
	$(CXX) -x c++ -std=c++20 -Wall -Wextra -pedantic $(CXX_CONTRIB_INC) $< -lm -lstdc++ -o $@
	@$(RECIPETAIL)

test-scan: bin/scandeps
	@echo "$(BANNER)test-scan$(BANEND)"
	$< tests/scandeps/01/main.cpp
	$< tests/scandeps/01/speech.cpp
	$< tests/scandeps/01/speech_english.cpp
	$< tests/scandeps/01/speech_spanish.cpp
	@$(RECIPETAIL)

module-deps: $(MODDEP_FILES)

# Symlink the gcm.cache directory, so that we can
# maintain different caches for different build configs
gcmdir:
	@mkdir -p $(GCMDIR)
	@rm -f gcm.cache
	@ln -s $(GCMDIR) gcm.cache

# For building libstdc++ headers
gcm.cache$(STDHDR_DIR)/%.gcm: $(STDHDR_DIR)/% | gcmdir
	@echo '$(BANNER)c++-system-header $<$(BANEND)'
	$(CXX) -x c++-system-header $(CXXFLAGS_F) $(notdir $<)
	@$(RECIPETAIL)

# $(BUILDDIR)/%.o.d: %.cpp
# 	@echo "$(BANNER)deps $<$(BANEND)"
# 	mkdir -p $(dir $@)
# 	$(CXX) -x c++ $(CXXFLAGS_F) -Mno-modules -MMD -MF $@ $< 1>/dev/null
# 	@$(RECIPETAIL)

$(BUILDDIR)/%.o.m: %.cpp | bin/scandeps
	@echo "$(BANNER)scandeps $<$(BANEND)"
	mkdir -p $(dir $@)
	bin/scandeps $< > $@
	@$(RECIPETAIL)


$(BUILDDIR)/%.o $(BUILDDIR)/%.o.d: %.cpp | bin/scandeps gcmdir
	@echo "$(BANNER)c++ $<$(BANEND)"
	mkdir -p $(dir $@)
	bin/scandeps $< > $@.d2
	$(CXX) -x c++ $(CXXFLAGS_F) -Mno-modules -MMD -MF $@.d -c $< -o $@
	@$(RECIPETAIL)

$(TARGETDIR)/$(TARGET): $(OBJECTS)
	@echo "$(BANNER)link $(TARGET)$(BANEND)"
	mkdir -p $(dir $@)
	$(CC) -o $@ $^ $(LDFLAGS_F)
	@$(RECIPETAIL)

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
	@echo "DEP_FILES:"
	@echo "$(DEP_FILES)" | sed 's,^,   ,'


