# PostgresConfig Module
[![Build Status](https://travis-ci.org/Adaptavist/puppet-postgresconfig.svg?branch=master)](https://travis-ci.org/Adaptavist/puppet-postgresconfig)
## Overview

The **PostgresConfig** module installs and configures a postgres database on any node where it has been included and at least a trivial database configuration exists in Hiera.

## Configuration

`postgresconfig::postgres_password:`

Sets postgres user db password, if "false" provided password will not be set, default "false"

`postgresconfig::listen_address:`

The address postgres will listen on for connections, defaults to '127.0.0.1'

`postgresconfig::listen_port:` 

The port postgres will listen on for connections, defaults to '5432'

`postgresconfig::config_enties:` 

A hash of configuration entries to be set in `postgresql.conf`, defaults to an empty hash

`postgresconfig::hba_rules:` 

A hash of accesss rules to be set in `pg_hba.conf`, defauts to undefined

`postgresconfig::install_contrib:`

A flag to determine if the contrib package (which contains, amoungst other things, pg_archivecleanup) should be installed, defaults to false

`postgresconfig::contrib_package:`

The name of the contrib package, this is set based on operating system family and should not usually be set manually

`postgresconfig::install_devel:`

A flag to determine if the development package should be installed, defaults to false

`postgresconfig::devel_package:`

The name of the development package, this is set based on operating system family and should not usually be set manually

`postgresconfig::create_auth_file:`

Flag to determine if a .pgpass file should be created, this flag is ignored if `postgres_password` is not set, defaults to false

`postgresconfig::auth_file:`

The location of the .pgpass file to create, defaults to '/root/.pgpass'

`postgresconfig::auth_file_owner:`

The owner of the .pgpass file, defaults to 'root'

`postgresconfig::auth_file_group:`

The group of the .pgpass file, defaults to 'root'

`postgresconfig::roles`

A hash of postgres roles to create

`postgresconfig::selinux_context`

The selinux context to apply to postgres's data dir and backup dir (if specified), defaults to postgresql_db_t

`postgresconfig::semanage_package`

The package that contains semanage, the utility to manage selinux contexts, defaults to policycoreutils-python on RedHat based systems and policycoreutils on Debian based systems

`postgresconfig::datadir`

The PostgreSQL data dir, if not set or set to false its inherited from the main postgres module, if the system has selinux enabled then this directory will have a selinux context of `selinux_context` set, defaults to false (meaning it'll be inherited from postgres module)

`postgresconfig::backupdir`

A backup directory, if set with a value other than false this directory will also have a selinux context of `selinux_context` set, usefull if postgres is achiving WAL's to a local folder, defaults to false

`postgresconfig::manage_recovery_conf`

Flag to determine if we are managing recoery params (used in creating PostgreSQL replicaiton slave), defaults to false

`postgresconfig::recovery_params`

Hsh of recovery parameters, defaults to empty hash

## Example Usage:
 
    postgresconfig::listen_address: '127.0.0.1'
    postgresconfig::listen_port: '5432'
    postgresconfig::install_contrib: true
    postgresconfig::install_devel: true
    postgresconfig::postgres_password: 'super-secret-password'
    postgresconfig::create_auth_file: true
    postgresconfig::config_enties:
        max_connections:
            value: '200'
        shared_buffers:
            value: '512MB'
    postgresconfig::hba_rules:
        001:
            type: 'local'
            user: 'postgres'
            auth_method: 'ident'
            order: '001'
            description: 'local access as postgres user'
        002:
            type: 'local'
            auth_method: 'md5'
            order: '002'
            description: 'local access to database with same name'
    postgresconfig::roles:
        'user1':
            password: "either plain text password or postgres password hash"
            createdb: "false"
            createrole: "false"
            login: "true"
            inherit: "true"
            superuser: "false"
            replication: "false"

## Dependencies

This module depends on the following puppet modules:

* Postgresql

