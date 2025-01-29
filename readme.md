# GuvnorRecon

## Overview

GuvnorRecon is an automated reconnaissance tool for subdomain enumeration, URL extraction, and full recon on a target domain.

## Features

- **Subdomain Enumeration:** Uses multiple tools like Subfinder, Amass, Assetfinder, crt.sh, and others.
- **URL Extraction:** Gathers URLs using Waybackurls, Gau, Katana, and Paramspider.
- **Service Discovery:** Identifies active services using DNSX and HTTPX.
- **Full Recon Mode:** Performs subdomain enumeration, checks for alive subdomains, extracts URLs, and discovers active services.
- **Interactive Mode:** If no mode or domain is provided, the script prompts for input.

## Installation

Run the setup script to install all dependencies:

```bash
chmod +x setup.sh
./setup.sh
```

## Usage

Run the script with one of the following modes:

```bash
chmod +x guvnor_recon.sh
./guvnor_recon.sh <mode> <domain>
```

### Modes

- `subs` - Enumerate subdomains
- `urls` - Extract URLs
- `full` - Perform full recon

### Example

```bash
./guvnor_recon.sh full example.com
```

## Output

Results are stored in a directory named after the target domain.

## Dependencies

- `go` (for Go-based tools)
- `curl`, `jq`, `git`, `python3`, and `pip3`
- Various security tools like Subfinder, Amass, HTTPX, etc.

## Disclaimer

This tool is for educational and security testing purposes only. Do not use it without proper authorization.
