# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2020 Rother OSS GmbH, https://otobo.de/
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

# Get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $FAQObject = $Kernel::OM->Get('Kernel::System::FAQ');

my $ItemID = $FAQObject->FAQAdd(
    Title       => 'Some Text',
    CategoryID  => 1,
    StateID     => 1,
    LanguageID  => 1,
    Keywords    => 'some keywords',
    Field1      => 'Problem...',
    Field2      => 'Solution...',
    ContentType => 'text/html',
    UserID      => 1,
);
$Self->True(
    $ItemID,
    'FAQAdd()',
);

my %FAQData = $FAQObject->FAQGet(
    ItemID     => $ItemID,
    ItemFields => 1,
    UserID     => 1,
);

# Build a test Dynamic field Config.
my $DynamicFieldConfig = {
    ID         => 123,
    FieldType  => 'Text',
    ObjectType => 'Ticket',
};

my @Tests = (
    {
        Name    => 'No Params',
        Config  => {},
        Request => "Action=someaction;Subaction=somesubaction;ItemID=$ItemID",
        Success => 0,
    },
    {
        Name   => 'Missing UserID',
        Config => {
            DynamicFieldConfig => $DynamicFieldConfig,
        },
        Request => "Action=someaction;Subaction=somesubaction;ItemID=$ItemID",
        Success => 0,
    },
    {
        Name   => 'Missing DynamicFieldConfig',
        Config => {
            UserID => 1,
        },
        Request => "Action=someaction;Subaction=somesubaction;ItemID=$ItemID",
        Success => 0,
    },
    {
        Name   => 'Missing FAQID in the request',
        Config => {
            DynamicFieldConfig => $DynamicFieldConfig,
            UserID             => 1,
        },
        Request => "Action=someaction;Subaction=somesubaction;",
        Success => 0,
    },
    {
        Name   => 'Wrong FAQID in the request',
        Config => {
            DynamicFieldConfig => $DynamicFieldConfig,
            UserID             => 1,
        },
        Request       => "Action=someaction;Subaction=somesubaction;ItemID=-1",
        Success       => 1,
        ExectedResult => {
            ObjectID => -1,
            Data     => {},
        },
    },
    {
        Name   => 'Correct FAQ',
        Config => {
            DynamicFieldConfig => $DynamicFieldConfig,
            UserID             => 1,
        },
        Request       => "Action=someaction;Subaction=somesubaction;ItemID=$ItemID",
        Success       => 1,
        ExectedResult => {
            ObjectID => $ItemID,
            Data     => \%FAQData,
        },
    },

);

my $ObjectHandlerObject = $Kernel::OM->Get('Kernel::System::DynamicField::ObjectType::FAQ');

TEST:
for my $Test (@Tests) {

    local %ENV = (
        REQUEST_METHOD => 'GET',
        QUERY_STRING   => $Test->{Request} // '',
    );

    CGI->initialize_globals();
    my $Request = Kernel::System::Web::Request->new();

    my %ObjectData = $ObjectHandlerObject->ObjectDataGet( %{ $Test->{Config} } );

    if ( !$Test->{Success} ) {
        $Self->IsDeeply(
            \%ObjectData,
            {},
            "$Test->{Name} - ObjectDataGet() unsuccessful",
        );
        next TEST;
    }

    $Self->IsDeeply(
        \%ObjectData,
        $Test->{ExectedResult},
        "$Test->{Name} ObjectDataGet()",
    );
}
continue {
    $Kernel::OM->ObjectsDiscard(
        Objects => [ 'Kernel::System::Web::Request', ],
    );
}

# cleanup is done by RestoreDatabase

1;
