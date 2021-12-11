
CXX:=g++-11
CXXFLAGS:=-std=c++2b -Wall -Wextra -pedantic -Werror -fmodules-ts


.PHONY: clean

a.out: main.o speech.o speech_english.o speech_spanish.o
	$(CXX) $^ -o $@

speech_english.o: speech_english.cpp
	$(CXX) $(CXXFLAGS) -MMD -MF $@.d -c $< -o $@

speech_spanish.o: speech_spanish.cpp
	$(CXX) $(CXXFLAGS) -MMD -MF $@.d -c $< -o $@

speech.o: speech.cpp speech_spanish.o speech_english.o
	$(CXX) $(CXXFLAGS) -MMD -MF $@.d -c $< -o $@

gcm.cache/usr/local/Cellar/gcc/11.2.0_2/include/c++/11/iostream.gcm:
	$(CXX) -x c++-system-header $(CXXFLAGS) iostream

gcm.cache/usr/local/Cellar/gcc/11.2.0_2/include/c++/11/cstdlib.gcm:
	$(CXX) -x c++-system-header $(CXXFLAGS) cstdlib

main.o: main.cpp speech.o gcm.cache/usr/local/Cellar/gcc/11.2.0_2/include/c++/11/iostream.gcm gcm.cache/usr/local/Cellar/gcc/11.2.0_2/include/c++/11/cstdlib.gcm
	$(CXX) $(CXXFLAGS) -MMD -MF $@.d -c $< -o $@


clean:
	rm -rf gcm.cache *.o *.o.d a.out




