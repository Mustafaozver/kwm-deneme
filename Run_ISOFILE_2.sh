# CTRL+ALT+G imleci kurtarır

HDDFILE="./QCOW/ISODENEME.qcow"

#qemu-img create -f qcow2 ./QCOW/ISODENEME.qcow 100G

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -drive id=disk0,format=qcow2,file=$HDDFILE,cache=writeback,aio=native,cache.direct=on \
  -rtc base=localtime \
  -bios ./BIOS/OVMF.fd \
  -net user,hostfwd=tcp::3389-:3389 -net nic