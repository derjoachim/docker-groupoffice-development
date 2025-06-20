Group-Office docker compose
===========================

This docker compose environment can be used for development. 
It will install these services:

1. mariadb
2. mailserver based on dovecot and postfix
3. groupoffice Apache web server with PHP, Composer and xdebug running on port 8080
4. phpunit for testing
5. sass container that will watch and compile sass files for you.
6. Libretranslate to help translators with machine translations.

Installation
------------

1. Make sure docker is installed.


2. Clone this repository:

   ```bash
   git clone --recurse-submodules https://github.com/Intermesh/groupoffice-docker-development.git
   ```

3. Go into the source dfirectory and checkout the 'master' branch:

   ```bash
   cd groupoffice-docker-development/src/master
   git checkout master
   git pull
   ```

4. Run the stack:

   ```bash
   docker compose up -d
   ```
   
   Note: The first time you run it 'composer install' and 'npm install' will run. This can take some time to complete. View the logs to see the progress.

5. Install Group-Office by going to http://localhost:8080/install/. Note you should not see a page where you enter database connection details. If you see this something is wrong with the database container.

6. Configure a cron job on the host machine so that Group Office can run scheduled tasks. 
   On Linux create a file /etc/cron.d/groupoffice and add (replace "/PATH/TO/docker-groupoffice-development"):

   ```cron
   * * * * * root cd /PATH/TO/docker-groupoffice-development && docker compose exec -T groupoffice php /usr/local/share/groupoffice/cron.php
   ```

    > On MacOS I ran on the terminal:
    >
    > ```bash
    > crontab -e
    > ```
    >
    > And added:
    >
    > ```bash
    > * * * * * cd /PATH/TO/docker-groupoffice-development && docker compose exec -T groupoffice php /usr/local/share/groupoffice/cron.php
    > ```

7. All done. Happy coding!

Unit testing
------------

> **WARNING**: This will destroy and recreate database called "groupoffice_phpunit".

```bash
docker compose exec groupoffice ./www/vendor/phpunit/phpunit/phpunit -c tests/phpunit.xml tests
```

See below for debugging too.

Profiling
---------

You can create a profile by setting setting XDEBUG_MODE: "profile" in the docker compose.yml file.
And create a bind mound: "./profile:/tmp/profile:delegated" to access the profile data.

Debugging
---------

Xdebug is ready to run. You just need to setup path mappings. 
Map your local folder
 "$YOUR_INSTALL_PATH/docker-groupoffice-development/src/master" to "/usr/local/share/src" 
in the Docker container to tell your IDE that's where the source files are on the server.

XDebug doesn't auto start. I recommend using the XDebug browser extension to enable it for requests.1
On the command line you can set the environment variable::

    docker compose exec -e XDEBUG_SESSION=1 groupoffice ./www/cli.php

### PHPStorm

For PHPStorm debugging on the command line make sure you set mappings for "localhost" at Settings -> Languages & Frameworks -> PHP -> Servers. Because we set the 'PHP_IDE_CONFIG' environment vairable to "localhost" in docker compose.yml.

See also:
https://www.jetbrains.com/help/phpstorm/zero-configuration-debugging-cli.html#6e577196

Open shell
----------

If you'd like to open a shell inside the container then you can run:

```bash
docker compose exec groupoffice bash
```

Building Typescript and SASS
----------------------------
The git clone only contains the source files and not the compiled css and js. When the container start it will
run ./scripts/build.sh which compiles all inside the docker container. You can watch all inside the docker container with:

```bash
docker compose exec groupoffice ./scripts/watch.sh
```

***Warning***: This uses many resources as it watches all modules. You can also use PHPStorm or another tool to watch them individually.

***Note for Mac users***: The node modules are installed for linux. If you want to compile on a mac you need to reinstall outside
the container:

Remove all node modules:
```bash
docker compose exec groupoffice find www -type d -name "node_modules" -exec rm -rf {} \;
```

```
./scripts/install-npm.sh
```

Now you can run ./scripts/watch.sh (heavy see above) or use PHP storm to start each process sepately.

Translating
-----------
Make sure the development tools module is installed.

Run this command to export language. LibreTranslate runs locally and
will be used to machine translate the missing string:

```
docker compose exec groupoffice php www/cli.php community/dev/Language/export --language=nl --translate --missingOnly | tee nl-missing.csv
```

Import language file:
```
docker compose exec groupoffice php www/cli.php community/dev/Language/import --path=lang.csv
```

Useful commands
---------------

Build SASS, GOUI Typescript modules and install composer packages:
```bash
docker compose exec groupoffice ./scripts/build.sh
```

Watch SASS and GOUI Typescript modules (This uses many resources and is not recommended but very easy to use):
```bash
docker compose exec groupoffice ./scripts/watch.sh
```

Run composer:
```bash
docker compose exec -w /usr/local/share/src/www groupoffice composer update -o
```

Run legacy CLI commands:
```bash
docker compose exec groupoffice php ./www/groupofficecli.php -r=postfixadmin/mailbox/cacheUsage -c=/etc/groupoffice/config.php -q
```

Run cron:

```bash
docker compose exec --user www-data groupoffice php ./www/cron.php
```

Upgrade:
```
docker compose exec -u www-data groupoffice ./www/cli.php core/System/upgrade
```

Watch debug.log file:
```shell
docker compose exec groupoffice  tail -f /var/lib/groupoffice/log/debug.log
```


Database access
---------------
You can connect from the host at port 8306 by default.

To enter the mariaDB container run:

```shell
docker compose exec db bash
```

Login to the mariadb server as root:

```shell
mariadb -u root -p
```

If you have newly built your Docker environment, you may update privileges for the 'groupoffice' user:

```sql
GRANT ALL PRIVILEGENS ON *.* to 'groupoffice'@localhost;
FLUSH PRIVILEGES;
```

To ease development you can login without a password if you run this query:

```sql
grant all privileges on *.* to root@localhost identified via unix_socket;
```

Now you can enter the mariadb server by running:

```shell
docker compose exec db mariadb
```
