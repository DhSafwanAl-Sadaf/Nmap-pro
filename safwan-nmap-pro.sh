#!/bin/bash

# ===== Safwan's Telegram Bot =====
TELEGRAM_BOT_TOKEN="8171178347:AAFvZJ4rYD1RuvlKCHq9S99dV31JTbNdf8g"
TELEGRAM_CHAT_ID="5043034104"

# ===== Ask User for Custom Bot (Optional) =====
read -p "📩 Do you want to send report to your own Telegram bot? (y/n): " ownbot
if [[ "$ownbot" == "y" || "$ownbot" == "Y" ]]; then
  read -p "🤖 Enter your Bot Token: " USER_BOT_TOKEN
  read -p "🆔 Enter your Chat ID: " USER_CHAT_ID
fi

# ===== Banner =====
banner() {
  clear
  echo -e "\e[1;36m"
  echo "_______  _______  _______           _______  _        "
  echo "(  ____ \(  ___  )(  ____ \|\     /|(  ___  )( (    /|"
  echo "| (    \/| (   ) || (    \/| )   ( || (   ) ||  \  ( |"
  echo "| (_____ | (___) || (__    | | _ | || (___) ||   \ | |"
  echo "(_____  )|  ___  ||  __)   | |( )| ||  ___  || (\ \) |"
  echo "      ) || (   ) || (      | || || || (   ) || | \   |"
  echo "/\____) || )   ( || )      | () () || )   ( || )  \  |"
  echo "\_______)|/     \||/       (_______)|/     \||/    )_)"
  echo -e "\e[0m"
  echo -e "\e[1;33m===============================================\n👨‍💻 Developer : Safwan Al-Sadaf\n🌐 Facebook  : https://www.facebook.com/share/15kFDb1uXr/\n✈️ Telegram  : @Safwan_al_sadaf\n🔧 Tool      : Safwan Nmap Pro Scanner\n===============================================\e[0m"
}

# ===== IP Info =====
get_ip_location() {
  echo -e "\n\e[1;34m🌍 Fetching IP info for $target ...\e[0m"
  info=$(curl -s "https://ipinfo.io/$target/json")
  city=$(echo "$info" | grep '"city"' | cut -d'"' -f4)
  region=$(echo "$info" | grep '"region"' | cut -d'"' -f4)
  country=$(echo "$info" | grep '"country"' | cut -d'"' -f4)
  org=$(echo "$info" | grep '"org"' | cut -d'"' -f4)
  echo -e "📍 Location: $city, $region, $country"
  echo -e "🏢 ISP/Org: $org"
}

# ===== HTML Export =====
export_html() {
  html="${outfile%.*}.html"
  echo "<html><head><title>Nmap Report</title></head><body><h2>Nmap Scan Report for $target</h2><pre>" > "$html"
  cat "$outfile" >> "$html"
  echo "</pre></body></html>" >> "$html"
  echo -e "\e[1;32m✔️ HTML report saved as $html\e[0m"
}

# ===== Telegram Sender =====
send_telegram() {
  msg="Nmap Scan Report for $target%0A$(head -n 20 "$outfile" | sed 's/$/%0A/')"

  # Send to Safwan
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    -d chat_id="$TELEGRAM_CHAT_ID" -d parse_mode="HTML" -d text="$msg" > /dev/null
  echo -e "\e[1;32m✔️ Report sent to Safwan's Telegram\e[0m"

  # Send to User (if provided)
  if [[ -n "$USER_BOT_TOKEN" && -n "$USER_CHAT_ID" ]]; then
    curl -s -X POST "https://api.telegram.org/bot$USER_BOT_TOKEN/sendMessage" \
      -d chat_id="$USER_CHAT_ID" -d parse_mode="HTML" -d text="$msg" > /dev/null
    echo -e "\e[1;36m✔️ Report also sent to user's Telegram bot\e[0m"
  fi
}

# ===== Target Info =====
get_target() {
  while true; do
    read -p "📍 Enter Target IP / Domain: " target
    [[ -n "$target" ]] && break || echo -e "\e[1;31m[✘] Target cannot be empty.\e[0m"
  done
  read -p "💾 Save report as (leave empty to skip): " outfile
}

# ===== Run Scan =====
run_scan() {
  get_ip_location
  echo -e "\n\e[1;33m🔍 Running: $cmd\e[0m\n"
  if [[ -z "$outfile" ]]; then
    eval "$cmd"
  else
    eval "$cmd" | tee "$outfile"
    echo -e "\n\e[1;32m✔️ Report saved as: $outfile\e[0m"
    export_html
    send_telegram
  fi
  read -p "🔁 Press Enter to return to menu..."
}

# ===== Menu Loop =====
while true; do
  banner
  echo -e "\e[1;36m====== Safwan Nmap Scanner Menu ======\e[0m"
  echo "1) General Scan"
  echo "2) Full Port Scan"
  echo "3) Service & Version Detection"
  echo "4) OS Detection"
  echo "5) Aggressive Scan"
  echo "6) Vulnerability Scan"
  echo "7) View Saved Report"
  echo "8) Exit"
  read -p "Choose option (1-8): " opt

  case $opt in
    1) get_target; cmd="nmap $target"; run_scan ;;
    2) get_target; cmd="nmap -p- $target"; run_scan ;;
    3) get_target; cmd="nmap -sV $target"; run_scan ;;
    4) get_target; cmd="nmap -O $target"; run_scan ;;
    5) get_target; cmd="nmap -A $target"; run_scan ;;
    6) get_target; cmd="nmap --script vuln $target"; run_scan ;;
    7)
      read -p "📂 Enter report file name: " file
      [[ -f "$file" ]] && echo -e "\n📄 $file\n" && cat "$file" || echo -e "\e[1;31m[✘] File not found!\e[0m"
      read -p "🔁 Press Enter to return to menu..."
      ;;
    8)
      echo -e "\e[1;32m👋 Exiting... Stay Ethical!\e[0m"
      exit
      ;;
    *)
      echo -e "\e[1;31m[✘] Invalid choice!\e[0m"; sleep 1 ;;
  esac
done