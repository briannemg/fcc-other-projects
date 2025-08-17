#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

ELEMENT=$1

# Decide how to search
if [[ $ELEMENT =~ ^[0-9]+$ ]]
then
  QUERY="e.atomic_number=$ELEMENT"
elif [[ $ELEMENT =~ ^[A-Z][a-z]?$ ]]
then
  QUERY="e.symbol='$ELEMENT'"
else
  QUERY="e.name='$ELEMENT'"
fi

RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
FROM elements e 
JOIN properties p ON e.atomic_number=p.atomic_number 
JOIN types t on p.type_id=t.type_id 
WHERE $QUERY;")

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$RESULT"
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi