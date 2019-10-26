#!/usr/bin/perl

use strict;
use warnings;

use Data::Compare;
use SQL::Parser;
use Test::Exception;
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

# This test uses session which checks the correct SQL is executed
# Set raise error on the db connect and wrap the sub call in lives ok, if the session doesn't match the actual it will error
# For some reason the UPDATE was written between qq|s so we use SQL parserd to make sure it's equivalent to it written in 1 line
subtest 'BAD PASSWORD' => sub {
	my $user_id = 1;
	my $username = 'Minnie';
	my $password = 'Mouse';

	my $dbh = DBI->connect('DBI:Mock:', '', '', { RaiseError => 1, PrintError => 0 }) || die "Cannot create handle: $DBI::errstr\n";

	my $bad_password = DBD::Mock::Session->new(
		'bad_password' => (
			{ statement => qr/SELECT user_id FROM users WHERE username = \'$username\' AND password = \'$password\'/, results => [['user_id'], [undef]] },
			{ statement => qr/SELECT user_id, login_failures FROM users WHERE username = \'$username\'/, results => [['user_id', 'login_failures'], [$user_id, 0]] },
			{
				statement => sub {
					my $parser1 = SQL::Parser->new('ANSI');
					$parser1->parse(shift(@_));
					my $parsed_statement1 = $parser1->structure();
					delete $parsed_statement1->{original_string};

					my $parser2 = SQL::Parser->new('ANSI');
					$parser2->parse("UPDATE users SET login_failures = (login_failures + 1) WHERE user_id = $user_id");
					my $parsed_statement2 = $parser2->structure();
					delete $parsed_statement2->{original_string};

					return Compare($parsed_statement2, $parsed_statement1);
				},
				results => [['rows'], []]
			}
		)
	);

	$dbh->{mock_session} = $bad_password;

	my $result;
	lives_ok {
		$result = MyApp::Login::login($dbh, $username, $password);
	}
	'... our session ran smoothly';

	is($result, 'BAD PASSWORD', '... username is found, but the password is wrong');
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
