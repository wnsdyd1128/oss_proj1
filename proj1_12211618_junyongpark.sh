#!/bin/bash

#! check args
if [ "$#" -ne 3 ]; then
  echo "Invalid usage"
  echo "Usage: ./proj1_12211618_junyongpark.sh <item_file> <data_file> <user_file>"
  exit 1
fi

item=$1
data=$2
user=$3
echo "--------------------------"
echo "User Name: Jun-Yong Park"
echo "Student Number: 12211618"

echo "[ MENU ]"

PS3="Enter your choice [ 1-9 ]: "
options=(\
  "Get the data of the movie identified by a specific 'movie id' from 'u.item'" \
  "Get the data of action genre movies from 'u.item'" \
  "Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'" \
  "Delete the 'IMDb URL' from 'u.item'" \
  "Get the data about users from 'u.user'" \
  "Modify the format of 'release date' in 'u.item'" \
  "Get the data of movies rated by a specific 'user id' from 'u.data'" \
  "Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'" \
  "Exit")
select opt in "${options[@]}"
do
  case $opt in
    "Get the data of the movie identified by a specific 'movie id' from 'u.item'")
      echo -n "Please enter 'movie id'(1~1682): "
      read movie_id
      echo 
      awk -F '|' -v id="$movie_id" '$1 == id {print}' $item 
      echo
      ;;
    "Get the data of action genre movies from 'u.item'")
      echo -n "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n): "
      read flag
      if [ "$flag" == "n" ]; then
        continue
      fi
      echo 
      awk -F '|' '$7 == 1 { printf "%s %s \n", $1, $2 }' $item | sort -n -k 1 -t " " | head -n 10
      echo 
      ;;
    "Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'")
      echo -n "Please enter the 'movie id'(1~1682): "
      read movie_id
      awk -F ' ' -v id="$movie_id" 'BEGIN {cnt = 0.0} $2 == id { sum += $3; cnt++ } END {printf "Average rating of %d: %.5f \n", id, sum / cnt + 0.000005}' $data 
      ;;
    "Delete the 'IMDb URL' from 'u.item'")
      echo -n "Do you want to delete the 'IMDB URL' from 'u.item'? (y/n): "
      read flag
      if [ "$flag" == "n" ]; then
        continue
      fi
      echo
      awk -F '|' '{ for(i = 1; i <= NF; i++)\
                      if (i != 5)\
                        printf("%s%s", $i, (i < NF) ? "|" : RS);\
                      else\
                        printf("|");\
                  }' $item | head -n 10
      ;;
    "Get the data about users from 'u.user'")
      echo -n "Do you want to get the data about users from 'u.user'? (y/n): "
      read flag
      if [ "$flag" == "n" ]; then
        continue
      fi
      echo
      awk -F '|' -v gender= '$3 == "F" {gender="female"} $3 == "M" {gender="male"} {printf "user %s is %s years old %s %s\n", $1, $2, gender, $4}' $user | head -n 10
      echo
      ;;
    "Modify the format of 'release date' in 'u.item'")
      echo -n "Do you want to modify the format of 'release data' in 'u.item'? (y/n): "
      read flag
      if [ "$flag" == "n" ]; then
        continue
      fi
      echo
      sed -e 's/Jan/01/g;
      s/Feb/02/g;
      s/Mar/03/g;
      s/Apr/04/g;
      s/May/05/g;
      s/Jun/06/g;
      s/Jul/07/g;
      s/Aug/08/g;
      s/Sep/09/g;
      s/Oct/10/g;
      s/Nov/11/g;
      s/Dec/12/g' u.item > item.tmp
      sed -Ee 's/([0-9]+)-([0-9]+ )-([0-9]+)/\3\2\1/g' item.tmp | tail -n 10
      rm -rf item.tmp
      echo
      ;;
    "Get the data of movies rated by a specific 'user id' from 'u.data'")
      echo -n "Please enter the 'user id'(1~943): "
      read user_id
      echo 
      awk -F ' ' -v id="$user_id" '$1==id { print $2 }' $data | sort -n > data.tmp
      total_cnt=$(cat data.tmp | wc -l)
      awk -v n="$total_cnt" 'BEGIN {cnt = 1} cnt == n {printf("%s", $1); cnt++;} cnt < n {printf("%s|", $1); cnt++;}' data.tmp
      echo
      echo
      i=0
      while read -r line
      do
        if [ "$i" -eq "10" ]; then
          break
        fi
        awk -F '|' -v num="$line" ' $1==num {printf("%s|%s", $1, $2);}' $item | sort -n -k 1 -t "|"
        ((i++))
      done < data.tmp
      rm -rf data.tmp
      echo
      ;;
    "Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'")
      echo -n "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): "
      read flag
      pre_ifs=$IFS
      declare -A array
      if [ "$flag" == "n" ]; then
        continue
      fi
      while IFS="|" read -r uid age gender occ zipcode
      do
        if (($age < 20 || $age > 29)); then
          continue
        fi
        if [ "$occ" != programmer ]; then
          continue
        fi
        array[$uid]=$uid
      done < $user
      while IFS="|" read -r mid etc
      do
        awk -F " " -v arr="${array[*]}" -v movie="$mid" 'BEGIN {split(arr, dict, " "); count=0; sum=0.0;} {
          flag = 0
          for (idx in dict) {
            if (dict[idx] == $1) {
              flag = 1
              break
            }
          }
          if (flag == 1 && $2 == movie) {
            sum += $3
            count++
          }
          
        } END {
          if (count != 0)
            print movie, sum / count
        }' $data
      done < $item
      IFS=$pre_ifs
      ;;
    "Exit")
      break
      ;;
  esac
done