{
  "product": {
    "id": "openSUSE_Leap"
  },
  "localization": {
    "language": "es_ES.UTF-8",
    "keyboard": "es",
    "timezone": "UTC"
  },
  "hostname": {
    "static": "opensuse"
  },
  "user": {
    "fullName": "Vagrant",
    "userName": "vagrant",
    "password": "vagrant",
    "hashedPassword": false
  },
  "root": {
    "password": "vagrant",
    "hashedPassword": false
  },
  "software": {
    "packages": [
      "sudo",
      "openssh",
      "wget",
      "curl",
      "vim",
      "nano"
    ]
  },
  "scripts": {
    "post": [
      {
        "name": "vagrant_sudo_ssh",
        "chroot": true,
        "content": "#!/bin/bash\necho 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant\nchmod 0440 /etc/sudoers.d/vagrant\nsystemctl enable sshd"
      }
    ]
  }
}
