#! /bin/bash
PSQL="psql -U freecodecamp -d periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    SEARCH_COLUMN="atomic_number"
  elif [[ $1 =~ ^[A-Z].* && ${#1} -le 2 ]]
  then
    SEARCH_COLUMN="symbol"
  elif [[ $1 =~ ^[A-Z].* && ${#1} -gt 2 ]]
  then
    SEARCH_COLUMN="name"
  else
    SEARCH_COLUMN=""
  fi

  if [[ -z $SEARCH_COLUMN ]]
  then
    echo "I could not find that element in the database."
  else
    if [[ $SEARCH_COLUMN == "atomic_number" ]]
    then
      ATOMIC_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE $SEARCH_COLUMN = $1")
    else
      ATOMIC_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE $SEARCH_COLUMN = '$1'")
    fi
    if [[ -z $ATOMIC_RESULT ]]
    then
      echo "I could not find that element in the database."
    else
      echo $ATOMIC_RESULT | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS M_POINT B_POINT
      do
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $M_POINT celsius and a boiling point of $B_POINT celsius."
      done
    fi
  fi
fi