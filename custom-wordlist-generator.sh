#!/bin/bash

# Script used for generating custom wordlists using manually 
# created wordlist and web scrapping using cewl.

# colors
yel=$'\e[1;33m'
gre=$'\e[1;32m'
red=$'\e[1;31m'
cya=$'\e[0;36m'
end=$'\e[0m'

# check to see if running as root
if [[ ! $(id -u) -eq 0 ]]; then
    echo "[*] Script must run with root priviledges."
    exit 1
fi

# script requirements
echo "${yel}[*] Installing required packages...${end}"
sleep 1
# KoreLogic password cracking rules for John the Ripper
if [[ ! -d /opt/custom-wordlist-generator/korelogic/ ]]; then
   echo "${yel}[*]Installing korelogic...${end}"
    git clone https://github.com/SpiderLabs/KoreLogic-Rules.git /opt/custom-wordlist-generator/korelogic
fi
# The rule file is a combination of rules from various sources
if [[ ! -d /opt/custom-wordlist-generator/onerule/ ]]; then
    echo "${yel}[*] Installing onerule...${end}"
    git clone https://github.com/NotSoSecure/password_cracking_rules.git /opt/custom-wordlist-generator/onerule
fi
sleep 1
# check john.conf for korelogic rules
if [[ $(grep -i 'korelogic' /etc/john/john.conf | wc -l) -le 10 ]]; then
    echo
    echo "${red}[w] KoreLogic Rules not found in john.conf${end}"
    echo "${yel}[i] Append /opt/custom-wordlist-generator/korelogic/kore-logic-rules-full-separate.txt to /etc/john/john.conf and re-run this script.${end}"
    echo "${gre}[*] Do not forget to backup john.conf first. [e.g., sudo cp /etc/john/john.conf /etc/john/john.conf.bak]${end}"
    exit 1
fi

clear

echo
echo "${gre}=====================================${end}"
echo "${gre}[-]   Custom Wordlist Generator   [-]${end}"
echo "${gre}=====================================${end}"
echo

# custom wordlist to run through rules
echo
echo "${gre}[+] Enter a lists of words. One word per line. [+]${end}"
read -p "${yel}[+] Press [Enter] to open the vim text editor...${end}"
rm -rf /tmp/list.txt 2>/dev/null
vi /tmp/list.txt

# website wordlist using cewl
read -p "${gre}[+] Do you also want to include words from a website? [Y/N]: ${end}" answer
if [[ ${answer} == "y" || ${answer} == "Y" ]]; then
    read -p "${cya}[+] What is the URL? [e.g. https://www.domain.com]: ${end}" url
    echo "${yel}[-]${end}"
    echo "${yel}[*] Scrapping ${url}...${end}"
    echo "${yel}[-]${end}"
    rm -rf /tmp/cewl_temp.txt 2>/dev/null
    cewl -d 3 -m 8 --with-numbers -w /tmp/cewl_temp.txt ${url} &>/dev/null
    sleep .5
    cat /tmp/cewl_temp.txt >> /tmp/list.txt
    echo "${yel}[*] Scrapping complete!${end}"
fi

# Adding Seasons and Months with year
echo "Summer" > /tmp/22.txt
echo "Winter" >> /tmp/22.txt
echo "Autumn" >> /tmp/22.txt
echo "Spring" >> /tmp/22.txt
echo "Fall" >> /tmp/22.txt
echo "January" >> /tmp/22.txt
echo "February" >> /tmp/22.txt
echo "March" >> /tmp/22.txt
echo "April" >> /tmp/22.txt
echo "May" >> /tmp/22.txt
echo "June" >> /tmp/22.txt
echo "July" >> /tmp/22.txt
echo "August" >> /tmp/22.txt
echo "September" >> /tmp/22.txt
echo "October" >> /tmp/22.txt
echo "November" >> /tmp/22.txt
echo "December" >> /tmp/22.txt

cat /tmp/22.txt >> /tmp/list.txt

# cleanup before the rules
cat /tmp/list.txt | sort | uniq > /tmp/master.txt
rm -rf /tmp/list.txt 2>/dev/null

