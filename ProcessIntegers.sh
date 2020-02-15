#!/bin/bash

# Script takes a list of integers as arguments and returns a response with the
# average (mean), total, maximum and minimum values. Prints the average to two
# decimal places. Input values are always integers.


# Check we actually got arguments
if [[ $# -eq 0 ]]; then
    echo Please provide integers as arguments for calculations.
    exit 1
else
    # Init vars
    mycount=0
    mytotal=0
    myaverage=0
    # It can only go up or down from the first arg!
    mymax=$1
    mymin=$1

    # Process arguments
    while [[ $# -gt 0 ]]; do
        mycount=$((++mycount))
        mytotal=$((mytotal+10#$1))
        if [ "$1" -lt "$mymin" ]; then
            mymin=$1
        fi
        if [ "$1" -gt "$mymax" ]; then
            mymax=$1
        fi
        shift
    done

    #Calculate the mean average
    # Originally used bc...
    # myaverage=$(echo "scale=2; ${mytotal} / ${mycount}" | bc)
    # This way is less threads/more efficient
    myaverage=$(printf %.2f\\n "$((10**9 * 10#${mytotal} / 10#${mycount}))e-9")
    echo Average: $myaverage
    echo Total: $mytotal
    echo Max: $mymax
    echo Min: $mymin
fi
