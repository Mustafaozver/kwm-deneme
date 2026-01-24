

DEVICE="/dev/nvme0n1"

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -drive file=$DEVICE,format=raw,if=virtio \
  -rtc base=localtime \
  -bios ./BIOS/OVMF.fd \
  -net user,hostfwd=tcp::3389-:3389 -net nic
