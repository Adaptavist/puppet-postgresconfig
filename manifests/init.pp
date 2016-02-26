class postgresconfig (
    $listen_address    = $postgresconfig::params::listen_address,
    $listen_port       = $postgresconfig::params::listen_port,
    $config_enties     = $postgresconfig::params::config_enties,
    $hba_rules         = $postgresconfig::params::hba_rules,
    $install_contrib   = $postgresconfig::params::install_contrib,
    $contrib_package   = $postgresconfig::params::contrib_package,
    $install_devel     = $postgresconfig::params::install_devel,
    $devel_package     = $postgresconfig::params::devel_package,
    $postgres_password = $postgresconfig::params::postgres_password,
    $create_auth_file  = $postgresconfig::params::create_auth_file,
    $auth_file         = $postgresconfig::params::auth_file,
    $auth_file_owner   = $postgresconfig::params::auth_file_owner,
    $auth_file_group   = $postgresconfig::params::auth_file_group,
    $roles             = $postgresconfig::params::roles,
    ) inherits postgresconfig::params {

    $use_default_hba_rules = $hba_rules ? {
        undef => true,
        default => false,
    }

    if ($postgres_password == 'false' or $postgres_password == false){
        $real_postgres_password = undef
    } else {
        $real_postgres_password = $postgres_password
        # create a pgpass file if requested to do so
        if (str2bool($create_auth_file)) {
            file { $auth_file:
                ensure  => 'present',
                content => template("${name}/pgpass.erb"),
                owner   => $auth_file_owner,
                group   => $auth_file_group,
                mode    => '0600',
            }
        # if not ensure its not there
        } else {
            file { $auth_file:
                ensure  => 'absent'
            }
        }
    }

    # install/configure postgres
    class { 'postgresql::server':
        listen_addresses     => $listen_address,
        port                 => $listen_port,
        pg_hba_conf_defaults => $use_default_hba_rules,
        postgres_password    => $real_postgres_password,
    }

    # if there are configuration options, call the define to set them
    if ($config_enties != 'false' or $config_enties != false ) {
        validate_hash($config_enties)
        create_resources(postgresql::server::config_entry, $config_enties)
    }

    # if there are some hba rules, call define to set them (this will be used instead of the defaults set in the postgresql module)
    if ($hba_rules != 'false' and $hba_rules) {
        validate_hash($hba_rules)
        create_resources(postgresconfig::hba_rule, $hba_rules)
    }

    # if the contrib pacakge (that includes pg_archivecleanup) is required, install it after installing the server
    if (str2bool($install_contrib)) {
        package {$contrib_package:
            ensure  => 'present',
            require => Package[$postgresql::server::package_name]
        }
    }

    # if the development pacakge is required, install it after installing the server
    if (str2bool($install_devel)) {
        package {$devel_package:
            ensure  => 'present',
            require => Package[$postgresql::server::package_name]
        }
    }

    # if any roles have been provided creaet them
    if ($roles) {
        validate_hash($roles)
        create_resources(postgresconfig::role, $roles)
    }
}