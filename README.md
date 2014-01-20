SystemMonitor
=============

An amazing system activity tracking and chart generation in PHP

Debian package dependencies
---------------------------

* [sysstat](http://packages.debian.org/en/stable/sysstat)
* [net-tools](http://packages.debian.org/en/stable/net-tools)
* [gawk](http://packages.debian.org/en/stable/gawk)
* [iputils-ping](http://packages.debian.org/en/stable/iputils-ping)
* [procps](http://packages.debian.org/en/stable/procps)
* [mysql-server](http://packages.debian.org/en/stable/mysql-server)
* [php5-mysqlnd](http://packages.debian.org/en/stable/php5-mysqlnd)

How to install
--------------

* Install required packages (using `aptitude` for example)
* Install and configure a http server
* Modify `db/database.sql`, `shell/monitor.cron`, `www/monitor.php` and `shell/monitor.sh` according to your needs
* Import `db/database.sql` into your database
* Insert filesystems and pinghosts into your database (see `db/example.sql`)
* Put `shell/monitor.sh` anywhere, `chown root` and `chmod u+x` it
* Put `www/` content somewhere into your http server document directory
* Put `shell/monitor.cron` into `/etc/cron.d/`
* Do a `service cron restart`

Used libs
---------

* [jQuery](http://jquery.com/)
* [Flot](http://www.flotcharts.org/)
* [Bootstrap](http://getbootstrap.com/)

Todo
----

* Rewrite Bash script in [PHP-CLI](http://www.php.net/manual/en/features.commandline.php)
	* Wrap shell code using [ShellWrap](https://github.com/MrRio/shellwrap)
	* Multiple DBMS support using [PDO](http://www.php.net/manual/en/book.pdo.php)
* Use triggers instead of hardcoded preprocess requests
* Dynamic JS code generation
	* Use Ajax
* New trackers
	* Disk/IO
	* Net/IO
	* Iptables rules count (iptables-save | egrep "^-A" | wc -l)
* Finer configuration
* Admin interface
* Unprivileged user support
* Daemon instead of a cron job
* Standalone API for generic data gathering
	* OO refactoring
	* REST API
* Multiple system aggregation
* Downtime support
