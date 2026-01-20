qemu-system-x86_64 --enable-kvm \
  -cpu host \
  -vga std              \
  -m 4G               \
  -cdrom ./Asset/NodeOS_bootfs.iso     \
  -hda ./Asset/NodeOS_usersfs.img