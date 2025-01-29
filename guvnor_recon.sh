#!/bin/bash
mode=$1
domain=$2

show_banner() {
    cat << "EOF"

     ______                             ____                      
    / ____/_  ___   ______  ____  _____/ __ \___  _________  ____ 
   / / __/ / / / | / / __ \/ __ \/ ___/ /_/ / _ \/ ___/ __ \/ __ \
  / /_/ / /_/ /| |/ / / / / /_/ / /  / _, _/  __/ /__/ /_/ / / / /
  \____/\__,_/ |___/_/ /_/\____/_/  /_/ |_|\___/\___/\____/_/ /_/ 
           
   Crafted by ello_guvnor   
                           
EOF
}

show_menu() {
    echo "-------- Choose Your Mode --------"
    echo "1) Subdomain Enumeration"
    echo "2) URL Extraction"
    echo "3) Full Recon"
    echo "q) Quit"
    echo "----------------------------------"
    read -p "Enter your choice: " choice

    case "$choice" in
        1) mode="subs";;
        2) mode="urls";;
        3) mode="full";;
        q) exit 0;;
        *) echo "Invalid option!"; exit 1;;
    esac

    if [[ -z "$domain" ]]; then
        read -p "Enter the domain: " domain
        echo
    fi
}

show_banner

if [[ -z "$mode" || -z "$domain" ]]; then
    show_menu
fi

if [ -d "./$domain" ]; then
	cd ./$domain
else 
	mkdir $domain ; cd ./$domain
fi

enum_subs() {
    echo "[*] Enumerating subdomains for $domain..."

    {
        echo "[*] Enumerating subdomains using subfinder..."
        subfinder -d "$domain" -silent -all -o subfinder.txt > /dev/null 2>&1
    } &
    {
        echo "[*] Enumerating subdomains using assetfinder..."
        assetfinder --subs-only "$domain" | grep "$domain" | tee assetfinder.txt > /dev/null 2>&1
    } &
    {
        echo "[*] Enumerating subdomains using amass..."
        amass enum -passive -d "$domain" -o amass.txt > /dev/null 2>&1
    } &
    {
        echo "[*] Enumerating subdomains using jldc.me"
        curl -s "https://jldc.me/anubis/subdomains/$domain" | jq -r ".[]" | sort -u > jldc.txt
    } &
    {
        echo "[*] Enumerating subdomains using certspotter"
        curl -s "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" | jq -r '.[].dns_names[]' | sort -u | tee -a certspotter.txt > /dev/null 2>&1
    } &
    {
        echo "[*] Enumerating subdomains using hackertarget"
        curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | cut -d "," -f 1 | tee -a hackertarget.txt > /dev/null 2>&1
    }
    wait

    cat hackertarget.txt certspotter.txt subfinder.txt assetfinder.txt amass.txt jldc.txt | sort -u > all_subdomains.txt
    rm hackertarget.txt subfinder.txt assetfinder.txt amass.txt jldc.txt certspotter.txt
    echo "[*] Found $(wc -l all_subdomains.txt | awk '{print $1}') unique subdomains."
}

enum_urls() {
    echo "[*] Extracting URLs for $domain..."
    

    echo "[*] Running waybackurls..."
    echo "$domain" | waybackurls | tee waybackurls.txt > /dev/null 2>&1

    {
    	echo "[*] Running katana..."
    	katana -u "$domain" -ps -silent -o katana.txt > /dev/null 2>&1
    } & 
    {
    	echo "[*] Running gau..."
    	gau "$domain" --o gau.txt > /dev/null 2>&1
    } & 
    {
    	echo "[*] Running paramspider..."
    	paramspider -d "$domain" > /dev/null 2>&1
    	mv results/$domain.txt . ; mv $domain.txt paramspider.txt ; rm results/ -rf
    } & 
    
    wait
     
    cat waybackurls.txt katana.txt gau.txt paramspider.txt | sort -u > all_urls.txt
    rm waybackurls.txt katana.txt gau.txt paramspider.txt
    echo "[*] Found $(wc -l all_urls.txt | awk '{print $1}') unique URLs."
}

alive_subs() {
    echo "[*] Checking for alive subdomains of $domain"
    cat all_subdomains.txt | dnsx -silent -o alive_subdomains.txt > /dev/null 2>&1
    echo "[*] Found $(wc -l alive_subdomains.txt | awk '{print $1}') alive subdomains."

}

service_discovery() {
	echo "[*] Discovering active services on live subdomains of $domain"
	cat alive_subdomains.txt | httpx -silent -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:134.0) Gecko/20100101 Firefox/134.0" -sc -cl -title -td -fr -o targets.txt > /dev/null 2>&1

	echo "[*] Found $(wc -l targets.txt | awk '{print $1}') targets." 
}

# Full Recon
full() {
    echo "[*] Running full recon on $domain..."
    enum_subs
    alive_subs
    service_discovery
    enum_urls
}

# Subdomain enumeration mode
if [[ "$mode" == "subs" ]]; then
    enum_subs

# URL extraction mode
elif [[ "$mode" == "urls" ]]; then 
    enum_urls
    
elif [[ "$mode" == "full" ]]; then
    full
else
    echo "Invalid mode: $mode"
    exit 1
fi
