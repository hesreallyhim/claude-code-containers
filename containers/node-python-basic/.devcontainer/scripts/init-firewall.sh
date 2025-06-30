#!/bin/bash
set -euo pipefail

echo "Initializing Claude Code firewall..."

# Flush existing rules and clean up
iptables -F 2>/dev/null || true
iptables -X 2>/dev/null || true
ipset destroy allowed-domains 2>/dev/null || true

# Allow loopback traffic (essential for local development)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow DNS resolution
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Create ipset for allowed domains
ipset create allowed-domains hash:net

# Fetch and add GitHub IP ranges
echo "Fetching GitHub IP ranges..."
gh_ranges=$(curl -s https://api.github.com/meta 2>/dev/null || echo '{"web":[],"api":[],"git":[]}')

if [ "$gh_ranges" != '{"web":[],"api":[],"git":[]}' ]; then
    echo "$gh_ranges" | jq -r '(.web + .api + .git)[]' 2>/dev/null | while read -r cidr; do
        if [[ "$cidr" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
            echo "Adding GitHub range: $cidr"
            ipset add allowed-domains "$cidr" 2>/dev/null || true
        fi
    done
else
    echo "Warning: Could not fetch GitHub ranges, using fallback IPs"
    # GitHub fallback ranges
    ipset add allowed-domains "140.82.112.0/20" 2>/dev/null || true
    ipset add allowed-domains "192.30.252.0/22" 2>/dev/null || true
fi

# Add other essential domains by IP
echo "Resolving essential domains..."
for domain in "registry.npmjs.org" "api.anthropic.com" "pypi.org" "files.pythonhosted.org" "pypi.python.org"; do
    echo "Resolving $domain..."
    ips=$(dig +short A "$domain" 2>/dev/null | head -5)
    if [ -n "$ips" ]; then
        echo "$ips" | while read -r ip; do
            if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "Adding $domain IP: $ip"
                ipset add allowed-domains "$ip" 2>/dev/null || true
            fi
        done
    else
        echo "Warning: Could not resolve $domain"
    fi
done

# Add PyPI CDN networks (Fastly CDN used by PyPI)
echo "Adding PyPI CDN ranges..."
# Fastly CDN ranges commonly used by PyPI
fastly_ranges=(
    "23.235.32.0/20"
    "43.249.72.0/22"
    "103.244.50.0/24"
    "103.245.222.0/23"
    "103.245.224.0/24"
    "104.156.80.0/20"
    "146.75.0.0/16"
    "151.101.0.0/16"
    "157.52.64.0/18"
    "167.82.0.0/17"
    "167.82.128.0/20"
    "167.82.160.0/20"
    "167.82.224.0/20"
    "172.111.64.0/18"
    "185.31.16.0/22"
    "199.27.72.0/21"
    "199.232.0.0/16"
)

for range in "${fastly_ranges[@]}"; do
    echo "Adding PyPI CDN range: $range"
    ipset add allowed-domains "$range" 2>/dev/null || true
done

# Allow outbound connections to whitelisted IPs only
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

# Allow SSH (port 22) for git operations
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS to whitelisted domains
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Default policy: deny all other outbound traffic
iptables -A OUTPUT -j DROP

echo "Firewall configuration complete!"

# Test connectivity
echo "Testing connectivity..."
if curl -s --connect-timeout 5 https://api.github.com/zen >/dev/null 2>&1; then
    echo "✓ GitHub API access verified"
else
    echo "⚠ GitHub API test failed - this may be expected in some environments"
fi

if curl -s --connect-timeout 5 https://pypi.org/simple/ >/dev/null 2>&1; then
    echo "✓ PyPI access verified"
else
    echo "⚠ PyPI test failed - this may be expected in some environments"
fi

echo "Claude Code firewall ready!"