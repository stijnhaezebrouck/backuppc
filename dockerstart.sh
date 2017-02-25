#!/bin/bash
echo Starting backuppc...

# Don't continue after errors
set -exuo pipefail

# Set proper globbing to ensure hidden files get moved as well
shopt -s dotglob

# Use initial config if we dont have one already
if [[ ! "$(ls -A $BACKUPPC_CONFIG)" ]]; then
  echo "Config directory is empty, using default configuration..."
  mv -Z $BACKUPPC_INITIAL_CONFIG/* $BACKUPPC_CONFIG
fi

if [[ -f $BACKUPPC_CONFIG/.msmtprc ]]; then
  echo "Setting file permissions for .msmntprc"
  chown backuppc:backuppc $BACKUPPC_CONFIG/.msmtprc
  chmod 600 $BACKUPPC_CONFIG/.msmtprc
fi

# Use directroy structure from package management if we dont have any
if [[ ! "$(ls -A $BACKUPPC_DATA)" ]]; then
  echo "Data directory is empty, using defalt data..."
  mv -Z $BACKUPPC_INITIAL_DATA/* $BACKUPPC_DATA
fi

# Set proper permissions
if [ $RESET_PERMISSIONS == 'true' ] ; then
  echo "Setting permissions"
  chown -R backuppc:www-data $BACKUPPC_CONFIG
  chown -R backuppc:backuppc $BACKUPPC_DATA
  chmod 775 $BACKUPPC_CONFIG $BACKUPPC_DATA
fi

echo $TIMEZONE > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata


if [[ -f $POST_CONFIG ]]; then
  chmod a+x $POST_CONFIG
  $POST_CONFIG
fi
/usr/bin/supervisord
