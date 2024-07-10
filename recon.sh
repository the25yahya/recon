#!/bin/bash 
BOLD='\033[1m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

domain=""
directory=""

source ./scan.sh


while getopts ":d:ljpcb" opt; do
 case $opt in
   d)
     domain=$OPTARG
     directory="${domain}_recon"
    ;;
   l)
     linked_discovery_flag=true
    ;;
   j)
     js_discovery_flag=true
     ;;
   p)
     spidering_flag=true
     ;;
   c)
     scraping_flag=true
     ;;
   b)
    brute_forcing_flag=true
    ;;
   ?)
     echo "invalid option: -$OPTARG" >&2
     exit 1
     ;;
   :)
     echo "Option -$OPTARG requires an argument." >&2
     exit 1
     ;;
  esac
done

if [ -z "$domain" ]; then
   echo "you must specify a domain with the -d option"
   exit 1
fi

mkdir -p "$directory"
(  
   cd "$directory" || exit
   touch subdomains.txt
   touch actualSites.txt
   touch site_urls.txt
   touch interesting.txt
)

# Call functions based on flags
if [ "$linked_discovery_flag" = true ]; then
  linked_discovery "$domain" "$directory"
fi


if [ "$js_discovery_flag" = true ]; then
  js_discovery "$domain" "$directory"
fi

if [ "$scraping_flag" = true ]; then
  scraping "$domain" "$directory"
fi

if [ "$spidering_flag" = true ]; then
  spidering "$domain" "$directory"
fi

if [ "$brute_forcing_flag" = true ]; then
  bruteForcing "$domain" "$directory"
fi

# Keywords to search for in actualSites.txt
keywords="admin|administrator|internal|intranet|portal|dashboard|control|manage|management|secure|panel|root|super|system|config|api|app|apps|services|service|web|backend|frontend|database|db|search|gateway|proxy|cache|cdn|auth|login|register|signup|user|account|accounts|customer|client|partner|supplier|support|help|billing|pay|payment|finance|dev|development|test|testing|qa|stage|staging|prod|production|beta|alpha|devops|git|svn|repo|repos|ci|cd|jenkins|build|deploy"

# Loop over actualSites.txt and find lines containing the keywords, add them to interesting.txt
grep -E "$keywords" "$directory/actualSites.txt" >> "$directory/interesting.txt"