echo "OPEN REMNIAN"
qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -drive id=disk0,format=qcow2,file=./QCOW/WINDOWSHDD.qcow,cache=writeback,aio=native,cache.direct=on \
  -rtc base=localtime \
  -bios ./BIOS/OVMF.fd \
  -vga virtio \
  -display none \
  -net user,hostfwd=tcp::3389-:3389 -net nic