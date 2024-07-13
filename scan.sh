#!/bin/bash

# Define the output path using the domain as a subdirectory
output_path="/home/kali/reconFramework/${2}_recon/"

linked_discovery(){
  echo -e "${BOLD}${GREEN}running hakrawler..."
  echo https://$1 | hakrawler -subs > hakrawler.txt
  echo -e "${BOLD}${GREEN}got results of hakrawler..."
  echo -e "${BOLD}${GREEN}appending results to site_urls.txt" 
  cat hakrawler.txt >> "${output_path}site_urls.txt" && rm hakrawler.txt
}

js_discovery(){
    echo -e "${BOLD}${BLUE}running SubDomainizer${NC}"
    (cd /home/kali/SubDomainizer && \
        python3 SubDomainizer.py -u "https://$1" -o SubDomainizer.txt && \
        cat SubDomainizer.txt >> "${output_path}subdomains.txt")
    
    echo -e "${BOLD}${BLUE}running httprobe${NC}"
    (cd /home/kali/SubDomainizer && \
        cat SubDomainizer.txt | httprobe >> "${output_path}actualSites.txt" && \
        rm SubDomainizer.txt)
}

scraping(){
    echo -e "${BOLD}${RED}scraping cert sh database...${NC}"
    cert_sh_results=$(python3 recon.py "$1")

    echo -e "${BOLD}${RED}GOT SUBDOMAINS FROM CRT.SH${NC}"
    echo -e "${BOLD}${RED}CERT.SH RESULTS:${NC}"
    echo "$cert_sh_results"
    echo ""

    echo -e "${BOLD}${RED}adding subdomains to subdomains.txt${NC}"
    echo "$cert_sh_results" >> "${output_path}subdomains.txt"


    echo -e "${BOLD}${RED}using httprobe to hit real sites${NC}"
    echo "$cert_sh_results" | httprobe >> "${output_path}actualSites.txt"

    echo ""
    echo ""
    echo -e "${BOLD}..."
    echo -e ".."
    echo -e ".${NC}"

    ### subscraper ###################
    echo -e "${BOLD}${YELLOW}running subscraper...${NC}"
    (cd /home/kali/subscraper && \
    python3 subscraper.py -d $1 -o subscraper.txt && \
    cat subscraper.txt >> "${output_path}subdomains.txt")
    echo -e "${BOLD}${YELLOW}running httprobe${NC}"
    (cd /home/kali/subscraper && \
    cat subscraper.txt | httprobe >> "${output_path}actualSites.txt" && \
    rm subscraper.txt)
    echo ""
    echo -e "${BOLD}..."
    echo -e ".."
    echo -e ".${NC}"

    ###subfinder##########################
    echo -e "${BOLD}${BLUE}running subfinder...${NC}"
    subfinder -d "$1" -o subfinder.txt && cat subfinder.txt >> "${output_path}subdomains.txt"
    echo -e "${BOLD}${BLUE}got subfinder results"
    echo -e "${BOLD}${BLUE}running httprobe to hit actual sites..."
    cat subfinder.txt | httprobe >> "${output_path}actualSites.txt" && rm subfinder.txt
   
    ### sublister #########################
    echo -e "${BOLD}${YELLOW}running sublist3r..."
    sublist3r -d $1 -t 50 -o sublister.txt && cat sublister.txt >> "${output_path}subdomains.txt"
    echo -e "${BOLD}${BLUE}running httprobe to hit actual sites..."
    cat sublister.txt | httprobe >> "${output_path}actualSites.txt" && rm sublister.txt
}

