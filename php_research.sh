#!/bin/bash

DOMAIN="${1#https://}"
DOMAIN="${DOMAIN#http://}"
DOMAIN="${DOMAIN#www.}"

[ -z "$DOMAIN" ] && echo "Usage: $0 <domain>" && exit 1

HTML=$(curl -s -L "https://$DOMAIN" 2>/dev/null || curl -s -L "http://$DOMAIN")

echo "PHP Research - $DOMAIN"
echo "===================="

# Method 1: Basic regex for .php files
echo -e "\n[+] PHP files (basic regex):"
echo "$HTML" | grep -o -E '["\047/]?[a-zA-Z0-9_/-]+\.php[^"\047]*["\047]?' | \
    sed 's/["\047]//g' | sort -u | head -10 | sed 's/^/  /'

# Method 2: Search in HTML attributes
echo -e "\n[+] In HTML attributes:"
ATTRS="href src action data-src"
for attr in $ATTRS; do
    echo "$HTML" | grep -o -E "$attr=\"[^\"]*\.php[^\"]*\"" | \
        sed "s/$attr=\"//;s/\"$//" | head -3 | sed 's/^/  /'
done

# Method 3: Search in JavaScript code
echo -e "\n[+] In JavaScript code:"
echo "$HTML" | grep -o -E '["\047][^"\047]*\.php[^"\047]*["\047]' | \
    grep -v 'href\|src\|action' | sed 's/["\047]//g' | sort -u | head -5 | sed 's/^/  /'

# Method 4: Common admin paths
echo -e "\n[+] Common admin paths (quick scan):"
COMMON_PATHS="admin login wp-admin dashboard panel backend cms control"
for path in $COMMON_PATHS; do
    echo "$HTML" | grep -q -i "/$path" && echo "  /$path/"
done

# Method 5: Common critical files
echo -e "\n[+] Common critical files:"
CRITICAL_FILES="phpinfo test debug info config database setup install"
for file in $CRITICAL_FILES; do
    echo "$HTML" | grep -q -i "$file\.php" && echo "  $file.php"
done
