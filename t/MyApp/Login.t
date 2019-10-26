#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use MyApp::Login;

# This test is as simple as you can get
# Seed the result data for the select
# You should also seed the result data for the INSERT statement
# Only 1 row affected so the result set is a single empty array
subtest 'LOGIN SUCCESSFUL' => sub {
	my $user_id = 1;
	my $username = 'Mickey';
	my $password = 'Mouse';

	my $dbh = DBI->connect('DBI:Mock:', '', '') || die "Cannot create handle: $DBI::errstr\n";

	$dbh->{mock_add_resultset} = [['user_id'], [$user_id]];
	$dbh->{mock_add_resultset} = [['rows'], [],];

	my $result = MyApp::Login::login($dbh, $username, $password);

	is($result, 'LOGIN SUCCESSFUL', '... logged in successfully');

	my $history = $dbh->{mock_all_history};

	is(scalar(@{$history}), 2, '... 2 statements executed');

	my $login_st = $history->[0];
	is($login_st->statement, "SELECT user_id FROM users WHERE username = '$username' AND password = '$password'", '... password check statement correct');

	my $event_st = $history->[1];
	is($event_st->statement, "INSERT INTO event_log (event) VALUES('User $user_id logged in')", '... event statement correct');
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
