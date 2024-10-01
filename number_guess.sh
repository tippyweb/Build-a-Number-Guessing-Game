#!/bin/bash
# global variables
# PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

UPDATE_RECORDS() {

  USER_ID=$1
  ROUND=$2

# retrieve the user's record
  RECORDS=$($PSQL "SELECT games_played, best_game FROM records WHERE user_id=$USER_ID;")
  IFS="|"
  echo "$RECORDS" | while read GAMES_PLAYED BEST_GAME
  do


echo "Records: $RECORDS"
echo "GAMES_PLAYED: $GAMES_PLAYED, BEST_GAME: $BEST_GAME"


    # update the user's record
    GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))


echo "Incremented GAMES_PLAYED: $GAMES_PLAYED"
echo "Prior to UPDATE record, User_id: $USER_ID"


    UPDATE_RECORD_RESULT=$($PSQL "UPDATE records SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID;")
 
    if [[ $ROUND -lt $BEST_GAME ]]
    then
      UPDATE_RECORD_RESULT=$($PSQL "UPDATE records SET best_game=$ROUND WHERE user_id=$USER_ID;")
    fi

  done
}


MAIN() {

# get the username
  echo "Enter your username:"
  read USERNAME

# get the user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

# if username doesn't exist
  if [[ -z $USER_ID ]]
  then
    # welcome the new user
    echo "Welcome, $USERNAME! It looks like this is your first time here."

    # add the new user to the database
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")

    # get the user_id of this user
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

    # initialize the user's records
    INSERT_RECORD_RESULT=$($PSQL "INSERT INTO records(user_id, games_played, best_game) VALUES($USER_ID, 0, 1000000);")

# if username already exists
  else

  # retrieve the user's records
    RECORDS=$($PSQL "SELECT games_played, best_game FROM records WHERE user_id=$USER_ID;")

  # display welcome message to the user
    IFS="|"
    echo "$RECORDS" | while read GAMES_PLAYED BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done

  fi

# generate a random number between 1 and 1000
  min=1
  max=1000 
  SECRET=$(( $RANDOM%($max-$min+1)+$min ))
  
echo "The secret number is: $SECRET"



# prompt the user for a guess
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

# check if the guess is an integer
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done

  ROUND=1

# while the guess isn't correct
  while [ $SECRET -ne $GUESS ]
  do
  
    if [[ $SECRET -gt $GUESS ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi

    read GUESS

    # check if the guess is an integer
    while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read GUESS
    done

    ROUND=$(( $ROUND + 1 ))

  done

  # user made the correct guess
  echo "You guessed it in $ROUND tries. The secret number was $SECRET. Nice job!"

  # update the user's records
  UPDATE_RECORDS $USER_ID $ROUND
  
}

MAIN