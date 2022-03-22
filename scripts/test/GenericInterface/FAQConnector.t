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
use Socket;
use MIME::Base64;

# CPAN modules
use YAML;
use Test2::V0;

# OTOBO modules
use Kernel::System::UnitTest::RegisterDriver;    # Set up $Kernel::OM
use Kernel::GenericInterface::Debugger;
use Kernel::GenericInterface::Operation::FAQ::LanguageList;
use Kernel::GenericInterface::Operation::FAQ::PublicCategoryList;
use Kernel::GenericInterface::Operation::FAQ::PublicFAQSearch;
use Kernel::GenericInterface::Operation::FAQ::PublicFAQGet;

# get helper object
my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $RandomID = $HelperObject->GetRandomID();

# set web-service name
my $WebserviceName = '-Test-' . $HelperObject->GetRandomID();

# set UserID on 1
my $UserID = 1;

# get helper object
my $FAQObject = $Kernel::OM->Get('Kernel::System::FAQ');

# get public states
my %States = $FAQObject->StateList(
    UserID => $UserID,
);
my $PublicStateID;
for my $Key ( sort keys %States ) {
    if ( $States{$Key} =~ /^public.*/ ) {
        $PublicStateID = $Key;
    }
}

ok( defined $PublicStateID, "Search for public StateID" );

# category one
my $CategoryIDOne = $FAQObject->CategoryAdd(
    Name     => 'ConnectorCategoryOne' . $WebserviceName,
    Comment  => 'Category for testing',
    ParentID => 0,
    ValidID  => 1,
    UserID   => $UserID,
);

ok(
    $CategoryIDOne,
    "CategoryAdd() - Category",
);

# category two
my $CategoryIDTwo = $FAQObject->CategoryAdd(
    Name     => 'ConnectorCategoryTwo' . $WebserviceName,
    Comment  => 'Child Category for testing',
    ParentID => $CategoryIDOne,
    ValidID  => 1,
    UserID   => $UserID,
);

ok(
    $CategoryIDTwo,
    "CategoryAdd() - Child Category",
);

# category three
my $CategoryIDThree = $FAQObject->CategoryAdd(
    Name     => '!"§$%&/()=?Ü*ÄÖL:L@,.-' . $WebserviceName,
    Comment  => 'Child Category for testing',
    ParentID => $CategoryIDTwo,
    ValidID  => 1,
    UserID   => $UserID,
);

ok(
    $CategoryIDThree,
    "CategoryAdd() - Child Category",
);

# category four
my $CategoryIDFour = $FAQObject->CategoryAdd(
    Name     => 'ConnectorCategoryFour' . $WebserviceName,
    Comment  => 'Category for testing',
    ParentID => 0,
    ValidID  => 1,
    UserID   => $UserID,
);

ok(
    $CategoryIDFour,
    "CategoryAdd() - Child Category",
);

my $ItemIDOne = $FAQObject->FAQAdd(
    Title       => 'Title FAQ ' . $RandomID . 'One' . $WebserviceName,
    CategoryID  => $CategoryIDOne,
    StateID     => $PublicStateID,
    LanguageID  => 1,
    Keywords    => 'some keywords',
    Field1      => 'Problem...',
    Field2      => 'Solution...',
    UserID      => $UserID,
    ContentType => 'text/html',
    Approved    => 1,
);

ok(
    $ItemIDOne,
    "FAQAdd() - FAQ One",
);

my $ItemIDTwo = $FAQObject->FAQAdd(
    Title       => 'Title FAQ ' . $RandomID . ' Two' . $WebserviceName,
    CategoryID  => $CategoryIDThree,
    StateID     => $PublicStateID,
    LanguageID  => 1,
    Keywords    => '',
    Field1      => 'Problem Description 1...',
    Field2      => 'Solution not found1...',
    UserID      => $UserID,
    ContentType => 'text/plain',
    Approved    => 1,
);

ok(
    $ItemIDTwo,
    "FAQAdd() - FAQ Two",
);

