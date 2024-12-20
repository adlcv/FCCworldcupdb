#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# clean tables first
$PSQL "TRUNCATE TABLE games, teams"

# insert all unique teams
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # winner team insert if not exist
  $PSQL "INSERT INTO teams(name) 
         VALUES('$WINNER') 
         ON CONFLICT (name) DO NOTHING"
  
  # opponent team insert if not exist
  $PSQL "INSERT INTO teams(name) 
         VALUES('$OPPONENT') 
         ON CONFLICT (name) DO NOTHING"
done

# games insert
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
         SELECT $YEAR, 
                '$ROUND', 
                (SELECT team_id FROM teams WHERE name='$WINNER'), 
                (SELECT team_id FROM teams WHERE name='$OPPONENT'), 
                $WINNER_GOALS, 
                $OPPONENT_GOALS"
done

# Do not change code above this line. Use the PSQL variable above to query your database.
