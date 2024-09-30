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

# generate a random number between 1 and 1000
  min=1
  max=1000 
  SECRET=$(($RANDOM%($max-$min+1)+$min))
  
  echo "The secret number is: $SECRET"

# prompt the user for a guess
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  ROUND=1

# while the guess isn't correct
  while [ '$SECRET' -ne '$GUESS' ]
  do
  
    # guess was an integer
#    if [[ $GUESS =~ ^[1-1000]$ ]]
    if [[ $GUESS =~ ^[0-9]+$ ]]
    then

      if [[ $SECRET -gt $GUESS ]]
      then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
    
    # guess wasn't an integer
    else
      echo "That is not an integer, guess again:"

    fi

    read GUESS
    ROUND=$ROUND+1

  done

  # user made the correct guess
  echo "You guessed it in $ROUND tries. The secret number was $SECRET. Nice job!"

  # update the user's record
  IFS="|"

  RECORDS=$($PSQL "SELECT games_played, best_game FROM records WHERE user_id=$USER_ID;")
  echo "$RECORDS" | while read GAMES_PLAYED BEST_GAME
  do
    UPDATE_RECORD_RESULT=$($PSQL "UPDATE records SET games_played=$GAMES_PLAYED+1 WHERE user_id=$USER_ID;")
 
    if [[ $ROUND -lt $BEST_GAME]]
    then
      UPDATE_RECORD_RESULT=$($PSQL "UPDATE records SET best_game=$ROUND WHERE user_id=$USER_ID;")
    fi

  done
  
}

MAIN