my $ItemIDThree = $FAQObject->FAQAdd(
    Title       => 'Title 使用下列语言 Three' . $WebserviceName,
    CategoryID  => $CategoryIDFour,
    StateID     => $PublicStateID,
    LanguageID  => 1,
    Keywords    => '',
    Field1      => 'Look for me ' . $RandomID . ' on the search',
    Field2      => 'Solution not found1...',
    UserID      => $UserID,
    ContentType => 'text/html',
    Approved    => 1,
);

ok(
    $ItemIDThree,
    "FAQAdd() - FAQ Three",
);

# get common objects
my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');

# file checks
for my $File (qw(bin txt)) {
    my $Location = $ConfigObject->Get('Home')
        . "/scripts/test/sample/GenericInterface/FAQ/GI-FAQ-Test-utf8-1.$File";

    my $ContentRef = $MainObject->FileRead(
        Location => $Location,
        Mode     => 'binmode',
    );

    my $Attachment = $FAQObject->AttachmentAdd(
        ItemID      => $ItemIDThree,
        Content     => ${$ContentRef},
        ContentType => 'test/' . $File,
        Filename    => 'test.' . $File,
        Inline      => 0,                 # (0|1, default 0)
        UserID      => $UserID,
    );
    ok(
        $Attachment,
        "AttachmentAdd() - File " . $File,
    );
}

my $ItemIDFour = $FAQObject->FAQAdd(
    Title       => 'Title FAQ ' . $RandomID . ' Языковые Four' . $WebserviceName,
    CategoryID  => $CategoryIDFour,
    StateID     => $PublicStateID,
    LanguageID  => 1,
    Keywords    => '',
    Field1      => 'Problem Description 1...',
    Field2      => 'Solution not found1...',
    UserID      => 1,
    ContentType => 'text/html',
    Approved    => 1,
);

ok(
    $ItemIDFour,
    "FAQAdd() - FAQ Four",
);

# get languages list
my %Languages = $FAQObject->LanguageList(
    UserID => 1,
);

my @LanguageList;
for my $Key ( sort keys %Languages ) {
    my %Language = (
        ID   => $Key,
        Name => $Languages{$Key},
    );
    push @LanguageList, {%Language};
}

# get FAQ
my %FAQOne = $FAQObject->FAQGet(
    ItemID     => $ItemIDOne,
    ItemFields => 1,
    UserID     => $UserID,
);
foreach my $Key ( keys %FAQOne ) {
    if ( !$FAQOne{$Key} ) {
        $FAQOne{$Key} = '';
    }
}

my %FAQTwo = $FAQObject->FAQGet(
    ItemID     => $ItemIDTwo,
    ItemFields => 1,
    UserID     => $UserID,
);
foreach my $Key ( keys %FAQTwo ) {
    if ( !$FAQTwo{$Key} ) {
        $FAQTwo{$Key} = '';
    }
}

my %FAQThree = $FAQObject->FAQGet(
    ItemID     => $ItemIDThree,
    ItemFields => 1,
    UserID     => $UserID,
);
foreach my $Key ( keys %FAQThree ) {
    if ( !$FAQThree{$Key} ) {
        $FAQThree{$Key} = '';
    }
}

my @Index = $FAQObject->AttachmentIndex(
    ItemID     => $ItemIDThree,
    ShowInline => 1,              #   ( 0|1, default 1)
    UserID     => $UserID,
);

my @AttachmentsThree;
for my $Attachment (@Index) {
    my %File = $FAQObject->AttachmentGet(
        ItemID => $ItemIDThree,
        FileID => $Attachment->{FileID},
        UserID => $UserID,
    );

    # convert content to base64
    $File{Content} = encode_base64( $File{Content} );
    $File{Inline}  = $Attachment->{Inline};
    $File{FileID}  = $Attachment->{FileID};

    push @AttachmentsThree, {%File};
}

my %FAQFour = $FAQObject->FAQGet(
    ItemID     => $ItemIDFour,
    ItemFields => 1,
    UserID     => $UserID,
);
foreach my $Key ( keys %FAQFour ) {
    if ( !$FAQFour{$Key} ) {
        $FAQFour{$Key} = '';
    }
}

