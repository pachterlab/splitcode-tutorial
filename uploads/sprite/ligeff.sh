#!/bin/bash

# Usage: ligeff.sh sprite_o1.fastq.gz sprite_u1.fastq.gz DPM,NYB,ODD,EVEN,ODD

# Where sprite_o1.fastq.gz is the "assigned" FASTQ and sprite_u1.fastq.gz is the "unassigned" FASTQ
# and where DPM,NYB,ODD,EVEN,ODD are the search pattern prefixes for tag names (case in-sensitive)
# Limitations: Cannot have a single tag-type present more than 3 times (e.g. no more than 3 odd barcodes)
# Limitations: Tags must have unique prefixes (e.g. ODD and ODDA is not acceptable)
# Default tags if third argument isn't provided: DPM,NYB,ODD,EVEN,ODD

assigned="$1"
unassigned="$2"
str="$3"

if [[ ! -e "$assigned" ]]; then
    echo "Error: First file does not exist: $assigned";
    exit 1;
fi

if [[ ! -e "$unassigned" ]]; then
    echo "Error: Second file does not exist: $unassigned";
    exit 1;
fi

if [ $str ]; then
final_tags_=""
min_num=999999
for i in ${str//,/ }
do
if [ ${#i} -lt $min_num ]; then
min_num=${#i}
fi
done
for i in ${str//,/ }
do
    tag_name=$(echo ${i} | tr '[:lower:]' '[:upper:]')
    tag_name=$(echo ${tag_name}|cut -c 1-$min_num)
    tag_name_="${tag_name}_0"
    if [[ "$final_tags_" != "" && "$final_tags_" == *"$tag_name_"* ]]; then
      tag_name_="${tag_name}_1"
      if [[ "$final_tags_" != "" && "$final_tags_" == *"$tag_name_"* ]]; then
         tag_name_="${tag_name}_2"
         if [[ "$final_tags_" != "" && "$final_tags_" == *"$tag_name_"* ]]; then
           tag_name_="${tag_name}_3"
         fi
      fi
    fi
    tag_name="$tag_name_"
    final_tags_="${final_tags_}${tag_name},"
done
final_tags=$(echo ${final_tags_}|rev | cut -c 2- | rev)

else
# Default
final_tags="DPM_0,NYB_0,ODD_0,EVE_0,ODD_1"
fi

num_full=$(zcat -f -- ${assigned}|awk 'NR%4==0'|wc -l)
num_barcodes_in_assigned_read=$(echo ,${final_tags}|tr -cd ',' | wc -c)

num_tags=$(echo ${final_tags}|awk -F"," '{print NF}')

bc_counts=$(zcat -f -- ${unassigned}|awk -F ':' 'NR % 4 == 1 { print $3} '| awk -v TAGS=${final_tags} -v nums=0 -v total_num_bcs=$num_barcodes_in_assigned_read '{ nums+=1; cpos=0; split(TAGS,arrayval,","); split($0,a,"["); split("", xx); nums_bc=0; for (i=1;i<=length(arrayval);i++) {inv[arrayval[i]] = i;} for (i=2;i<=length(a);i++) { x=toupper(substr(a[i],0,3));  if (xx[x"_0"] == 0 && cpos < inv[x"_0"]) { xx[x"_0"] = 1; cpos=inv[x"_0"]; } else { if (xx[x"_1"] == 0 && cpos < inv[x"_1"]) { xx[x"_1"] = 1; cpos=inv[x"_1"]; } else { xx[x"_2"] = 1; cpos=inv[x"_2"]; } } } for (tag in arrayval) { total[arrayval[tag]]+=xx[arrayval[tag]]; nums_bc+=xx[arrayval[tag]]; } nums_bc_total[nums_bc]+=1; if (nums_bc >= total_num_bcs) { total_num_bcs = nums_bc; } } END { printf nums" "; printf total_num_bcs+1; printf " | "; for (i=0; i<=total_num_bcs+1; i++) { printf (i)":"nums_bc_total[i]" " }; printf " | "; for (i=1; i<=length(arrayval); i++) { printf ","total[arrayval[i]]; }  printf "\n" }')

num_barcodes_unassigned=$(echo $bc_counts |cut -d' ' -f1)
num_positions=$(echo $bc_counts |cut -d' ' -f2)
pos_info=$(echo $bc_counts |cut -d'|' -f2)
counter=$(echo $bc_counts |cut -d'|' -f3)
num_barcodes=$(($num_full + $num_barcodes_unassigned))

if [ $num_barcodes -eq 0 ]; then
pct_full="0.0"
else
pct_full=$(awk -v var1=$num_full -v var2=$num_barcodes 'BEGIN { printf  ("%.1f", 100*var1 / var2 ) }')
fi

for (( i=0; i<=$((num_positions-2)); i++ ))
do
pos_i=$(($i+1))
pos_and_count=$(echo $pos_info|cut -d' ' -f$pos_i)
pos=$(echo $pos_and_count|cut -d':' -f1)
count=$(echo $pos_and_count|cut -d':' -f2)
case $count in
    ''|*[!0-9]*) count=0 ;;
esac
if [ $count -eq 0 ]; then
pct="0.0"
else
pct=$(awk -v var1=$count -v var2=$num_barcodes 'BEGIN { printf  ("%.1f", 100*var1 / var2 ) }')
fi

echo "$count ($pct%) reads found with $i barcodes."
done
echo "$num_full ($pct_full%) reads found with $num_barcodes_in_assigned_read barcodes."

echo "";

for (( i=1; i<=$num_tags; i++ ))
do
pos_i=$(($i+1))
count=$(echo $counter|cut -d',' -f$pos_i)
count=$(($count+$num_full))
case $count in
    ''|*[!0-9]*) count=0 ;;
esac
if [ $count -eq 0 ]; then
pct="0.0"
else
pct=$(awk -v var1=$count -v var2=$num_barcodes 'BEGIN { printf  ("%.1f", 100*var1 / var2 ) }')
fi

echo "$count ($pct%) barcodes found in position $i."
done
