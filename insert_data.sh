#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


# Vaciar las tablas antes de insertar nuevos datos
echo $($PSQL "TRUNCATE teams, games")

# Leer archivo games.csv
cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Omitir la primera fila (encabezado)
  if [[ $winner != "winner" ]]
  then
    # Insertar equipos en la tabla teams
    for team in "$winner" "$opponent"
    do
      # Verificar si el equipo ya existe
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$team'")
      # Si no existe, insertar el equipo
      if [[ -z $TEAM_ID ]]
      then
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$team')")
        if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
        then
          echo "Se insertó el equipo: $team"
        fi
      fi
    done

    # Obtener los IDs de los equipos
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

    # Insertar el juego en la tabla games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Se insertó el juego: $winner vs $opponent"
    fi
  fi
done