# get all categories with their long names
my $CategoryTree = $FAQObject->GetPublicCategoriesLongNames(
    Valid  => 1,
    Type   => 'rw',
    UserID => $UserID,
);
my @PublicCategoryList;
for my $Key ( sort( keys %{$CategoryTree} ) ) {
    my %Category = (
        ID   => $Key,
        Name => $CategoryTree->{$Key},
    );
    push @PublicCategoryList, {%Category};
}

# create web-service object
my $WebserviceObject = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');
isa_ok(
    $WebserviceObject,
    ['Kernel::System::GenericInterface::Webservice'],
    "Create webservice object",
);

my $WebserviceID = $WebserviceObject->WebserviceAdd(
    Name   => $WebserviceName,
    Config => {
        Debugger => {
            DebugThreshold => 'debug',
            TestMode       => 1,
        },
        Provider => {
            Transport => {
                Type => 'HTTP::SOAP',
            },
        },
    },
    ValidID => 1,
    UserID  => 1,
);
ok( $WebserviceID, "Added Webservice" );

# get remote host with some precautions for certain unit test systems
my $Host = $HelperObject->GetTestHTTPHostname();

# use hard coded localhost IP address
if ( !$Host ) {
    $Host = '127.0.0.1';
}

# prepare web service config
my $RemoteSystem =
    $ConfigObject->Get('HttpType')
    . '://'
    . $Host
    . '/'
    . $ConfigObject->Get('ScriptAlias')    # has trailing slash
    . 'nph-genericinterface.pl/WebserviceID/'
    . $WebserviceID;

my $WebserviceConfig = {

    #    Name => '',
    Description =>
        'Test for  using SOAP transport backend.',
    Debugger => {
        DebugThreshold => 'debug',
        TestMode       => 1,
    },
    Provider => {
        Transport => {
            Type   => 'HTTP::SOAP',
            Config => {
                MaxLength => 10000000,
                NameSpace => 'http://otobo.org/SoapTestInterface/',
                Endpoint  => $RemoteSystem,
            },
        },
        Operation => {
            LanguageList => {
                Type => 'FAQ::LanguageList',
            },
            PublicCategoryList => {
                Type => 'FAQ::PublicCategoryList',
            },
            PublicFAQSearch => {
                Type => 'FAQ::PublicFAQSearch',
            },
            PublicFAQGet => {
                Type => 'FAQ::PublicFAQGet',
            },
        },
    },
    Requester => {
        Transport => {
            Type   => 'HTTP::SOAP',
            Config => {
                NameSpace => 'http://otobo.org/SoapTestInterface/',
                Encoding  => 'UTF-8',
                Endpoint  => $RemoteSystem,
            },
        },
        Invoker => {
            LanguageList => {
                Type => 'Test::TestSimple',
            },
            PublicCategoryList => {
                Type => 'Test::TestSimple',
            },
            PublicFAQSearch => {
                Type => 'Test::TestSimple',
            },
            PublicFAQGet => {
                Type => 'Test::TestSimple',
            },
        },
    },
};

# update webservice with real config
my $WebserviceUpdate = $WebserviceObject->WebserviceUpdate(
    ID      => $WebserviceID,
    Name    => $WebserviceName,
    Config  => $WebserviceConfig,
    ValidID => 1,
    UserID  => $UserID,
);
ok(
    $WebserviceUpdate,
    "Updated Webservice $WebserviceID - $WebserviceName",
);

