# RDBIconnections
## Manage your DBI connections

This package manages DBI connections by creating a YAML file in your home directory called `.RDBIconnections`. The file looks something like this.

```
the_nickname_you_choose:
  driver_constructor: RMariaDB::MariaDB()
  args:
    user: colinfraser
    password: password123
    host: thehost.myserver.aws.internet.web
    dbname: all_data
    ssl.cert: ssl_certificate.pem
another_one:
  driver_constructor: RPostgres::Postgress()
  args:
    user: post-read
    password: passpass
    host: postgress.server.mycompany.internet
    dbname: arrests
    ssl.cert: 
```


If this file is set up properly, then you can connect to the server specified by `the_nickname_you_choose` with `con <- connect("the_nickname_you_choose")`.

## Installation

With devtools, simply `install.github("colin-fraser/RDBIconnections")`.

## Setup

The first thing is to create the connection file. Running `add_connection` for the first time will initialize a new connection file.
To create the connection listed above, the process looks like this:

```
> add_connection()
Connection name: the_connection_you_choose
Driver constructor in R (e.g. RMariaDB::MariaDB()): RMariaDB::MariaDB()
Username: colinfraser
Password (set to "ask" to prompt for password each time): password123
Host: thehost.myserver.aws.internet.web
Database name: all_data
Path to ssl cert: ~/.ssl/ssl_certificate.pem
Do you wish to add more arguments? [y/n] n
```

additional arguments are optional additional arguments to the driver constructor that you're working with. If everything is set up properly, you now ought to be able to create a DBI connection with `con <- connect("the_nickname_you_choose")`.

Note that if you prefer, you can enter `ask` for the password, and then `connect("the_nickname_you_choose")` will prompt you for a password each time. Do this if you'd rather not have passwords stored in plain text anywhere on your machine. Otherwise, passwords will be stored in plain text in your .RDBIConnections file, but that's sure better than storing them in source code.
