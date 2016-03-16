# For Linux
LD_FLAGS = -Wall

all: client

fonctionsSocket.o: fonctionsTCP.c fonctionsTCP.h
	gcc -c -o fonctionsTCP.o fonctionsTCP.c

serveur: serveur.c fonctionsTCP.o
	gcc serveur.c -o serveur fonctionsTCP.o  $(LD_FLAGS)

client: client.c fonctionsTCP.o
	gcc client.c -o client fonctionsTCP.o  $(LD_FLAGS)

clean:
	rm *~ ; rm -i \#* ; rm *.o; \
        rm serveur ; rm client
