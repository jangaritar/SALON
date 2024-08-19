#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo "~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;" | sed "s/'//g")

LIST_SERVICES(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
    echo "6) EXIT"
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED == 6 ]]
  then
  EXIT
  else 
   if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
   then 
    LIST_SERVICES "I could not find that service. What would you like today?"
   else 
    HAVE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
     if [[ -z $HAVE_SERVICE ]]
     then 
      LIST_SERVICES
     else 
      MAIN_MENU
     fi 
   fi 
  fi
}

MAIN_MENU(){
  echo -e "\nWhat's your phone number?\n"
  read CUSTOMER_PHONE
  
  HAVE_CLIENT=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $HAVE_CLIENT ]]
   then
   echo "I don't have a record for that phone number, what's your name?"
   read CUSTOMER_NAME
   INSERTED=$($PSQL "INSERT INTO customers(phone, name) VALUES( '$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
   echo -e "\nNew Client\n"
   CREATE_APPOINTMENT
   else 
   CREATE_APPOINTMENT
  fi
}
CREATE_APPOINTMENT (){
  NAME_CLIENT=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CLIENT_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  CLIENT_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nWELCOME  \nWhat time would you like your$CLIENT_SERVICE,$NAME_CLIENT?"
  read SERVICE_TIME
  NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, name, time) VALUES($CLIENT_ID,$HAVE_SERVICE,'$NAME_CLIENT','$SERVICE_TIME')")
  echo "I have put you down for a$CLIENT_SERVICE at $SERVICE_TIME,$NAME_CLIENT."
  LIST_SERVICES "Do you want to schedule something else?"
}
EXIT() {
  echo -e "\nThank you!.\n"
}
LIST_SERVICES

