#!/bin/bash 
BOLD='\033[1m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

domain=""
directory=""

cert_sh(){
    cert_sh_results=$(python3 recon.py "$1")

    echo -e "${BOLD}${RED}GOT SUBDOMAINS FROM CRT.SH${NC}"
    echo ""

    echo -e "${BOLD}${RED}CERT.SH RESULTS:${NC}"
    echo "$cert_sh_results"
    echo ""

    echo -e "${BOLD}${RED}adding subdomains to subdomains.txt${NC}"
    echo "$cert_sh_results" >> "$2/subdomains.txt"

    echo -e "${BOLD}${RED}using httprobe to hit real sites${NC}"
    echo "$cert_sh_results" | httprobe >> "$2/actualSites.txt"

    echo -e "${BOLD}${RED}Contents of subdomains.txt:${NC}"
    cat "$2/subdomains.txt"
    echo -e "${BOLD}${RED}Contents of actualSites.txt:${NC}"
    cat "$2/actualSites.txt"
}

gobuster(){

echo -e "${BOLD}${GREEN}running gobuster to brute force subdomains${NC}"
gobuster_results=$(gobuster dns -d $1 -w /home/kali/n0kovo_subdomains/n0kovo_subdomains_medium.txt -t 50 --wildcard)

echo -e "${BOLD}${GREEN}got gobuster results${NC}"
purify=$(echo "$gobuster_results" | awk '{print $1}')
echo -e "${BOLD}${GREEN}appending results to subdomains.txt${NC}"

echo "$purify" >> "$2/subdomains.txt"
echo -e "${BOLD}${GREEN}appending actual sites to actualSites.txt${NC}"
echo "$purify" | httprobe >> "$2/actualSites.txt"

}

subdomainizer(){
    echo -e "${BOLD}${BLUE}running SubDomainizer${NC}"
    (cd /home/kali/SubDomainizer && \
        python3 SubDomainizer.py -u "https://$1" -o SubDomainizer.txt && \
        cat SubDomainizer.txt >> /home/kali/reconFramework/"$2"/subdomains.txt)
    
    echo -e "${BOLD}${BLUE}running httprobe${NC}"
    (cd /home/kali/SubDomainizer && \
        cat SubDomainizer.txt | httprobe >> /home/kali/reconFramework/"$2"/actualSites.txt && \
        rm SubDomainizer.txt)
}

while getopts ":d:cgs" opt; do
 case $opt in
   d)
     domain=$OPTARG
     directory="${domain}_recon"
    ;;
   c)
     cert_sh_flag=true
    ;;
   g)
     gobuster_flag=true
     ;;
   s)
     subdomainizer_flag=true
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
)

# Call functions based on flags
if [ "$cert_sh_flag" = true ]; then
  cert_sh "$domain" "$directory"
fi


if [ "$subdomainizer_flag" = true ]; then
  subdomainizer "$domain" "$directory"
fi

if [ "$gobuster_flag" = true ]; then
  gobuster "$domain" "$directory"
fi