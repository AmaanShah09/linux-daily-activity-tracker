#!/bin/bash

# Configuration
DATA_DIR="$HOME/.daily-tracker"
LOG_FILE="$DATA_DIR/activities.log"
mkdir -p "$DATA_DIR"

# Function to track activity
track_activity() {
    local category="$1"
    local description="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp|$category|$description" >> "$LOG_FILE"
    echo "✅ Activity tracked successfully!"
}

# Function to generate daily report
generate_report() {
    local today=$(date '+%Y-%m-%d')
    echo -e "\n📋 Daily Activity Report - $(date '+%B %d, %Y')"
    echo "----------------------------------------"
    
    if ! grep -q "$today" "$LOG_FILE"; then
        echo "No activities recorded today."
        return
    fi

    # Print activities grouped by category
    grep "$today" "$LOG_FILE" | awk -F'|' '{
        category[$2] = category[$2] "\n- [" substr($1, 12, 5) "] " $3
    } END {
        for (cat in category) {
            print "\n" cat ":"
            print category[cat]
        }
    }'

    echo -e "\nTotal activities: $(grep "$today" "$LOG_FILE" | wc -l)"
}

# Set up cron job for daily report at 6 PM
setup_cron() {
    (crontab -l 2>/dev/null | grep -v "$PWD/daily.sh report"; echo "0 18 * * * $PWD/daily.sh report") | crontab -
    echo "✅ Daily report scheduled for 6 PM"
}

# Command handling
case "$1" in
    "track")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 track <category> <description>"
            exit 1
        fi
        track_activity "$2" "$3"
        ;;
    "report")
        generate_report
        ;;
    "setup")
        setup_cron
        ;;
    *)
        echo "Usage: $0 {track <category> <description>|report|setup}"
        exit 1
        ;;
esac
