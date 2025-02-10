## AutoBackup VPS to VPS | by ValareCloud

---
Pengguna dilarang untuk menjual belikan script kepada orang lain.
Dilarang mengklaim bahwa script dibuat oleh kamu (pengguna)
Mengubah isi script kode diperbolehkan dengan syarat harus memfork repository ini
---

Tutorial install ( VPS Source )
1. Update linux package:
OS ubuntu:
apt update -y && apt upgrade -y

2. Install unzip, zip, dan rsync
OS ubuntu:
apt install zip -y && apt install unzip -y && apt install rsync -y

3. Upload file autoBackup di directory (folder) /root/ dan extract (unarchive) file .zip nya.

4. Edit file backup.sh sesuai keinginan mu dan jangan lupa untuk disave. 

5. Setting crontab agar script berjalan sesuai dengan waktu yang ditentukan
OS ubuntu:
- Ketikan "crontab -e" divps
- Masukkan "0 0 */3 * * bash /root/backup.sh >> /root/backup.log 2>&1" (backup 3 hari 1x)

6. Dan selesai

Tutorial install ( VPS Storage )
1. Update linux package:
OS ubuntu:
apt update -y && apt upgrade -y

2. Install unzip, zip, dan rsync
OS ubuntu:
apt install zip -y && apt install unzip -y && apt install rsync -y

3. Buat folder baru dengan nama "autoBackup", dan buat sub folder didalam folder "autoBackup" dengan nama contoh: shared, basic, private. Dengan begitu script akan membackup dan mensortir setiap backup sesuai node nya (script diinstall disetiap node). Jika tidak membuat subfolder tidak apa, script masih bisa berjalan

4. Dan selesai

Jika ingin mengganti configurasi nya kamu bisa mengganti nya di file "backup.sh" sesuai keinginan

Dan ya kita sudah sampai dipenghujung tutorial dan selamat mencoba terimakasih!
