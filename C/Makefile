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

$(OBJDIR)/*.o : $(SRCDIR)/fonctionsTCP.c $(INCLUDEDIR)/fonctionsTCP.h $(OBJDIR)
	$(CC) $(IFLAGS) $(CFLAGS) -c $(SRCDIR)/fonctionsTCP.c -o $(OBJDIR)/fonctionsSocket.o

$(BINDIR)/client: $(OBJDIR)/*.o $(BINDIR)
	$(CC) $(IFLAGS) $(SRCDIR)/$(CLIENTDIR)/*.c $(OBJDIR)/*.o -o $@

$(BINDIR)/serveur: $(OBJDIR)/*.o $(BINDIR)
	$(CC) $(IFLAGS) $(SRCDIR)/$(SERVEURDIR)/*.c $(OBJDIR)/*.o -o $@

#########################################
# Règles de construction des répertoires
$(BINDIR):
	mkdir $(BINDIR)

$(OBJDIR):
	mkdir $(OBJDIR)

#########################################
# Règles de nettoyage
clean:
	rm $(OBJDIR)/fonctionsSocket.o; rm -r $(BINDIR);
