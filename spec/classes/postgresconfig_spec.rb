require 'spec_helper'

listen_address = "127.0.0.1"
listen_port = "5432"
postgres_password = 'password'
describe 'postgresconfig', :type => 'class' do
	# facts needed by postgresql, taken puppet-postgresql spec tests
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

end