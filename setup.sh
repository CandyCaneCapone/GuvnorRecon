#!/bin/bash

# Update package lists

# Install required packages
sudo apt install -y git curl jq python3 python3-pip

# Install subfinder
GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
sudo cp ~/go/bin/subfinder /usr/local/bin/

# Install assetfinder
go install github.com/tomnomnom/assetfinder@latest
sudo cp ~/go/bin/assetfinder /usr/local/bin/

# Install amass
GO111MODULE=on go install -v github.com/owasp-amass/amass/v3/...@master
sudo cp ~/go/bin/amass /usr/local/bin/

# Install waybackurls
go install github.com/tomnomnom/waybackurls@latest
sudo cp ~/go/bin/waybackurls /usr/local/bin/

# Install gau
go install github.com/lc/gau/v2/cmd/gau@latest
sudo cp ~/go/bin/gau /usr/local/bin/

# Install paramspider
git clone https://github.com/devanshbatham/paramspider.git
cd paramspider || exit
pip3 install -r requirements.txt --break-system-packages
sudo cp paramspider.py /usr/local/bin/paramspider
cd ..

# Install katana
go install github.com/projectdiscovery/katana/cmd/katana@latest
sudo cp ~/go/bin/katana /usr/local/bin/

# Install dnsx
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
sudo cp ~/go/bin/dnsx /usr/local/bin/

# Install httpx
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
sudo cp ~/go/bin/httpx /usr/local/bin/

# Clean up
rm -rf Sublist3r paramspider

# Done
echo "Setup complete. All tools are installed."

