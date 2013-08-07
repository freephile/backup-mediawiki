#!/bin/sh
 
####################################################################
#                                                                  #
# Basic Backup Script for MediaWiki.                               #
# Created by Daniel Kinzler, brightbyte.de, 2008                   #
#                                                                  #
# This script may be freely used, copied, modified and distributed #
# under the sole condition that credits to the original author     #
# remain intact.                                                   #
#                                                                  #
# 1st Mod: http://www.mediawiki.org/wiki/User:Kaotic               #
# 2nd Mod: http://www.mediawiki.org/wiki/User:Megam0rf             #
# 3rd Mod: http://www.mediawiki.org/wiki/User:Robkam               #
# 4rd Mod: http://kodango.com/backup-mediawiki                     #
#                                                                  #
# This script comes without any warranty, use it at your own risk. #
#                                                                  #
####################################################################
 
###############################################
# CHANGE THESE OPTIONS TO MATCH YOUR SYSTEM ! #
###############################################
 
function usage()
{
    cat <<EOF
Usage: `basename $0` <-n db_name> <-u db_user> <-p db_pwd> <-b backup_dir>
                     <-w wiki_install_dir> [-c charset] [-r readonly]

Options:
  -n  set the database your wiki stores data in.
  -u  set the database username.
  -p  set the database password.
  -b  set the directory to write the backup to.
  -w  set the directory mediawiki is installed in.
  -c  set the database charset, such as latin1, utf8, binary. Check your wiki's LocalSettings.php.
  -r  leave the wiki readonly when dump finished

Examples:
  bash `basename $0` -n my_wiki -u root -p 123456 -b ./bak_wiki -w /var/www/my_wiki

EOF
}

# Parse command line options
while getopts ":n:u:p:b:c:w:r" opt; do
    case $opt in
        h) usage && exit 0;;    # show help
        n) db_name="$OPTARG";;  # the database your wiki stores data in
        u) db_user="$OPTARG";;  # the database username
        p) db_pwd="$OPTARG";;   # the database password
        b) bak_dir="$OPTARG";;  # the directory to write the backup to
        c) charset="$OPTARG";;  # latin1, utf8, binary, etc. Check your wiki's LocalSettings.php
        w) wiki_dir="$OPTARG";; # the directory mediawiki is installed in
        r) wiki_ro=1;;          # leave the wiki readonly when dump finished
        \?) echo "Invalid option: -$OPTARG!" >&2;;
        :) echo "Option -$OPTARG requires an argument!" >&2;;
    esac
done

# Set default options
: "${charset:=binary}"

if [ $# -eq 0 ]; then
    usage && exit 0
fi

if [ -z "$db_name" ] || [ -z "$db_pwd" ] || [ -z "$wiki_dir" ] || \
        [ -z "$db_user" ] || [ -z "$bak_dir" ]; then
    echo "Error, missing some required options" >&2
    usage && exit 1
fi
 
##################
# END OF OPTIONS #
##################
 
timestamp=`date +%Y-%m-%d`
 
####################################
# Put the wiki into Read-only mode #
####################################
 
echo
echo "Putting the wiki in Read-only mode..."
 
maintmsg="\$wgReadOnly = 'Dumping Database, Access will be restored shortly';"

if ! grep -q "$maintmsg?>" "$wiki_dir"/LocalSettings.php 2>/dev/null; then
    sed -i "s/?>/$maintmsg?>/ig" "$wiki_dir"/LocalSettings.php
fi 
 
####################################

bak_dir=`readlink -f "$bak_dir"`
mkdir -p $bak_dir

dbdump="$bak_dir/$db_name-$timestamp.sql.gz"
filedump="$bak_dir/$db_name-$timestamp.files.tgz"
xmldump="$bak_dir/$db_name-$timestamp.xml.gz"

echo
echo -e "Wiki backup:\n-------------"
echo -e " Database:  $db_name\n Directory: $wiki_dir\n Backup to: $bak_dir"
echo -e "\ncreating database dump \t$dbdump..."
mysqldump --default-character-set=$charset --user=$db_user \
        --password=$db_pwd "$db_name" | gzip > "$dbdump" || exit $?
 
echo -e "creating file archive \t$filedump..."
cd "$wiki_dir"
tar --exclude .svn -zcf "$filedump" . || exit $?
 
echo -e "creating XML dump \t$xmldump..."
cd "$wiki_dir/maintenance"
php -d error_reporting=E_ERROR dumpBackup.php --full | gzip > "$xmldump" || exit $?
 
##########################################
# Put the wiki back into read/write mode #
##########################################
 
if [ "$wiki_ro" != "1" ]; then
    echo
    echo "Bringing the wiki out of Read-only mode..."
     
    if grep -q "$maintmsg?>" "$wiki_dir"/LocalSettings.php 2>/dev/null; then
        sed -i "s/$maintmsg?>/?>/ig" "$wiki_dir"/LocalSettings.php
    fi
fi
 
##########################################
 
echo
echo "Done!"
echo "Files to copy to a safe place:"
echo "$dbdump,"
echo "$filedump,"
echo "$xmldump"
 
#######
# END #
#######
