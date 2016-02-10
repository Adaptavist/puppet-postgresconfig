require 'spec_helper'

listen_address = "127.0.0.1"
listen_port = "5432"
postgres_password = 'password'
auth_file = '/etc/my_auth_file'
auth_file_owner = 'postgres'
auth_file_group = 'postgres'

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

  context "Should create pgpass file if password is set" do
    let(:params) { 
      { 
          :listen_address => listen_address,
          :listen_port => listen_port,
          :postgres_password => postgres_password,
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
        'postgres_password'  => postgres_password
      )
      should contain_file(auth_file).with(
          'ensure' => 'present',
          'owner'  => auth_file_owner,
          'group'  => auth_file_group,
          'mode'   => '0600'
      )
      pgpass_test = catalogue().resource('file', auth_file).send(:parameters)[:content]
      expect("*:*:*:postgres:#{postgres_password}").to eq(pgpass_test)
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

end