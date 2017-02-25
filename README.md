# BackupPC
Backuppc is perl-cgi based software for backupping client pc's. Features include:
- server initiated backup
- backup clients when on the network
- avoid file duplication in backup
- Web UI for backing up, browsing and restoring files

For more info, see [BackupPC website](http://backuppc.sourceforge.net).

# Docker image
I have created a docker image to run the BackupPC software. It is based on the
Debian:jessie image.

## Features
- mountable data directory and config directory
- configurable time zone
- configurable smtp forwarder

## Configuration
### Environment variables
| variable          | default       | possible values       | purpose                                                            |
| ----------------- | ------------- | ----------------------| ------------------------------------------------------------------ |
| RESET_PERMISSIONS | false         | 'true' or 'false'     | change ownership and permissions on startup of data and config dir |
| TIMEZONE          | UTC           | 'Europe/Brussels' etc | set timezone at startup of docker container                        |

### Mountable volumes
Volumes are specified using the -v option on docer run.
If the volume is not mounted, default values are use.
If the mounted volume is empty, it will be automatically filled with defaults.

| docker container directory   | description                                                          |
| ---------------------------- | -------------------------------------------------------------------- |
| /etc/backuppc                | BackupPC config directory                                            |
| /var/lib/backuppc            | BackupPC data directory. Contains all backupped files + log files.   |

### User and group
Following [an attempt for uid/gid standardisation](https://wiki.archlinux.org/index.php/DeveloperWiki:UID_/_GID_Database),
a backuppc user and group are created with uid and gid 126.
The default password for backuppc is 'backuppc'. To change the password:
- mount a config directory on the volume
- run the docker container
- docker run -ti exec bash
- root# htpasswd /etc/backuppc/htpasswd backuppc

All contents in /etc/backuppc and /var/lib/backuppc should have ownership 126:126
and readable/writable permissions for 126. This can be achieved by setting $RESET_PERMISSIONS=true

The home directory for backuppc is /etc/backuppc and the shell is bash.
Ownership in /etc/backuppc should be backuppc:www-data (www-data has gid 33)

### Port
The port 80 is exposed. Access backuppc on http://dockerhost:8000/backuppc
when running container with -p 8000:80 option.

### BackupPC e-mails
Bacuppc can be configured to forward e-mails to an smtp server.
  Sendmail is replaced with msmtp. This can be configured by creating a configuration file
  /etc/backuppc/.msmtprc
When starting up the docker container with an empty configuration, a template
  for this file is copied by name /etc/backuppc/.msmtprc.template.gmail
  That file contains a sample configuration for gmail (when using 2-step auth, use an
  application specific password)

### Additional configuration
If script /etc/backuppc/scripts/post-config.sh exists, it will be executed as root 
prior to starting backkup. Its a hook to perform additional configuration.

# Image owner
Created by Stijn Haezebrouck for my own purposes, offer no warranties.
