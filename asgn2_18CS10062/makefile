a.out:main.o libass2_18CS10062.a
	c++ main.o -L. ./libass2_18CS10062.a

main.o:main.cpp toylib.h
	c++ -Wall -c main.cpp

libass2_18CS10062.a:ass2_18CS10062.o
	ar -rcs libass2_18CS10062.a ass2_18CS10062.o

ass2_18CS10062.o:ass2_18CS10062.cpp toylib.h
	c++ -Wall -c ass2_18CS10062.cpp
	
clean:
	rm a.out main.o libass2_18CS10062.a ass2_18CS10062.o