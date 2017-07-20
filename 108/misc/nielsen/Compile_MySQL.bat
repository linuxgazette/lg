
export download_file=mysql-standard-4.1.5-gamma-pc-linux-i686.tar.gz
export mysql_compile_dir=mysql-4.1.5-gamma
export ftp_dir=ftp://mirror.aca.oakland.edu/pub/mysql/Downloads/MySQL-4.1

export prefix=/usr/local/mysql4.1
  ### Change this variable to whereever you downloaded your files to.
export compile_home=/usr/local/src/MySQL

export root_password='this is a dumb password, please change.'
export mysql_password='simple password'

#-------------------------------------------------
  ## Lets add the mysql.mysql account in case it doesn't exist. 
adduser -g mysql mysql

#------------------------------------------------------------
  # Cd to the directory where we will build MySQL 4.1
cd /usr/local/src
mkdir -p MySQL
cd MySQL

  # Download the version of MySQL you want. 
if [ ! -e $download_file ]; then 
  wget -O $download_file $ftp_dir/$download_file
fi

  # We need three files, if they don't exist, abort.
  # Please download from my article in The Linux Gazette.

for file in my.cnf Start_MySQL Stop_MySQL; do
  if [ ! -e Config/$file ]; then
     echo "Config/$file doesn't exist. Please download from Mark's article."
     exit
  fi
done;

  ## Make sure we have stopped mysql if installing again.
if [ -e $prefix/Stop_MySQL ]; then chmod 755 $prefix/Stop_MySQL; fi
if [ -x $prefix/Stop_MySQL ]; then $prefix/Stop_MySQL; fi
if [ -x /etc/rc.d/init.d/mysqld ]; then service mysqld stop; fi

  ### Remove the previous compile
rm -rf $mysql_compile_dir
  ## We will delete the previous install. Hope you don't have data you need.
rm -rf $prefix

#------------------------------------------------------------------

  ## Compile the program and install it.
tar -zxvf $download_file
cd $mysql_compile_dir
make clean
  ### Even though we try to isolate mysql to a specific directory, 
  ### the lock file, pid file, and data dir end up being outside prefix. 
  ### We have to change some things later to isolate mysql to the prefix.
./configure --prefix=$prefix --with-openssl --with-ndbcluster --datadir=$prefix/data --libdir=$prefix/lib --localstatedir=$prefix/var --with-vio
make 
if ! make install ; then
 echo "Installation failed." 
 exit
fi

echo "Now entering customizations."

#----------------------------------------------------------------------
  ## Copy over the files we need to get things started.
cd ..
cp -f Config/Compile_MySQL.bat $prefix/

echo "" > $prefix/Start_MySQL
echo "" > $prefix/Stop_MySQL
echo "export prefix=$prefix" >> $prefix/Start_MySQL
echo "export prefix=$prefix" >> $prefix/Stop_MySQL
cat Config/Start_MySQL >> $prefix/Start_MySQL
cat Config/Stop_MySQL >> $prefix/Stop_MySQL
chmod 755 $prefix/St*

  ### I really hate sed and awk. The manpages or info pages are awful and
  ### should have really good examples on how to do stuff. 
  ### I should do this in a perl one-liner or python.
export prefix2=`echo $prefix | sed -e "s/\//\|/g;"`
mkdir -p $prefix/etc
sed -e "s/__PREFIX__/$prefix2/g" Config/my.cnf | sed -e "s/|/\//g" > $prefix/my.cnf
cp -f $prefix/etc/my.cnf /etc/


#----------------------------------
## Now do some things with the installed mysql
cd $prefix/

export PATH=$prefix/bin:$PATH

echo "Please remember to put 'export PATH=$prefix/bin:\$PATH' in your .bash_profile file."

./bin/mysql_install_db

mkdir -p $prefix/var/lib/mysql
mkdir -p $prefix/var/log/
mkdir -p $prefix/var/run/mysqld/
mkdir -p $prefix/data/mysql
mkdir -p $prefix/var/lock/subsys/
mkdir -p $prefix/tmp
mkdir -p $prefix/slave_load

chown -R mysql $prefix
chown -R mysql.mysql $prefix
chmod 700 $prefix/data

  #You can start the MySQL daemon with:
$prefix/Start_MySQL 

echo "Sleeping 5 seconds to let the mysql server start."

  ## Change permissions on various accounts.
  ## The last command will require root to use a password afterwards.

  ## Delete anonymous accounts.
echo "Deleting anoynmous accounts."
echo "delete from user where user=''" | $prefix/bin/mysql mysql

  ## Add a read-only mysql account.
echo "Creating read only mysql account."
echo "grant select on *.* to mysql@localhost identified by '$mysql_password'" | $prefix/bin/mysql mysql

  ## Change the root password.
echo "Changing root password for mysql".
echo "update user set Password=password('$root_password') where user='root'" |$prefix/bin/mysql mysql

  ## Make note
echo "Note: new passwords for root won't be available until flush or restart."

