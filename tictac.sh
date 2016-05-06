#!/bin/sh

cd C
make clean
make
cd ..
cd Java
javac -cp /applis/sicstus-4.3.2/lib/sicstus-4.3.2/bin/jasper.jar *.java
java -cp .:/applis/sicstus-4.3.2/lib/sicstus-4.3.2/bin/jasper.jar JulIA &
sleep 1
cd ..
cd C
cd bin
./client $1 $2 JulIA &
