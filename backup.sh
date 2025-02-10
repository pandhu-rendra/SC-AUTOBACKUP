#!/bin/bash

# Variabel konfigurasi
SOURCE_DIR="/var/lib/pterodactyl/volumes"
TARGET_USER="root"
TARGET_IP="192.0.0.1"
NODE_NAME="SH-1"
TARGET_DIR="/autobackup"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1322158954121527316/9lzCavqfY-5VWgDVQTKF7dVKKHyv8emrN60vMwz6frVSA_V3UIX7jJ_jJQFK4s_Ams_s"
LOG_FILE="/root/backup.log"
ARCHIVE_FORMAT="tar.gz"

# Fungsi untuk mengirim notifikasi ke Discord
send_discord_notification() {
    local status="$1"
    local color="$2"

    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{
             "embeds": [{
                 "title": "<:vc1:1324506064183492649><:vc2:1324506113768423536><:vc3:1324506155984097401><:vc4:1324506198527180870><:vc5:1324506347785556008><:vc6:1324506391192277082>",
                 "description": "'"$status"'",
                 "color": '"$color"',
                 "footer": {
                     "text": "ValareCloud Backup System | '"$NODE_NAME"'",
                     "icon_url": "https://media.discordapp.net/attachments/1297526444574113855/1326132831847710741/VALARECLOUD.png?ex=677e50f1&is=677cff71&hm=2baf37a59957290563a1528ff3af96c1ad930bc6fdf315d45656e0105353eec5&=&format=webp&quality=lossless&width=230&height=230"
                 }
             }]
         }' \
         "$DISCORD_WEBHOOK_URL"
}

# Fungsi untuk setup SSH Key
setup_ssh_key() {
    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" > /dev/null
    fi

    ssh-copy-id -i ~/.ssh/id_rsa.pub "$TARGET_USER@$TARGET_IP" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "$(date) - Gagal setup SSH" >> "$LOG_FILE"
        send_discord_notification "<a:vcx:1298611251928367114> **Penyiapan Kunci SSH gagal!** Tidak dapat menyalin kunci SSH ke server target." 16711680
        exit 1
    fi
}

# Notifikasi awal
send_discord_notification "<a:vcloading:1320747053252612231> **Memulai proses pencadangan untuk '$NODE_NAME'**. Anda akan diberi tahu setelah pencadangan selesai dan aman!\n\n**Node Detail’s**\n<:vcdot:1297484497767628831> **Node:** $NODE_NAME\n<:vcdot:1297484497767628831> **Status:** <a:vcloading:1320747053252612231> Sedang dibackup!" 16711680

# Setup SSH Key jika diperlukan
setup_ssh_key

# Menghitung total folder yang akan dibackup
total_data=$(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
success_count=0
failed_count=0

# Backup folder
backup_success=true

# Format tanggal: "1 Januari 2025"
CURRENT_DATE=$(date +"%-d %B %Y")

# Buat folder otomatis berdasarkan nama node + tanggal di dalam VPS storage
FULL_TARGET_DIR="$TARGET_DIR/$NODE_NAME/$CURRENT_DATE"

ssh "$TARGET_USER@$TARGET_IP" "mkdir -p '$FULL_TARGET_DIR'" >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "$(date) - Gagal membuat folder backup $FULL_TARGET_DIR" >> "$LOG_FILE"
    send_discord_notification "<a:vcx:1298611251928367114> **Gagal membuat folder backup!** Tidak dapat membuat folder '$FULL_TARGET_DIR' di server target." 16711680
    exit 1
fi

for folder in "$SOURCE_DIR"/*/; do
    folder_name=$(basename "$folder")
    ARCHIVE_NAME="$folder_name.$ARCHIVE_FORMAT"

    if [ "$ARCHIVE_FORMAT" = "tar.gz" ]; then
        tar -czvf - "$folder" | ssh "$TARGET_USER@$TARGET_IP" "cat > '$FULL_TARGET_DIR/$ARCHIVE_NAME'" >> "$LOG_FILE" 2>&1
    elif [ "$ARCHIVE_FORMAT" = "zip" ]; then
        zip -r - "$folder" | ssh "$TARGET_USER@$TARGET_IP" "cat > '$FULL_TARGET_DIR/$ARCHIVE_NAME'" >> "$LOG_FILE" 2>&1
    else
        echo "$(date) - Format arsip tidak valid: $ARCHIVE_FORMAT" >> "$LOG_FILE"
        send_discord_notification "<a:vcx:1298611251928367114> **Format arsip tidak valid!** Harap gunakan 'tar.gz' atau 'zip'." 14353241
        exit 1
    fi

    if [ $? -ne 0 ]; then
        echo "$(date) - Gagal membackup folder: $folder_name" >> "$LOG_FILE"
        failed_count=$((failed_count+1))
        backup_success=false
    else
        success_count=$((success_count+1))
    fi
done

if [ "$backup_success" == true ]; then
    send_discord_notification "<a:vcsuccess:1298609625226149928> **Pencadangan berhasil untuk '$NODE_NAME'!** Arsip telah ditransfer dengan aman ke VPS Drive.\n\n**Upload Detail’s**\n<:vcdot:1297484497767628831> **Node:** $NODE_NAME\n<:vcdot:1297484497767628831> **Status:** <a:vcsuccess:1298609625226149928> Berhasil dibackup!\n<:vcdot:1297484497767628831> **Total data:** Berhasil: $success_count, Gagal: $failed_count" 16711680
else
    send_discord_notification "<a:vcx:1298611251928367114> **Pencadangan gagal untuk '$NODE_NAME'!** Silakan periksa log untuk keterangan lebih rinci." 16711680
fi

echo "$(date) - Backup process complete!" >> "$LOG_FILE"
echo "🎉 Backup process complete!"
