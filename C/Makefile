# Répertoires
BINDIR= ./bin
INCLUDEDIR = ./include
OBJDIR = ./obj
SRCDIR = ./src
CLIENTDIR = ./client
SERVEURDIR = ./serveur

#
CC=gcc
IFLAGS=-I$(INCLUDEDIR)
CFLAGS=-Wall

all: $(BINDIR)/client $(BINDIR)/serveur

$(OBJDIR)/fonctionsSocket.o : $(SRCDIR)/fonctionsTCP.c $(INCLUDEDIR)/fonctionsTCP.h $(OBJDIR)
	$(CC) $(IFLAGS) $(CFLAGS) -c $(SRCDIR)/fonctionsTCP.c -o $(OBJDIR)/fonctionsSocket.o

$(BINDIR)/client: $(OBJDIR)/fonctionsSocket.o $(BINDIR)
	$(CC) $(IFLAGS) $(SRCDIR)/$(CLIENTDIR)/main.c $(SRCDIR)/$(CLIENTDIR)/client.c $(OBJDIR)/fonctionsSocket.o -o $@

$(BINDIR)/serveur: $(OBJDIR)/fonctionsSocket.o $(BINDIR)
	$(CC) $(IFLAGS) $(SRCDIR)/$(SERVEURDIR)/main.c $(SRCDIR)/$(SERVEURDIR)/serveur.c $(OBJDIR)/fonctionsSocket.o -o $@

#########################################
# Règles de construction des répertoires
$(BINDIR):
	mkdir $(BINDIR)

$(OBJDIR):
	mkdir $(OBJDIR)

#########################################
# Règles de nettoyage
clean:
	rm -r $(OBJDIR); rm -r $(BINDIR);
