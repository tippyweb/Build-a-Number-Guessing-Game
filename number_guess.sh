#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"



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

# if username already exists
  else

  # get the user's records
    RECORDS=$($PSQL "SELECT games_played, best_game FROM records WHERE user_id=$USER_ID;")

  # display welcome message to the user
    echo "$RECORDS" | while read GAMES_PLAYED BAR BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done

  fi



}

MAIN