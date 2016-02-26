define postgresconfig::role (
    $password,
    $createdb    = false,
    $createrole  = false,
    $login       = true,
    $inherit     = true,
    $superuser   = false,
    $replication = false,
    )  {

    postgresql::server::role { $title:
        password_hash => $password,
        createdb      => str2bool($createdb),
        createrole    => str2bool($createrole),
        login         => str2bool($login),
        inherit       => str2bool($inherit),
        superuser     => str2bool($superuser),
        replication   => str2bool($replication),
    }

}

