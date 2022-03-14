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

# get needed objects
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper        = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $CommandObject = $Kernel::OM->Get('Kernel::System::Console::Command::Admin::FAQ::Import');

# test command without source argument
my $ExitCode = $CommandObject->Execute();

$Self->Is(
    $ExitCode,
    1,
    "Option - without source-path argument",
);

my $SourcePath = $Kernel::OM->Get('Kernel::Config')->Get('Home') . "/scripts/test/sample/FAQ.csv";

# test command with source argument
$ExitCode = $CommandObject->Execute( '--separator', ';', '--quote', '', $SourcePath );

$Self->Is(
    $ExitCode,
    0,
    "Option - with source argument",
);

# cleanup is done by restore database

1;
