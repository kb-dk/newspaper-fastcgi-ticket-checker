#!/bin/bash

MY_IP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n1)

GET_TICKET_URL="http://alhena:7950/ticket-system-service/tickets/issueTicket?id=doms_radioTVCollection:uuid:0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c&id=doms_radioTVCollection:uuid:853a0b31-c944-44a5-8e42-bc9b5bc697be&id=doms_radioTVCollection:uuid:8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d&type=Stream&ipAddress=$MY_IP&SBIPRoleMapper=inhouse"

echo $MY_IP
echo $GET_TICKET_URL 

TICKET=$(curl -sS $GET_TICKET_URL)

#TICKET="{\"doms_radioTVCollection:uuid:8eaca37b-c3a9-4afd-b8ed-9f7f86d5e82d\":\"3fc6b6e3-b095-4125-8421-63f28ef50fcb\",\"doms_radioTVCollection:uuid:853a0b31-c944-44a5-8e42-bc9b5bc697be\":\"3fc6b6e3-b095-4125-8421-63f28ef50fcb\",\"doms_radioTVCollection:uuid:0c6a18b8-a3c4-4dfc-9ece-1d7c8ffc908c\":\"3fc6b6e3-b095-4125-8421-63f28ef50fcb\"}"

echo $TICKET

TICKET_ID=$(echo $TICKET | cut -d':' -f4 | cut -d '"' -f2)

echo $TICKET_ID

SERVICE_URL="http://localhost/test/?ticket=$TICKET_ID"

curl $SERVICE_URL
