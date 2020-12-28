#!/bin/bash
ECHO=/bin/echo
bcftools view -i "FORMAT/AD[:3]<2 && INFO/AD[3]<5" M2018-DP100.vcf > Site3.vcf
bcftools query -f "%CHROM %POS\n" Site3.vcf > Pos3.txt
bcftools view -i "FORMAT/AD[:2]<2 && INFO/AD[2]<5" M2018-DP100.vcf > Site2.vcf
bcftools query -f "%CHROM %POS\n" Site2.vcf > Pos2.txt
while IFS= read -r line ; do
if [[ ${line:0:2} = "##" ]] ; then
  echo $line 
elif [[ ${line:0:1} = "#" ]] ; then
  FNUM=`echo $line | sed s'/#//' | sed 's/FORMAT.*/FORMAT/' | wc -w`
  SC=`echo $line | sed s'/#//' | sed 's/.*FORMAT//' | wc -w`
  ALTNUM=`echo $line | sed s'/#//' | sed 's/ALT.*/ALT/' | wc -w`
  INFONUM=`echo $line | sed s'/#//' | sed 's/INFO.*/INFO/' | wc -w`
  SNUM=$(( $FNUM + 1 ))
  echo $line | sed 's# #\t#g'
else
  CHR=`echo "$line" | awk '{print $1}'` 
  POS=`echo "$line" | awk '{print $2}'`
  SITE3=`grep -w "$CHR" Pos3.txt | grep -w "$POS"`
  SITE2=`grep -w "$CHR" Pos2.txt | grep -w "$POS"`
  line2P=`echo $line | sed -e 's# #\t#g'`
  if [[ ! -z "$SITE3" ]] ; then
    NAD=`echo "$line2P" | awk -v var=$FNUM '{print $var}' | sed 's#AD.*#AD#' | sed 's#:# #g' | wc -w`
    ALT=`echo "$line2P" | awk -v var=$ALTNUM '{print $var}'`
    ALTNEW=`echo $ALT | sed 's#\(.*\),.*#\1#'`
    INFOAD=`echo $line2P | awk -v var=$INFONUM '{print $var}' | sed 's#.*AD#AD#' | sed 's#;.*##'`
    INFOADNEW=`echo $INFOAD | sed 's#\(.*\),.*#\1#'`
    FORMATOLD=`echo "$line2P" | cut -d$'\t' -f $SNUM-`
    FORMATNEW=""
    for (( i=1; i<=$SC; i++ )) ; do
      FTMP=`echo $FORMATOLD | awk -v var=$i '{print $var}'`
      STR=`echo $FTMP | sed 's#:# #g' | awk -v var=$NAD '{print $var}'`
      NEWSTR=`echo "$STR" | sed 's#\(.*\),.*#\1#'`
      STROUT=`echo $FTMP | sed "s#"$STR"#"$NEWSTR"#"`
      FORMATNEW=$FORMATNEW" "$STROUT
    done
    FORMATOLDN=`echo $FORMATOLD | sed 's#\t# #g'`
    FORMATNEWN=`echo $FORMATNEW | sed 's#\t# #g'`
    lineN=`echo $line2P | sed 's#\t# #g'`
    line2P=`echo $lineN | sed -e "s#$FORMATOLDN#$FORMATNEWN#" | sed "s#$ALT#$ALTNEW#" | sed "s#$INFOAD#$INFOADNEW#" | sed -e 's# #\t#g' `
  fi
  if [[ ! -z "$SITE2" ]] ;then
    NAD=`echo "$line2P" | awk -v var=$FNUM '{print $var}' | sed 's#AD.*#AD#' | sed 's#:# #g' | wc -w`
    ALT=`echo "$line2P" | awk -v var=$ALTNUM '{print $var}'`
    ALTNEW=`echo $ALT | sed 's#\(.*\),.*#\1#'`
    INFOAD=`echo $line2P | awk -v var=$INFONUM '{print $var}' | sed 's#.*AD#AD#' | sed 's#;.*##'`
    INFOADNEW=`echo $INFOAD | sed 's#\(.*\),.*#\1#'`
    FORMATOLD=`echo "$line2P" | cut -d$'\t' -f $SNUM-`
    FORMATNEW=""
    for (( i=1; i<=$SC; i++ )) ; do
      FTMP=`echo $FORMATOLD | awk -v var=$i '{print $var}'`
      STR=`echo $FTMP | sed 's#:# #g' | awk -v var=$NAD '{print $var}'`
      NEWSTR=`echo "$STR" | sed 's#\(.*\),.*#\1#'`
      STROUT=`echo $FTMP | sed "s#"$STR"#"$NEWSTR"#"`
      FORMATNEW=$FORMATNEW" "$STROUT
    done
    FORMATOLDN=`echo $FORMATOLD | sed 's#\t# #g'`
    FORMATNEWN=`echo $FORMATNEW | sed 's#\t# #g'`
    lineN=`echo $line2P | sed 's#\t# #g'`
    line2P=`echo $lineN | sed -e "s#$FORMATOLDN#$FORMATNEWN#" | sed "s#$ALT#$ALTNEW#" | sed "s#$INFOAD#$INFOADNEW#"`
  fi
  echo $line2P | sed -e 's# #\t#g'
fi
done < $1

rm Site2.vcf
rm Site3.vcf
rm Pos2.txt
rm Pos3.txt
