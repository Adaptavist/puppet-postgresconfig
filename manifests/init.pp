class postgresconfig (
    $listen_address       = $postgresconfig::params::listen_address,
    $listen_port          = $postgresconfig::params::listen_port,
    $config_enties        = $postgresconfig::params::config_enties,
    $hba_rules            = $postgresconfig::params::hba_rules,
    $install_contrib      = $postgresconfig::params::install_contrib,
    $contrib_package      = $postgresconfig::params::contrib_package,
    $install_devel        = $postgresconfig::params::install_devel,
    $devel_package        = $postgresconfig::params::devel_package,
    $postgres_password    = $postgresconfig::params::postgres_password,
    $create_auth_file     = $postgresconfig::params::create_auth_file,
    $auth_file            = $postgresconfig::params::auth_file,
    $auth_file_owner      = $postgresconfig::params::auth_file_owner,
    $auth_file_group      = $postgresconfig::params::auth_file_group,
    $roles                = $postgresconfig::params::roles,
    $selinux_context      = $postgresconfig::params::selinux_context,
    $semanage_package     = $postgresconfig::params::semanage_package,
    $datadir              = $postgresconfig::params::datadir,
    $backupdir            = $postgresconfig::params::backupdir,
    $manage_recovery_conf = $postgresconfig::params::manage_recovery_conf,
    $recovery_params      = $postgresconfig::params::recovery_params,
    ) inherits postgresconfig::params {

    $use_default_hba_rules = $hba_rules ? {
        undef => true,
        'false' => true,
        false => true,
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
        manage_recovery_conf => str2bool($manage_recovery_conf)
    }

    if ($datadir == 'false' or $datadir == false){
        $real_datadir = $postgresql::server::datadir
    } else {
        $real_datadir = $datadir
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

    # if any roles have been provided create them
    if ($roles) {
        validate_hash($roles)
        create_resources(postgresconfig::role, $roles)
    }

    if (str2bool($manage_recovery_conf)){
        validate_hash($recovery_params)
        create_resources(postgresql::server::recovery, $recovery_params)
    }

    # if selinux is enabled set the correct context on the datadir
    if str2bool($::selinux) {
        if ! defined(Package[$semanage_package]) {
            ensure_packages([$semanage_package])
        }

        exec { 'postgres_datadir_selinux':
            command => "semanage fcontext -a -t ${selinux_context} \"${real_datadir}(/.*)?\" && restorecon -R -v ${real_datadir}",
            require => Package[$semanage_package]
        }

        if ($backupdir and $backupdir != 'false' and $backupdir != false) {
            exec { 'postgres_backupdir_selinux':
                command => "semanage fcontext -a -t ${selinux_context} \"${backupdir}(/.*)?\" && restorecon -R -v ${backupdir}",
                require => Package[$semanage_package]
            }
        }
    }
}
