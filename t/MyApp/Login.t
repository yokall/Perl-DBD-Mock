#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use MyApp::Login;

subtest 'LOGIN SUCCESSFUL' => sub {
	TODO: {
		todo_skip 'Mock::DBD not used yet', 1;

		my $dbh = undef;
		my $username = 'Mickey';
		my $password = 'Mouse';

		my $result = MyApp::Login::login($dbh, $username, $password);

		is($result, 'LOGIN SUCCESSFUL', 'Successful login');
	}
};

subtest 'BAD PASSWORD' => sub {
	TODO: {
		todo_skip 'Mock::DBD not used yet', 1;

		my $dbh = undef;
		my $username = 'Mickey';
		my $password = 'Mouse';

		my $result = MyApp::Login::login($dbh, $username, $password);

		is($result, 'BAD PASSWORD', 'Failed login, bad password');
	}
};

subtest 'USER ACCOUNT LOCKED' => sub {
	TODO: {
		todo_skip 'Mock::DBD not used yet', 1;

		my $dbh = undef;
		my $username = 'Mickey';
		my $password = 'Mouse';

		my $result = MyApp::Login::login($dbh, $username, $password);

		is($result, 'USER ACCOUNT LOCKED', 'Failed login, account locked');
	}
};

subtest 'USERNAME NOT FOUND' => sub {
	TODO: {
		todo_skip 'Mock::DBD not used yet', 1;

		my $dbh = undef;
		my $username = 'Mickey';
		my $password = 'Mouse';

		my $result = MyApp::Login::login($dbh, $username, $password);

		is($result, 'USERNAME NOT FOUND', 'Username not found');
	}
};

done_testing();
