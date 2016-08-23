Backup-Mediawiki
================

Basic Backup Script for MediaWiki

To ensure you're using the proper database charset, look for `$wgDBTableOptions` in your LocalSettings.php file. The default used in the backup script is 'binary'

* $wgDBname
* $wgDBuser
* $wgDBpassword

are the other settings in LocalSettings.php that you'll need to use this script.

The user running the script will need write privileges to LocalSettings.php (to put the wiki in read-only maintenance mode) as well as write privileges to the backup directory.

This version excludes .svn directories but will backup .git repositories and all other VCS files found in your file system. It will include files that are ignored by your VCS.  Thus passwords or other sensitive data files are included in your backup. `--exclude-caches` and `--exclude-backups` are in effect.  See https://www.gnu.org/software/tar/manual/html_section/tar_49.html for more on exclude options for tar
