define postgresconfig::hba_rule (
    $type,
    $auth_method,
    $order,
    $description,
    $auth_option = undef,
    $user        = 'all',
    $database    = 'all',
    $address     = undef,
    ) {

    postgresql::server::pg_hba_rule { $description:
        type        => $type,
        auth_method => $auth_method,
        auth_option => $auth_option,
        order       => $order,
        user        => $user,
        database    => $database,
        address     => $address,
    }
}

