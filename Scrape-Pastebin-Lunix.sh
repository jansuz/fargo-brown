#!/bin/bash

ParseResults () {

sSearch="une.edu.au"
sFilename="tmp.scrape"
# LastEntry=""
sScrape=""

while read line;
  do
  sResult=""
  sScrape=$(echo $line | cut -d'=' -f2)
  curl --silent $line --output $sScrape

  if grep -q -e "^Please slow down" $sScrape; then
    let INUM=INUM-1
	if [ $INUM -lt 101 ]; then
	    let INUM=100;
    	fi
    echo "Decreasing to "$INUM"."
    sed -i  "/${sScrape}/d" $sFilename
  else
    # head -n 2 $sScrape
    # printf "\n~ "$sScrape" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\n"

    sResult=$(grep --ignore-case -e $sSearch $sScrape)
    # echo 1.$sSearch,2.$sResult,3.$sScrape,4.${#sResult}
    if [ ${#sResult} = 0 ]; then
      sed -i  "/${sScrape}/d" $sFilename
    else
      # echo -e \"$sSearch\"" found in "$sScrape"."
      echo $(date +"%Y%m%d%H%M%S"), $sScrape >> found.scrape
    fi
    if [ $INUM -gt 249 ]; then
      let INUM=250;
    else
      let INUM=INUM+1
      echo "Increasing to "$INUM"."
    fi
    rm $sScrape
  fi
  done < $sFilename
}

while [ 1 == 1 ];
	do
	# Scrape
        if [ $INUM==0 ]; then
          let INUM=250;
	fi
        echo "Scraping at "$(date +"%H:%M:%S")"..."
	echo "Fetching "$INUM" records."
	sFullScrape=$(curl --silent https://scrape.pastebin.com/api_scraping.php?limit=$INUM)
		echo $sFullScrape |
		sed -e 's/{/\n{/g' |
		grep scrape_url | \
		cut -d: -f2-3 | \
		sed 's/full_url//g' | \
		sed 's/^ //g' | \
		sed 's/[,"]//g' >> tmp.scrape

		# echo 'Grep: '$(grep -e '$(LastEntry)' tmp.scrape)
		# LastEntry=$(tail -n 1 tmp.scrape | cut -d'=' -f2)

		# I'd like to figure out how many *new* scrapes per scrape in case:
	        # 1. More than 250 new items per run
		# 2. Less than 250 new items per run
		echo $(date +"%Y%m%d%H%M%S"), $(wc -l tmp.scrape) >> counts.scrape

	 # Idealy I would like to perform the scrape investigation here within the looped timer.
	 ParseResults &

	# Sleep
	echo "Sleeping 2..." && sleep 60
	echo "Sleeping 1..." && sleep 60
	done
