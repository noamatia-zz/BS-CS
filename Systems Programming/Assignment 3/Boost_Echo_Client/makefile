CFLAGS:=-c -Wall -Weffc++ -g -std=c++11 -Iinclude -pthread
LDFLAGS:=-lboost_system -pthread

all: StompBookClubClient

StompBookClubClient: bin/connectionHandler.o bin/echoClient.o bin/User.o
	g++ -o bin/StompBookClubClient bin/User.o bin/connectionHandler.o bin/echoClient.o $(LDFLAGS) 

bin/User.o: src/User.cpp include/User.h
	g++ $(CFLAGS) -o bin/User.o src/User.cpp
	
bin/connectionHandler.o: src/connectionHandler.cpp include/connectionHandler.h
	g++ $(CFLAGS) -o bin/connectionHandler.o src/connectionHandler.cpp

bin/echoClient.o: src/echoClient.cpp 
	g++ $(CFLAGS) -o bin/echoClient.o src/echoClient.cpp
	
	
.PHONY: clean
clean:
	rm -f bin/*