my @Tests = (
    {
        Name                     => 'Test 1',
        SuccessRequest           => '1',
        RequestData              => {},
        ExpectedReturnRemoteData => {
            Data => {
                Language => \@LanguageList,
            },
            Success => 1,
        },
        Operation => 'LanguageList',
    },
    {
        Name                     => 'Test 2',
        SuccessRequest           => '1',
        RequestData              => {},
        ExpectedReturnRemoteData => {
            Success => 1,
            Data    => {
                Category => \@PublicCategoryList,
            },
        },
        Operation => 'PublicCategoryList',
    },
    {
        Name           => 'Test 3',
        SuccessRequest => '1',
        RequestData    => {
            Title   => 'Title FAQ ' . $RandomID,
            OrderBy => 'FAQID',
        },
        ExpectedReturnRemoteData => {
            Success => 1,
            Data    => {
                ID => [
                    $ItemIDFour,
                    $ItemIDTwo,
                    $ItemIDOne,
                ],
            },
        },
        Operation => 'PublicFAQSearch',
    },
    {
        Name           => 'Test 4',
        SuccessRequest => '1',
        RequestData    => {
            What    => 'Look for me ' . $RandomID,
            OrderBy => 'FAQID',
        },
        ExpectedReturnRemoteData => {
            Success => 1,
            Data    => {
                ID => $ItemIDThree,
            },
        },
        Operation => 'PublicFAQSearch',
    },
    {
        Name           => 'Test 5',
        SuccessRequest => '1',
        RequestData    => {
            ItemID => $ItemIDFour,
        },
        ExpectedReturnRemoteData => {
            Success => 1,
            Data    => {
                FAQItem => {
                    %FAQFour,
                },
            },
        },
        ExpectedReturnLocalData => {
            Success => 1,
            Data    => {
                FAQItem => [
                    {
                        %FAQFour
                    }
                ],
            },
        },
        Operation => 'PublicFAQGet',
        ItemID    => $ItemIDFour,
    },
    {
        Name           => 'Test 6',
        SuccessRequest => '1',
        RequestData    => {
            ID => $ItemIDFour,
        },
        ExpectedReturnRemoteData => {
            Data => {
                Error => {
                    ErrorCode    => 'PublicFAQGet.MissingParameter',
                    ErrorMessage => 'PublicFAQGet: Got no ItemID!'
                }
            },
            Success => 1

        },
        ExpectedReturnLocalData => {
            Data => {
                Error => {
                    ErrorCode    => 'PublicFAQGet.MissingParameter',
                    ErrorMessage => 'PublicFAQGet: Got no ItemID!'
                }
            },
            Success => 1

        },
        Operation => 'PublicFAQGet',
        ItemID    => $ItemIDFour,
    },
    {
        Name           => 'Test 7',
        SuccessRequest => '1',
        RequestData    => {
            ItemID => 'NotItemID',
        },
        ExpectedReturnRemoteData => {
            Data => {
                Error => {
                    ErrorCode    => 'PublicFAQGet.NotValidFAQID',
                    ErrorMessage =>
                        'PublicFAQGet: Could not get FAQ data in Kernel::GenericInterface::Operation::FAQ::PublicFAQGet::Run()'
                }
            },
            Success => 1

        },
        ExpectedReturnLocalData => {
            Data => {
                Error => {
                    ErrorCode    => 'PublicFAQGet.NotValidFAQID',
                    ErrorMessage =>
                        'PublicFAQGet: Could not get FAQ data in Kernel::GenericInterface::Operation::FAQ::PublicFAQGet::Run()'
                }
            },
            Success => 1

        },
        Operation => 'PublicFAQGet',
        ItemID    => 'NotItemID',
    },
    {
        Name           => 'Test 8',
        SuccessRequest => '1',
        RequestData    => {
            ItemID => $ItemIDThree,
        },
        ExpectedReturnRemoteData => {
            Success => 1,
            Data    => {
                FAQItem => {
                    %FAQThree,
                    Attachment => \@AttachmentsThree,
                },
            },
        },
        ExpectedReturnLocalData => {
            Success => 1,
            Data    => {
                FAQItem => [
                    {
                        Attachment => \@AttachmentsThree,
                        %FAQThree
                    },
                ],
            },
        },
        Operation => 'PublicFAQGet',
        ItemID    => $ItemIDThree,
    },
    {
        Name           => 'Test 9',
        SuccessRequest => '1',
        RequestData    => {
            OrderBy => 'NotExistingField',
        },
        ExpectedReturnRemoteData => {
            Data => {
                Error => {
                    ErrorCode    => 'PublicFAQSearch.NotFAQData',
                    ErrorMessage =>
                        'PublicFAQSearch: Could not get FAQ data in Kernel::GenericInterface::Operation::FAQ::PublicFAQSearch::Run()'
                }
            },
            Success => 1
        },
        ExpectedReturnLocalData => {
            Data => {
                Error => {
                    ErrorCode    => 'PublicFAQSearch.NotFAQData',
                    ErrorMessage =>
                        'PublicFAQSearch: Could not get FAQ data in Kernel::GenericInterface::Operation::FAQ::PublicFAQSearch::Run()'
                }
            },
            Success => 1
        },
        Operation => 'PublicFAQSearch',
    },
    {
        Name           => 'Test 10',
        SuccessRequest => '1',
        RequestData    => {
            What => 'NotExistingValue',
        },
        ExpectedReturnRemoteData => {
            Data => {
                Error => {
                    ErrorCode    => 'PublicFAQSearch.NotFAQData',
                    ErrorMessage =>
                        'PublicFAQSearch: Could not get FAQ data in Kernel::GenericInterface::Operation::FAQ::PublicFAQSearch::Run()'
                }
            },
            Success => 1
        },
        ExpectedReturnLocalData => {
            Data => {
                Error => {
                    ErrorCode    => 'PublicFAQSearch.NotFAQData',
                    ErrorMessage =>
                        'PublicFAQSearch: Could not get FAQ data in Kernel::GenericInterface::Operation::FAQ::PublicFAQSearch::Run()'
                }
            },
            Success => 1
        },
        Operation => 'PublicFAQSearch',
    },
    {
        Name           => 'Test 11',
        SuccessRequest => '1',
        RequestData    => {
            ItemID => "$ItemIDOne,$ItemIDTwo,$ItemIDThree",
        },
        ExpectedReturnRemoteData => {
            Success => 1,
            Data    => {
                FAQItem => [
                    {
                        %FAQOne
                    },
                    {
                        %FAQTwo
                    },
                    {
                        %FAQThree,
                        Attachment => \@AttachmentsThree,
                    },
                ],
            },
        },
        Operation => 'PublicFAQGet',
        ItemID    => "$ItemIDOne,$ItemIDTwo,$ItemIDThree",
    },

);

