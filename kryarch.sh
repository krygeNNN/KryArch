bash part1.sh
if test -f flag_done; then
    rm flag_done
    arch-chroot /mnt /root/KryArch/part2.sh
    source /mnt/root/KryArch/envs.conf
    if [[ $plasma == "true" ]]; then
        arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/KryArch/part3.sh
    fi
fi

