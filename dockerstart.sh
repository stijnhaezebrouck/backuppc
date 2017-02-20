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

# Use directroy structure from package management if we dont have any
if [[ ! "$(ls -A $BACKUPPC_DATA)" ]]; then
  echo "Data directory is empty, using defalt data..."
  mv -Z $BACKUPPC_INITIAL_DATA/* $BACKUPPC_DATA
  echo "Creating a ssh keypair"
  ssh-keygen -N '' -f $BACKUPPC_DATA/.ssh/id_rsa
fi

# Set proper permissions
if [ $RESET_PERMISSIONS == 'true' ] ; then
  echo "Setting permissions"
  chown -R backuppc:www-data $BACKUPPC_CONFIG
  chown -R backuppc:backuppc $BACKUPPC_DATA
  chmod 775 $BACKUPPC_CONFIG $BACKUPPC_DATA
  if [ -d $BACKUPPC_DATA/.ssh ] ; then
    chmod -R 0600 $BACKUPPC_DATA/.ssh/*
  fi
fi

/usr/bin/supervisord
