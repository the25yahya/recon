linked_discovery(){
  echo -e "${BOLD}${GREEN}running hakrawler..."
  echo https://$1 | hakrawler -subs > hakrawler.txt
  echo -e "${BOLD}${GREEN}got results of hakrawler..."
  echo -e "${BOLD}${GREEEN}appending results to site_urls.txt" 
  cat hakrawler.txt >> /home/kali/reconFramework/"$2"/site_urls.txt && rm hakrawler.txt
}

js_discovery(){
    echo -e "${BOLD}${BLUE}running SubDomainizer${NC}"
    (cd /home/kali/SubDomainizer && \
        python3 SubDomainizer.py -u "https://$1" -o SubDomainizer.txt && \
        cat SubDomainizer.txt >> /home/kali/reconFramework/"$2"/subdomains.txt)
    
    echo -e "${BOLD}${BLUE}running httprobe${NC}"
    (cd /home/kali/SubDomainizer && \
        cat SubDomainizer.txt | httprobe >> /home/kali/reconFramework/"$2"/actualSites.txt && \
        rm SubDomainizer.txt)
}

spidering(){
  echo "not yet"
}

scraping(){
    echo -e "${BOLD}${RED}scraping cert sh database...${NC}"
    cert_sh_results=$(python3 recon.py "$1")

    echo -e "${BOLD}${RED}GOT SUBDOMAINS FROM CRT.SH${NC}"

    echo -e "${BOLD}${RED}CERT.SH RESULTS:${NC}"
    echo "$cert_sh_results"
    echo ""

    echo -e "${BOLD}${RED}adding subdomains to subdomains.txt${NC}"
    echo "$cert_sh_results" >> "$2/subdomains.txt"

    echo -e "${BOLD}${RED}Contents of subdomains.txt:${NC}"
    cat "$2/subdomains.txt"

    echo -e "${BOLD}${RED}using httprobe to hit real sites${NC}"
    echo "$cert_sh_results" | httprobe >> "$2/actualSites.txt"


    echo -e "${BOLD}${RED}Contents of actualSites.txt:${NC}"
    cat "$2/actualSites.txt"
        echo ""
    echo ""
    echo -e "${BOLD}..."
    echo -e ".."
    echo -e ".${NC}"
    echo -e "${BOLD}${YELLOW}running subscraper...${NC}"
  (cd /home/kali/subscraper && \
    python3 subscraper.py -d $1 -o subscraper.txt && \
    cat subscraper.txt >> /home/kali/reconFramework/"$2"/subdomains.txt)
  echo -e "${BOLD}${YELLOW}running httprobe${NC}"
  (cd /home/kali/subscraper && \
  cat subscraper.txt | httprobe >> /home/kali/reconFramework/"$2"/actualSites.txt && \
  rm subscraper.txt)    
    echo ""
    echo -e "${BOLD}..."
    echo -e ".."
    echo -e ".${NC}"
    echo -e "${BOLD}${BLUE}running subfinder...${NC}"
    subfinder -d "$1" -o subfinder.txt && subfinder.txt >> /home/kali/reconFramework/"$2"/subdomains.txt
    echo -e "${BOLD}${BLUE}got subfinder results"
    echo -e "${BOLD}${BLUE}running httprobe to hit actual sites..."
    cat subfinder.txt | httprobe >> /home/kali/reconFramework/"$2"/actualSites.txt && rm subfinder.txt
}

bruteForcing(){
  echo -e "${BOLD}${GREEN}running gobuster to brute force subdomains${NC}"
  gobuster_results=$(gobuster dns -d $1 -w /home/kali/n0kovo_subdomains/n0kovo_subdomains_medium.txt -t 50 --wildcard)

  echo -e "${BOLD}${GREEN}got gobuster results${NC}"
  purify=$(echo "$gobuster_results" | awk '{print $1}')
  echo -e "${BOLD}${GREEN}appending results to subdomains.txt${NC}"
  echo "$purify" >> "$2/subdomains.txt"

  echo -e "${BOLD}${GREEN}appending actual sites to actualSites.txt${NC}"
  echo "$purify" | httprobe >> "$2/actualSites.txt"

}