# Run through Rules
echo
echo "${gre} [*] Running OneRuleToRuleThemAll against list...${end}"
hashcat /tmp/master.txt -r /opt/onerule/OneRuleToRuleThemAll.rule --stdout 2>/dev/null | grep -v 'Skipping invalid or' 2>/dev/null > /tmp/2.txt
echo "${gre} [*] Running KoreLogic Top 7 Rules...${end}"
echo -e "\t${yel} [1] Running KoreLogicRulesPrependAppend1-4...${end}"
john --wordlist=/tmp/master.txt --rules=KoreLogicRulesPrependAppend1-4 --stdout 2>/dev/null >> /tmp/2.txt
echo -e "\t${yel} [2] Running KoreLogicRulesL33t...${end}"
john --wordlist=/tmp/master.txt --rules=KoreLogicRulesL33t --stdout 2>/dev/null >> /tmp/2.txt
echo -e "\t${yel} [3] Running KoreLogicRulesReplaceNumbers...${end}"
john --wordlist=/tmp/master.txt --rules=KoreLogicRulesReplaceNumbers --stdout 2>/dev/null >> /tmp/2.txt
echo -e "\t${yel} [4] Running KoreLogicRulesAddJustNumbersLimit8...${end}"
john --wordlist=/tmp/master.txt --rules=KoreLogicRulesAddJustNumbersLimit8 --stdout 2>/dev/null >> /tmp/2.txt
echo -e "\t${yel} [5] Running KoreLogicRulesAppendNumbers_and_Specials_Simple...${end}"
john --wordlist=/tmp/master.txt --rules=KoreLogicRulesAppendNumbers_and_Specials_Simple --stdout 2>/dev/null >> /tmp/2.txt
echo -e "\t${yel} [6] Running KoreLogicRulesReplaceLetters...${end}"
john --wordlist=/tmp/master.txt --rules=KoreLogicRulesReplaceLetters --stdout 2>/dev/null >> /tmp/2.txt
echo -e "\t${yel} [7] Running KoreLogicRulesReplaceLettersCaps...${end}"
john --wordlist=/tmp/master.txt --rules=KoreLogicRulesReplaceLettersCaps --stdout 2>/dev/null >> /tmp/2.txt

# Adding Seasons and Months with year
for i in $(cat /tmp/22.txt); do
    echo ${i}2018;
    echo ${i}2019;
    echo ${i}2020;
    echo ${i}2021;
    echo ${i}2018!;
    echo ${i}2019!;
    echo ${i}2020!;
    echo ${i}2021!;
    echo ${i}2022!;
    echo ${i}_2018;
    echo ${i}_2019;
    echo ${i}_2020;
    echo ${i}_2021;
    echo ${i}_2018!;
    echo ${i}_2019!;
    echo ${i}_2020!;
    echo ${i}_2021!;
    echo ${i}_2022!;
    echo ${i}.2018;
    echo ${i}.2019;
    echo ${i}.2020;
    echo ${i}.2021;
    echo ${i}.2022;
    echo ${i}.2018!;
    echo ${i}.2019!;
    echo ${i}.2020!;
    echo ${i}.2021!;
    echo ${i}.2022!;
done > /tmp/23.txt

# cleanup
sleep .5
cat /tmp/master.txt /tmp/22.txt /tmp/23.txt >> /tmp/2.txt
rm -rf /tmp/master.txt /tmp/22.txt /tmp/23.txt

echo "${cya}[-] Sorting, removing duplicates, and shuffling...${end}"
LC_ALL=C strings /tmp/2.txt | egrep -v '[[:space:]]' | egrep -v '^[[:punct:]]*$' | sort -T $(pwd) | uniq > /tmp/3.txt
rm -rf /tmp/2.txt
shuf < /tmp/3.txt > $(pwd)/custom_wordlist.txt
sleep .5
rm -rf /tmp/3.txt
echo
echo "${yel}[*] Wordlist generated: $(pwd)/custom_wordlist.txt${end}"