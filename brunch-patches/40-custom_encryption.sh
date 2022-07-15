# This patch implements a different cryptohome approach (swtpm does not work with cryptohome since r103)

ret=0

cat >/roota/usr/share/cros/startup_utils.sh <<'ENCRYPTION'
mount_var_and_home_chronos() {
  mkdir -p /mnt/stateful_partition/var
  mount -n --bind /mnt/stateful_partition/var /var || return 1
  mkdir -p /mnt/stateful_partition/ecryptfs/encrypted /mnt/stateful_partition/ecryptfs/unencrypted
  mount -t ecryptfs -o key=passphrase,passwd=$(cat /sys/class/dmi/id/board_serial /sys/class/dmi/id/board_name /sys/class/dmi/id/product_uuid /sys/class/dmi/id/product_name  | tr '\n' 'n' | openssl passwd -stdin -5 -salt xyz | xxd -pu -l 16),ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_passthrough=no,ecryptfs_enable_filename_crypto=yes,no_sig_cache,verbosity=0 /mnt/stateful_partition/ecryptfs/encrypted /mnt/stateful_partition/ecryptfs/unencrypted || return 1
  mount -n --bind /mnt/stateful_partition/ecryptfs/unencrypted /home/chronos || return 1
}

umount_var_and_home_chronos() {
umount /home/chronos
umount /mnt/stateful_partition/ecryptfs/unencrypted
umount /var
}
ENCRYPTION
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi

exit $ret
