#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1;")

# sort unique names 
unique_names=$(cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do
    if [[ $WINNER != "winner" ]]
    then
      echo "$WINNER"
      echo "$OPPONENT"
    fi
  done | sort | uniq)

# insert unique names
while IFS= read -r name;
  do
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$name') ON CONFLICT DO NOTHING")
  done <<< "$unique_names"


cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # ignore line 1 of csv
  if [[ $YEAR != "year" ]]
    then

    # get winner_id and opponent_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if not found set winner_id and opponent_id to null
    [[ -z $WINNER_ID ]] && WINNER_ID=NULL
    [[ -z $OPPONENT_ID ]] && OPPONENT_ID=NULL
 
    # insert game info
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

  fi
done