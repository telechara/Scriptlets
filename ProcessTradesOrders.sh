#!/bin/bash

# Given the two files (orders.txt and trades.txt) extract orders and match them
# to trades. Produce a report that prints CSV containing “ClientID, OrderID,
# Price, Volume”. Additionally, for each client print the total volume and
# turnover (turnover is the subtotal of price * volume on each trade).

# Example orders file
# ClientID,OrderID,Price,Volume:
# TRAD,TRAD6580494597,00000138,00001856
# MEGA,MEGA6760353333,00000070,00002458
# GROU,GROU9093170513,00000004,00003832
# TRAD,TRAD6563975285,00000347,00009428

# Example trades file:
# ClientID,Volume,Turnover
# AING,68746,24977345
# BANK,51921,16448128
# GROU,18301,5831218
# MEGA,56139,9225340
# TRAD,81047,19432408


myOrderFile="example_orders.txt"
myTradesFile="example_trades.txt"
myReportStore=""

echo "ClientID,OrderID,Price,Volume"
while IFS= read -r myLine
do
    #Sanitise - Remove empty lines/comments
    myLine=$(sed -e 's/#.*$//' -e '/^$/d' <<< "$myLine")
    #Do not process empty lines
    if [ ! -z "$myLine" ]; then
        IFS=',' read -r -a myArray <<< "$myLine"
        myClientID="${myArray[1]}"
        myOrderID="${myArray[3]}"
        myOrder=$(grep ${myOrderID} ${myTradesFile})
        #Check if order actually exists/matches in TradesFile (There are some which dont)
        if [ ! -z "$myOrder" ]; then
            myPrice=${myOrder:28:8}
            myVolume=${myOrder:36:8}
            echo ${myClientID},${myOrderID},${myPrice},${myVolume}
            # Originally used bc...
            # myReportStore+=${myClientID},${myVolume},$(echo "${myVolume} * ${myPrice}" | bc)$'\n'
            # This way is less threads/more efficient
            myReportStore+=${myClientID},${myVolume},$((10#${myVolume} * 10#${myPrice}))$'\n'
        fi
    fi
done < "$myOrderFile"

echo
echo "ClientID,Volume,Turnover"
#Sort by client ID, ignore blanks
myReportStore=$(sort -u <<< "$myReportStore" | sed -e '/^$/d')
myClientID=""
myCurrentID=""

while IFS= read -r myLine
do
    IFS=',' read -r -a myArray <<< "$myLine"
    myClientID="${myArray[0]}"
    #If we have already encountered this Client... perform sums
    if [ "$myClientID" = "${myCurrentID}" ]; then
        # Originally used bc...
        # myTotalVol=$(echo "${myTotalVol} + ${myArray[1]}" | bc)
        # myTotalTurn=$(echo "${myTotalTurn} + ${myArray[2]}" | bc)
        # This way is less threads/more efficient
        myTotalVol=$((10#${myTotalVol} + 10#${myArray[1]}))
        myTotalTurn=$((10#${myTotalTurn} + 10#${myArray[2]}))

    else
        #Handle first ClientID or Next ClientID
        if [ "$myCurrentID" = "" ]; then
            myCurrentID="${myArray[0]}"
        else
            echo "${myCurrentID},${myTotalVol},${myTotalTurn}"
        fi
        myCurrentID="${myArray[0]}"
        myTotalVol="${myArray[1]}"
        myTotalTurn="${myArray[2]}"
    fi
done <<< "$myReportStore"$'\n'
