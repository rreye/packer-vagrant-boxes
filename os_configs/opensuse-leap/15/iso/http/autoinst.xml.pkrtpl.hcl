<?xml version="1.0"?>
<!DOCTYPE profile>
<profile xmlns="http://www.suse.com/1.0/yast2ns" xmlns:config="http://www.suse.com/1.0/configns">
  <general>
    <mode>
      <confirm config:type="boolean">false</confirm>
    </mode>
  </general>
  
  <keyboard>
    <keymap>spanish</keymap>
  </keyboard>
  <language>
    <language>es_ES</language>
  </language>
  <timezone>
    <hwclock>UTC</hwclock>
    <timezone>UTC</timezone>
  </timezone>

  <networking>
    <dns>
      <hostname>opensuse</hostname>
      <dhcp_hostname config:type="boolean">false</dhcp_hostname>
    </dns>
  </networking>
  
  <users config:type="list">
    <!-- Usuario Root -->
    <user>
      <username>root</username>
      <user_password>vagrant</user_password>
      <encrypted config:type="boolean">false</encrypted>
    </user>
    <!-- Usuario Vagrant -->
    <user>
      <username>vagrant</username>
      <user_password>vagrant</user_password>
      <encrypted config:type="boolean">false</encrypted>
      <fullname>Vagrant</fullname>
    </user>
  </users>

  <software>
    <packages config:type="list">
      <package>sudo</package>
      <package>openssh</package>
      <package>wget</package>
      <package>curl</package>
      <package>vim</package>
      <package>nano</package>
    </packages>
  </software>
  
  <scripts>
    <chroot-scripts config:type="list">
      <script>
        <chrooted config:type="boolean">true</chrooted>
        <filename>vagrant_sudo_ssh.sh</filename>
        <interpreter>shell</interpreter>
        <!-- Usamos CDATA para evitar problemas de escape con caracteres como > -->
        <source><![CDATA[#!/bin/bash
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant
systemctl enable sshd
]]></source>
      </script>
    </chroot-scripts>
  </scripts>
</profile>
