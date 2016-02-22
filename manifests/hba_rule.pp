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

    if ($auth_option == false) or ($auth_option == 'false') {
        $real_auth_option = undef
    } else {
        $real_auth_option = $auth_option
    }

    if ($address == false) or ($address == 'false') {
        $real_address = undef
    } else {
        $real_address = $address
    }

    postgresql::server::pg_hba_rule { $description:
        type        => $type,
        auth_method => $auth_method,
        auth_option => $real_auth_option,
        order       => $order,
        user        => $user,
        database    => $database,
        address     => $real_address,
    }
}