# debugger object
my $DebuggerObject = Kernel::GenericInterface::Debugger->new(
    DebuggerConfig => {
        DebugThreshold => 'debug',
        TestMode       => 1,
    },
    WebserviceID      => $WebserviceID,
    CommunicationType => 'Provider',
);
isa_ok(
    $DebuggerObject,
    ['Kernel::GenericInterface::Debugger'],
    'DebuggerObject instantiate correctly',
);

for my $Test (@Tests) {

    subtest $Test->{Name} => sub {

        # create local object
        my $LocalObject = "Kernel::GenericInterface::Operation::FAQ::$Test->{Operation}"->new(
            DebuggerObject => $DebuggerObject,
            WebserviceID   => $WebserviceID,
        );

        isa_ok(
            $LocalObject,
            ["Kernel::GenericInterface::Operation::FAQ::$Test->{Operation}"],
            "Create local object",
        );

        # start requester with our web-service
        my $LocalResult = $LocalObject->Run(
            WebserviceID => $WebserviceID,
            Invoker      => $Test->{Operation},
            Data         => $Test->{RequestData},
        );

        # check result
        ref_ok( $LocalResult, 'HASH', "Local result structure is valid" );

        # workaround because results from direct call and
        # from SOAP call are a little bit different
        if ( $Test->{Operation} eq 'PublicFAQGet' ) {

            if ( ref $LocalResult->{Data}->{FAQItem} eq 'ARRAY' ) {
                for my $FAQItem ( @{ $LocalResult->{Data}->{FAQItem} } ) {
                    for my $Key ( sort keys %{$FAQItem} ) {
                        if ( !$FAQItem->{$Key} ) {
                            $FAQItem->{$Key} = '';
                        }
                    }
                }
            }

        }

        # remove ErrorMessage parameter from direct call
        # result to be consistent with SOAP call result
        if ( $LocalResult->{ErrorMessage} ) {
            delete $LocalResult->{ErrorMessage};
        }

        if ( $Test->{ExpectedReturnLocalData} ) {
            is(
                $LocalResult,
                $Test->{ExpectedReturnLocalData},
                "Local result matched with remote result.",
            );
        }
        else {
            is(
                $LocalResult,
                $Test->{ExpectedReturnRemoteData},
                "Local result matched with remote result.",
            );
        }

        # remote call using the system as Requester and Provider

        # create requester object
        my $RequesterObject = $Kernel::OM->Get('Kernel::GenericInterface::Requester');
        isa_ok(
            $RequesterObject,
            ['Kernel::GenericInterface::Requester'],
            "Create requester object",
        );

        # start requester with our web-service
        my $RequesterResult = $RequesterObject->Run(
            WebserviceID => $WebserviceID,
            Invoker      => $Test->{Operation},
            Data         => $Test->{RequestData},
        );

        # check result
        ref_ok( $RequesterResult, 'HASH', "Requester result structure is valid" );

        # workaround because results from direct call and
        # from SOAP call are a little bit different
        if ( $Test->{Operation} eq 'PublicFAQGet' && $Test->{SuccessRequest} ) {

            if ( ref $RequesterResult->{Data}->{FAQItem} eq 'HASH' ) {
                for my $Key ( sort keys %{ $RequesterResult->{Data}->{FAQItem} } ) {
                    if ( !$RequesterResult->{Data}->{FAQItem}->{$Key} ) {
                        $RequesterResult->{Data}->{FAQItem}->{$Key} = '';
                    }
                }
            }
            elsif ( ref $RequesterResult->{Data}->{FAQItem} eq 'ARRAY' ) {
                for my $FAQItem ( @{ $RequesterResult->{Data}->{FAQItem} } ) {
                    for my $Key ( sort keys %{$FAQItem} ) {
                        if ( !$FAQItem->{$Key} ) {
                            $FAQItem->{$Key} = '';
                        }
                    }
                }
            }
        }

        is(
            $RequesterResult->{Success},
            $Test->{SuccessRequest},
            "Requester - Success status",
        );

        is(
            $RequesterResult,
            $Test->{ExpectedReturnRemoteData},
            "Requester successful result (needs configured and running webserver)",
        );
    };
}

