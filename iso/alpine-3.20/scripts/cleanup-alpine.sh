#!/bin/sh -eux

echo "==> Running cleanup script (Alpine)..."

# Clean apk cache
rm -rf /var/cache/apk/*

# Remove temporary files
rm -rf /tmp/*

# Clear bash history (if bash is used)
if [ -f /home/vagrant/.bash_history ]; then
  unset HISTFILE
  rm -f /root/.ash_history # Default Alpine shell
  rm -f /home/vagrant/.ash_history
  rm -f /home/vagrant/.bash_history
fi

echo "==> Cleanup complete."
