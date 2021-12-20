#!/bin/bash

echo "{"

while read line
do 
  echo "    \"$(echo "$line" | cut -f2)\": \"$(echo "$line" | cut -f1)\","
done < courts.txt

echo "}"

