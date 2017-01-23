require 'spec_helper'

listen_address = "127.0.0.1"
listen_port = "5432"
postgres_password = 'password'
pgpass_postgres_user = 'fred'
pgpass_postgres_password = 'password77'
auth_file = '/etc/my_auth_file'
auth_file_owner = 'postgres'
auth_file_group = 'postgres'

hba_rules = { '001' => {
       'type'        => 'local',
       'auth_method' => 'ident',
       'order'       => '001',
       'description' => 'local access as postgres user',
       'auth_option' => 'false',
       'user'        => 'all',
       'database'    => 'all',
       'address'     => 'false'  }
}

roles = { 'repl' => {
       'password'    => 'super_secret',
       'createdb'    => 'false',
       'createrole'  => 'false',
       'login'       => 'true',
       'inherit'     => 'true',
       'superuser'   => 'false',
       'replication' => 'true'  }
}

describe 'postgresconfig', :type => 'class' do
	# facts needed by postgresql, taken from puppet-postgresql spec tests
    let :facts do 
    	{
            :osfamily => 'Debian',
            :operatingsystem => 'Debian',
            :operatingsystemrelease => '6.0',
            :concat_basedir => '/tmp',
            :kernel => 'Linux',
            :id => 'root',
            :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        }
    end

  context "Should run postgres server with parameters" do
  	let(:params) { 
  		{ 
  		    :listen_address => listen_address,
  		    :listen_port => listen_port
  		} 
  	}

  	it {
  		should contain_class('postgresql::server').with(
  			'listen_addresses' => listen_address,
  			'port' => listen_port,
        'postgres_password'  => nil
  		)
  	}
  end

  context "Should run postgres server with password set" do
    let(:params) { 
      { 
          :listen_address => listen_address,
          :listen_port => listen_port,
          :postgres_password => postgres_password,
      } 
    }

    it {
      should contain_class('postgresql::server').with(
        'listen_addresses' => listen_address,
        'port' => listen_port,
        'postgres_password'  => postgres_password
      )
    }
  end

  context "Should create pgpass file, fall back to dba password if custom pgpass it not set" do
    let(:params) { 
      { 
          :listen_address => listen_address,
          :listen_port => listen_port,
          :postgres_password => postgres_password,
          :create_auth_file => true,
          :auth_file => auth_file,
          :auth_file_owner => auth_file_owner,
          :auth_file_group => auth_file_owner,
          :pgpass_postgres_user => pgpass_postgres_user,
      } 
    }

    it {
      should contain_class('postgresql::server').with(
        'listen_addresses' => listen_address,
        'port' => listen_port,
        'postgres_password'  => postgres_password
      )
      should contain_file(auth_file).with(
          'ensure' => 'present',
          'owner'  => auth_file_owner,
          'group'  => auth_file_group,
          'mode'   => '0600'
      )
      pgpass_test = catalogue().resource('file', auth_file).send(:parameters)[:content]
      expect("*:*:*:#{pgpass_postgres_user}:#{postgres_password}").to eq(pgpass_test)
    }
  end

  context "Should create pgpass file with custom pgpass password" do
    let(:params) { 
      { 
          :listen_address => listen_address,
          :listen_port => listen_port,
          :postgres_password => postgres_password,
          :create_auth_file => true,
          :auth_file => auth_file,
          :auth_file_owner => auth_file_owner,
          :auth_file_group => auth_file_owner,
          :pgpass_postgres_user => pgpass_postgres_user,
          :pgpass_postgres_pass => pgpass_postgres_password,
      } 
    }

    it {
      should contain_class('postgresql::server').with(
        'listen_addresses' => listen_address,
        'port' => listen_port,
        'postgres_password'  => postgres_password
      )
      should contain_file(auth_file).with(
          'ensure' => 'present',
          'owner'  => auth_file_owner,
          'group'  => auth_file_group,
          'mode'   => '0600'
      )
      pgpass_test = catalogue().resource('file', auth_file).send(:parameters)[:content]
      expect("*:*:*:#{pgpass_postgres_user}:#{pgpass_postgres_password}").to eq(pgpass_test)
    }
  end

  context "Should ensure pgpass file is not present" do
    let(:params) { 
      { 
          :listen_address => listen_address,
          :listen_port => listen_port,
          :postgres_password => postgres_password,
          :create_auth_file => false,
          :auth_file => auth_file,
          :auth_file_owner => auth_file_owner,
          :auth_file_group => auth_file_owner,
      } 
    }

    it {
      should contain_class('postgresql::server').with(
        'listen_addresses' => listen_address,
        'port' => listen_port,
        'postgres_password'  => postgres_password
      )
      should contain_file(auth_file).with(
          'ensure' => 'absent'
      )
    }
  end

  context "Should not create pgpass file if password is not set" do
    let(:params) { 
      { 
          :listen_address => listen_address,
          :listen_port => listen_port,
          :postgres_password => 'false',
          :create_auth_file => true,
          :auth_file => auth_file,
          :auth_file_owner => auth_file_owner,
          :auth_file_group => auth_file_owner,
      } 
    }

    it {
      should contain_class('postgresql::server').with(
        'listen_addresses' => listen_address,
        'port' => listen_port,
        'postgres_password'  => nil
      )
      should_not contain_file(auth_file)
    }
  end

  context "Should create hba_rule with address and auth_option undef" do
    let(:params) { 
      { 
          :listen_address => listen_address,
          :listen_port => listen_port,
          :hba_rules => hba_rules,
      } 
    }

    it {
      should contain_postgresql__server__pg_hba_rule('local access as postgres user').with(
        'type'        => 'local',
        'auth_method' => 'ident',
        'auth_option' => nil,
        'order'       => '001',
        'user'        => 'all',
        'database'    => 'all',
        'address'     => nil,
      )
    }
  end

  context "Should create user repl with replication privileges" do
    let(:params) { 
      { 
          :listen_address => listen_address,
          :listen_port => listen_port,
          :hba_rules => hba_rules,
          :roles => roles,
      } 
    }

    it {
      should contain_postgresql__server__role('repl').with(
       'password_hash' => 'super_secret',
       'createdb'      => 'false',
       'createrole'    => 'false',
       'login'         => 'true',
       'inherit'       => 'true',
       'superuser'     => 'false',
       'replication'   => 'true'  
      )
    }
  end

end