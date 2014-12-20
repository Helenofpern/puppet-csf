class csf(
	$manage_config = true,
	$ipv6 = 1,
) {
	# Install and configure CSF as required
	include csf::install
	include csf::config
	
	# This controls CSF restarts - keep in mind that this will also enable it.
	exec { 'csf-reload':
		command => '/usr/sbin/csf -e; /usr/sbin/csf -r',
		refreshonly => true,
		onlyif => 'test -f /etc/csf/csf.conf',
	}

	# This is a just an 'in case it does not work' scenario, if CSF blocks port 
	# 8140, make sure it stays open
	exec { 'csf-open-puppet':
		command => 'iptables -I OUTPUT -p tcp --dport 8140 -j ACCEPT',
		unless => 'iptables -L OUTPUT -n | grep "8140"',
	}
	
	# Set up a header for /etc/csf/csfpost.sh so people do not make changes to it
	concat::fragment { 'csf-post-header':
		target	=> '/etc/csf/csfpost.sh',
		content	=> template('csf/csf_header.rb'),
		order	=> '00',
	}
	
	# Set up a header for /etc/csf/csfpre.sh so people do not make changes to it
	concat::fragment { 'csf-pre-header':
		target	=> '/etc/csf/csfpre.sh',
		content	=> template('csf/csf_header.rb'),
		order	=> '00',
	}
	
	# Create /etc/csf/csfpost.sh, only when it's installed
	concat { '/etc/csf/csfpost.sh':
		ensure			=> present,
		ensure_newline 	=> true,
		mode			=> 711,
		force			=> true,
		require			=> Exec['csf-install'],
		notify			=> Exec['csf-reload'],
	}
	
	# Create /etc/csf/csfpre.sh, only when it's installed
	concat { '/etc/csf/csfpre.sh':
		ensure			=> present,
		ensure_newline 	=> true,
		mode			=> 711,
		force			=> true,
		require			=> Exec['csf-install'],
		notify			=> Exec['csf-reload'],
	}
	
}