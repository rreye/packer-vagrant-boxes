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
      }%{ if is_utm },
      {
        "name": "utm_network_config",
        "chroot": true,
        "content": "#!/bin/bash\nnmcli con add type ethernet ifname eth1 con-name eth1 ipv4.method auto ipv6.method ignore"
      }
%{ endif }
    ]
  }
}
