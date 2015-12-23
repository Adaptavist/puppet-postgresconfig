
# PostgresConfig Module

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

## Example Usage:
 
    postgresconfig::listen_address: '127.0.0.1'
    postgresconfig::listen_port: '5432'
    postgresconfig::install_contrib: true
    postgresconfig::install_devel: true
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

## Dependencies

This module depends on the following puppet modules:

* Postgresql