# clean up web-service
my $WebserviceDelete = $WebserviceObject->WebserviceDelete(
    ID     => $WebserviceID,
    UserID => $UserID,
);
ok( $WebserviceDelete, "Deleted Webs-ervice $WebserviceID" );

# clean up FAQ stuff
my $FAQDelete = $FAQObject->FAQDelete(
    ItemID => $ItemIDOne,
    UserID => $UserID,
);
ok( $FAQDelete, "FAQDelete() - ItemID: $ItemIDOne" );

$FAQDelete = $FAQObject->FAQDelete(
    ItemID => $ItemIDTwo,
    UserID => $UserID,
);
ok(
    $FAQDelete,
    "FAQDelete() - ItemID: $ItemIDTwo",
);

$FAQDelete = $FAQObject->FAQDelete(
    ItemID => $ItemIDThree,
    UserID => $UserID,
);
ok(
    $FAQDelete,
    "FAQDelete() - ItemID: $ItemIDThree",
);

$FAQDelete = $FAQObject->FAQDelete(
    ItemID => $ItemIDFour,
    UserID => $UserID,
);
ok(
    $FAQDelete,
    "FAQDelete() - ItemID: $ItemIDFour",
);

my $CategoryDelete = $FAQObject->CategoryDelete(
    CategoryID => $CategoryIDFour,
    UserID     => $UserID,
);

ok(
    $CategoryDelete,
    "CategoryDelete() - Category: $CategoryIDFour",
);

$CategoryDelete = $FAQObject->CategoryDelete(
    CategoryID => $CategoryIDThree,
    UserID     => $UserID,
);

ok(
    $CategoryDelete,
    "CategoryDelete() - Category: $CategoryIDThree",
);

$CategoryDelete = $FAQObject->CategoryDelete(
    CategoryID => $CategoryIDTwo,
    UserID     => $UserID,
);

ok(
    $CategoryDelete,
    "CategoryDelete() - Category: $CategoryIDTwo",
);

$CategoryDelete = $FAQObject->CategoryDelete(
    CategoryID => $CategoryIDOne,
    UserID     => $UserID,
);

ok(
    $CategoryDelete,
    "CategoryDelete() - Category: $CategoryIDOne",
);

done_testing();
