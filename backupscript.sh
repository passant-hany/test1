#! /bin/bash

SOURCE_DIR="/home/passant-hany/source_dir"
BACKUP_DIR="/home/passant-hany"
LOG_FILE="/home/passant-hany/log/backup_$(date +%Y%m%d_%H%M%S).log"
NOTIFY_EMAIL="passant.hany@live.com"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DIR_NAME=$(basename "$SOURCE_DIR")
ARCHIVE_NAME="${DIR_NAME}_${TIMESTAMP}.tar.gz"
TARGET_ARCHIVE="${BACKUP_DIR}/${ARCHIVE_NAME}"

mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

send_failure_notification() {
    local error_msg="ALERT: Backup FAILED for ${SOURCE_DIR} on $(hostname) at $(date)"
}

if [ -n "$NOTIFY_EMAIL" ]; then
        echo -e "${error_msg}\n\nCheck log file: ${LOG_FILE}" | mail -s "Backup Failure Alert" "$NOTIFY_EMAIL"
    fi

echo "=== Backup Started: $(date) ===" >> "$LOG_FILE"
echo "Source: $SOURCE_DIR" >> "$LOG_FILE"

START_TIME=$(date +%s)

tar -czvf "$TARGET_ARCHIVE" -C "$(dirname "$SOURCE_DIR")" "$DIR_NAME" >> "$LOG_FILE" 2>&1
EXIT_CODE=$?

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $EXIT_CODE -eq 0 ]; then
    STATUS="SUCCESS"
    FILE_SIZE=$(du -sh "$TARGET_ARCHIVE" | cut -f1)
else
    STATUS="FAILED (Exit Code: $EXIT_CODE)"
    FILE_SIZE="N/A"

    send_failure_notification
fi


# Get current timestamp (Format: YYYYMMDD_HHMMSS)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DIR_NAME=$(basename "$SOURCE_DIR")
ARCHIVE_NAME="${DIR_NAME}_${TIMESTAMP}.tar.gz"
TARGET_ARCHIVE="${BACKUP_DIR}/${ARCHIVE_NAME}"

# Ensure backup and log directories exist
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Start logging
echo "=== Backup Started: $(date) ===" >> "$LOG_FILE"
echo "Source: $SOURCE_DIR" >> "$LOG_FILE"

START_TIME=$(date +%s)

tar -czvf "$TARGET_ARCHIVE" -C "$(dirname "$SOURCE_DIR")" "$DIR_NAME" >> "$LOG_FILE" 2>&1
EXIT_CODE=$?

echo -e "\n========================================="
echo "            BACKUP SUMMARY               "
echo "========================================="
echo "Status:       $STATUS"
echo "Source:       $SOURCE_DIR"
echo "Archive:      $TARGET_ARCHIVE"
echo "Size:         $FILE_SIZE"
echo "Duration:     ${DURATION} seconds"
echo "Log File:     $LOG_FILE"
echo "========================================="

{
    echo "Status: $STATUS"
    echo "Size: $FILE_SIZE"
    echo "Duration: ${DURATION}s"
    echo "-----------------------------------------"
} >> "$LOG_FILE"
