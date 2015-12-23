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
}

