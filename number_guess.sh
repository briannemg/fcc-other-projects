#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Add username input and database check
echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
else
  IFS='|' read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

# Add guess loop with input validation
echo "Guess the secret number between 1 and 1000:"
while true
do
  read GUESS
  ((GUESS_COUNT++))

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  if (( $GUESS < $SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  elif (( $GUESS > $SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done 

# Update database after game completion
if [[ -z $USER_DATA ]]
then
  UPDATE_USER_FIRST_GAME_RETURN=$($PSQL "UPDATE users SET games_played=1, best_game=$GUESS_COUNT WHERE username='$USERNAME';")
else
  ((GAMES_PLAYED++))
  if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]
  then
    UPDATE_USER_BEST_GAME_RETURN=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$GUESS_COUNT WHERE username='$USERNAME';")
  else
    UPDATE_USER_GAME_RETURN=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
  fi
fi