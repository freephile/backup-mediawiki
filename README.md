Backup-Mediawiki
================

Complete Backup Script for MediaWiki

This script will backup your wiki database, your wiki filesystem and also make an XML dump of the wiki content.

To ensure you're using the proper database character set, look for [`$wgDBTableOptions`](https://www.mediawiki.org/wiki/Manual:$wgDBTableOptions) in your LocalSettings.php file. The default used in the backup script is 'binary' which matches many/most Mediawikis so most likely you won't need to even specify this option.  But be warned that getting it wrong can be a big problem, so check; AND test your restore procedure!

## Database name
You'll need to know the name of the database you want to backup.  Look for `$wgDBname` in your LocalSettings.php file.

## Database credentials
You could specify `$wgDBuser` and `$wgDBpassword` on the command line with this script.  However, that can easily expose your credentials to other users on your system.  To use this script securely, make use of the [MySQL options file](https://dev.mysql.com/doc/refman/5.7/en/option-files.html) at `$HOME/.my.cnf`

## Privileges
The user running the script will need write privileges to LocalSettings.php (to put the wiki in read-only maintenance mode) as well as write privileges to the backup directory.

## What's Included and Excluded
This script excludes .svn directories but will backup .git repositories and all other VCS files found in your file system. It will include files that are ignored by your VCS.  Thus passwords or other sensitive data files are included in your backup. `--exclude-caches` and `--exclude-backups` are in effect.  See the [tar manual](https://www.gnu.org/software/tar/manual/html_section/tar_49.html) for what these exclude options mean.
