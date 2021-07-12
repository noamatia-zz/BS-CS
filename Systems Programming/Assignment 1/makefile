all: splflix


splflix:bin/Main.o bin/Session.o bin/Watchable.o bin/User.o bin/Action.o
	g++ -o  bin/splflix bin/Main.o  bin/Session.o   bin/Watchable.o bin/User.o bin/Action.o


bin/Main.o:src/Main.cpp
	g++ -g -Wall -Weffc++ -std=c++11 -c -Iinclude -o bin/Main.o src/Main.cpp
	

bin/User.o:src/User.cpp
	g++ -g -Wall -Weffc++ -std=c++11 -c -Iinclude -o bin/User.o src/User.cpp


bin/Session.o:src/Session.cpp
	g++ -g -Wall -Weffc++ -std=c++11 -c -Iinclude -o bin/Session.o src/Session.cpp


bin/Watchable.o:src/Watchable.cpp
	g++ -g -Wall -Weffc++ -std=c++11 -c -Iinclude -o bin/Watchable.o src/Watchable.cpp


bin/Action.o:src/Action.cpp
	g++ -g -Wall -Weffc++ -std=c++11 -c -Iinclude -o bin/Action.o src/Action.cpp

clean:
	rm -f bin/*
