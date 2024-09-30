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

    echo "User exists"

  fi

}

MAIN