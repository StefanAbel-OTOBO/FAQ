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

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;
use utf8;

use vars (qw($Self));

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my @Tests = (
    {
        Name   => 'No array',
        Params => {
            TableColumn => 'test.table',
            IDRef       => 1,
        },
        Result => undef,
    },
    {
        Name   => 'Single Integer',
        Params => {
            TableColumn => 'test.table',
            IDRef       => [1],
        },
        Result => ' (  test.table IN (1)  ) ',
    },
    {
        Name   => 'Sorted values',
        Params => {
            TableColumn => 'test.table',
            IDRef       => [ 2, 1, -1, 0 ],
        },
        Result => ' (  test.table IN (-1, 0, 1, 2)  ) ',
    },
    {
        Name   => 'Invalid value',
        Params => {
            TableColumn => 'test.table',
            IDRef       => [1.1],
        },
        Result => undef,
    },
    {
        Name   => 'Mix of valid and invalid values',
        Params => {
            TableColumn => 'test.table',
            IDRef       => [ 1, 1.1 ],
        },
        Result => undef,
    },
);

# get FAQ object
my $FAQObject = $Kernel::OM->Get('Kernel::System::FAQ');

for my $Test (@Tests) {
    $Self->Is(
        scalar $FAQObject->_InConditionGet( %{ $Test->{Params} } ),
        $Test->{Result},
        "$Test->{Name} _InConditionGet()"
    );
}

# cleanup is done by RestoreDatabase.

1;
