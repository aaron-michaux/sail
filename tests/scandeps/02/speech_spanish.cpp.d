speech_spanish.o gcm.cache/speech-spanish.gcm: speech_spanish.cpp
speech:spanish.c++m: gcm.cache/speech-spanish.gcm
.PHONY: speech:spanish.c++m
gcm.cache/speech-spanish.gcm:| speech_spanish.o
