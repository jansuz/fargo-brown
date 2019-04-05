#!/usr/local/bin/bash

ParseResults () {

sSearch="[dog|cat|mouse]"
sFilename="tmp.scrape"

while read line;
  do
  sResult=""
  sScrape=$(echo $line | cut -d'=' -f2)
  curl --silent $line --output $sScrape
  sResult=$(grep --ignore-case -e $sSearch $sScrape)
  if [ ${#sResult}==0 ]; then
    # echo -e \"$sSearch\"" not found in "$sScrape"."
    # Note the "" after -i, needed in OS X
    sed -i "" "/${sScrape}/d" $sFilename
  else
    # echo -e \"$sSearch\"" found in "$sScrape"."
    echo $(date +"%Y%m%d%H%M%S"), $sScrape >> found.scrape
  fi
  rm $sScrape
  done < $sFilename
}

while [ 1 == 1 ];
	do
	# Scrape
	echo "Scraping..."
	curl --silent \
		https://scrape.pastebin.com/api_scraping.php | \
		grep scrape_url | \
		cut -d: -f2-3 | \
		sed 's/[,"]//g' >> tmp.scrape

	#Parse
  ParseResults &

	# Sleep
	echo "Sleeping 3..." && sleep 60
	echo "Sleeping 2..." && sleep 60
	echo "Sleeping 1..." && sleep 60
	done
