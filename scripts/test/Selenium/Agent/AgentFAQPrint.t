# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2022 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

use v5.24;
use strict;
use warnings;
use utf8;

# core modules

# CPAN modules

# OTOBO modules
use Kernel::System::UnitTest::RegisterDriver;    # Set up $Self and $Kernel::OM
use Kernel::System::UnitTest::Selenium;

our $Self;

# get selenium object
my $Selenium = Kernel::System::UnitTest::Selenium->new( LogExecuteCommandActive => 1 );

if ( !$Selenium->{browser_name} || $Selenium->{browser_name} ne 'firefox' ) {
    $Self->True(
        1,
        'PDF test currently supports Firefox only, skipping test'
    );
}
else {
    $Selenium->RunTest(
        sub {

            # get helper object
            my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

            # get FAQ object
            my $FAQObject = $Kernel::OM->Get('Kernel::System::FAQ');

            # create test FAQ
            # test params
            my $FAQTitle    = 'FAQ ' . $Helper->GetRandomID();
            my $FAQSymptom  = 'Selenium Symptom';
            my $FAQProblem  = 'Selenium Problem';
            my $FAQSolution = 'Selenium Solution';
            my $FAQComment  = 'Selenium Comment';

            my $ItemID = $FAQObject->FAQAdd(
                Title       => $FAQTitle,
                CategoryID  => 1,
                StateID     => 1,
                LanguageID  => 1,
                Keywords    => 'some keywords',
                Field1      => $FAQSymptom,
                Field2      => $FAQProblem,
                Field3      => $FAQSolution,
                Field6      => $FAQComment,
                ValidID     => 1,
                UserID      => 1,
                ContentType => 'text/html',
            );

            $Self->True(
                $ItemID,
                "FAQ item is created - ID $ItemID",
            );

            # create test user and login
            my $TestUserLogin = $Helper->TestUserCreate(
                Groups => [ 'admin', 'users' ],
            ) || die "Did not get test user";

            $Selenium->Login(
                Type     => 'Agent',
                User     => $TestUserLogin,
                Password => $TestUserLogin,
            );

            # get script alias
            my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

            # navigate to AgentFAQPrint screen of created test FAQ
            $Selenium->get("${ScriptAlias}index.pl?Action=AgentFAQPrint;ItemID=$ItemID");

            # wait until print screen is loaded
            ACTIVESLEEP:
            for my $Second ( 1 .. 20 ) {
                if ( index( $Selenium->get_page_source(), $FAQComment ) > -1, ) {
                    last ACTIVESLEEP;
                }
                sleep 1;
            }

            my @Tests = (
                {
                    FAQData => $FAQSymptom,
                },
                {
                    FAQData => $FAQProblem,
                },
                {
                    FAQData => $FAQSolution,
                },
                {
                    FAQData => $FAQComment,
                },

            );
            for my $Test (@Tests) {
                $Self->True(
                    index( $Selenium->get_page_source(), $Test->{FAQData} ) > -1,
                    "$Test->{FAQData} is found on print screen",
                );
            }

            my $Success = $FAQObject->FAQDelete(
                ItemID => $ItemID,
                UserID => 1,
            );
            $Self->True(
                $Success,
                "FAQ item is deleted - ID $ItemID",
            );

            # make sure the cache is correct
            $Kernel::OM->Get('Kernel::System::Cache')->CleanUp( Type => "FAQ" );

        }

    );
}

$Self->DoneTesting();
