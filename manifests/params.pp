class postgresconfig::params {
    include postgresql::globals
    $listen_address    = '127.0.0.1'
    $listen_port       = '5432'
    $config_enties     = {}
    $hba_rules         = 'false'
    $install_contrib   = 'false'
    $postgres_password = 'false'
    $contrib_package   = $::osfamily ? {
          'RedHat' => 'postgresql-contrib',
          'Debian' => "postgresql-contrib-${postgresql::globals::globals_version}"
    }
    $install_devel     = 'false'
    $devel_package     = $::osfamily ? {
          'RedHat' => 'postgresql-devel',
          'Debian' => "postgresql-server-dev-${postgresql::globals::globals_version}"
    }
    $create_auth_file = 'false'
    $auth_file = '/root/.pgpass'
    $auth_file_owner = 'root'
    $auth_file_group = 'root'
    $roles = {}
    $selinux_context = 'postgresql_db_t'
    $semanage_package = $::osfamily ? {
        'RedHat' => 'policycoreutils-python',
        'Debian' => 'policycoreutils',
    }
    $datadir = 'false'
    $backupdir = 'false'
    $manage_recovery_conf = 'false'
    $recovery_params = {}
    $pgpass_postgres_user = 'postgres'
    $pgpass_postgres_pass = 'false'
    $archive_alternatives_install = 'false'
}

