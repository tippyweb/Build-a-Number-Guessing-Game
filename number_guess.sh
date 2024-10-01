#!/bin/bash
# global variables
# PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

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

  # retrieve the user's records
    RECORDS=$($PSQL "SELECT guesses FROM records WHERE user_id=$USER_ID;")

    GAMES_PLAYED=$( echo $RECORDS | wc -l )
    BEST_GAME=$( echo $RECORDS | sort -n | awk '{echo $1}' )

  # display welcome message to the user
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

  fi

# generate a random number between 1 and 1000
  min=1
  max=1000 
  SECRET=$(( $RANDOM%($max-$min+1)+$min ))
  
#echo "The secret number is: $SECRET"



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
  # insert the user's record
  INSERT_RECORD_RESULT=$($PSQL "INSERT INTO records(user_id, guesses) VALUES($USER_ID, $ROUND);")

  # display the message to the user
  echo "You guessed it in $ROUND tries. The secret number was $SECRET. Nice job!"
  
}

MAIN