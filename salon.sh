#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Gongo's Salon ~~~~~\n\n"

echo -e "This is Gongo's Salon. What can I do for you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES="$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid bike number."
    else 
      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_ID ]]
        then
          # send to main menu
          MAIN_MENU "I could not find that service. What would you like today?"
        else

          SERVICE_NAME=$($PSQL "Select name FROM SERVICES WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/ //g') 
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE

          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/ //g')
          if [[ -z $CUSTOMER_NAME ]]
            then
              # get new customer name
              echo -e "\nI don't have a record for that phone number, what's your name?"
              read CUSTOMER_NAME
              INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
            fi

          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/ //g')

          echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?" 
          read SERVICE_TIME

          INSERT_APP_REUSLT==$($PSQL "INSERT INTO appointments(customer_id, service_id, time) 
                                      VALUES('$CUSTOMER_ID',$SERVICE_ID_SELECTED, '$SERVICE_TIME')")

          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"                             

        fi
    fi  


}


MAIN_MENU
