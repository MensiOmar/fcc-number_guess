#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"
MAIN () {
  if [[ ! -z $1 ]]
  then
    echo $1 
  else
    echo "Enter your username:"
    read USER_NAME
  fi
}

MAIN
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USER_NAME')")
else
  NUMBER_OF_GAMES=$($PSQL "SELECT count(*) FROM users AS u FULL JOIN games AS g ON u.user_id=g.user_id WHERE u.username='$USER_NAME'")
  HIGH_SCORE=$($PSQL "SELECT MIN(number_of_guesses) FROM users AS u FULL JOIN games AS g ON u.user_id=g.user_id WHERE u.username='$USER_NAME'")
  echo "Welcome back, $USER_NAME! You have played $NUMBER_OF_GAMES games, and your best game took $HIGH_SCORE guesses."
fi
SECRET_NUMBER=$(( ( RANDOM % 1000 ) + 1 ))
echo "Guess the secret number between 1 and 1000:"
SUCC=0
NUMBER_OF_GUESSES=0
while [[ $SUCC -ne 1 ]]
do
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  read NEW_GUESS
  if [[ ! $NEW_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    SUCC=0
  else
    if [[ $NEW_GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      SUCC=0
    elif [[ $NEW_GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      SUCC=0
    else
      SUCC=1
    fi
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(user_id,number_of_guesses) VALUES ($USER_ID,$NUMBER_OF_GUESSES)")
