// --
// OTOBO is a web-based ticketing system for service organisations.
// --
// Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
// Copyright (C) 2019-2022 Rother OSS GmbH, https://otobo.de/
// --
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
// --


"use strict";

var FAQ = FAQ || {};
FAQ.Agent = FAQ.Agent || {};

/**
 * @namespace
 * @exports TargetNS as FAQ.Agent.FAQ
 * @description
 *      This namespace contains the special module functions for FAQ.
 */
FAQ.Agent.FAQ = (function (TargetNS) {

    /**
     * @name Init
     * @memberof FAQ.Agent.FAQ
     * @function
     * @description
     *      This function initialize the FAQ module.
     */
    TargetNS.Init = function() {
        var FAQSearchProfile = Core.Config.Get('FAQSearchProfile');

        // Prevent too fast submitions that could lead into no changes sent to server,
        // due to RTE to textarea data transfer
        $('#FAQSubmit').on('click', function () {
            window.setTimeout(function () {
                $('#FAQSubmit').closest('form').submit();
            }, 250);
        });

        $('#AgentFAQSearch').on('click', function () {
            Core.Agent.Search.OpenSearchDialog('AgentFAQSearch');
            return false;
        });

        if (FAQSearchProfile !== 'undefined') {
            $('#FAQSearch').on('click', function () {
                Core.Agent.Search.OpenSearchDialog(Core.Config.Get('Action'), FAQSearchProfile);
                return false;
            });
        }

        $('#ShowContextSettingsDialog').on('click', function (Event) {
            Core.UI.Dialog.ShowContentDialog($('#ContextSettingsDialogContainer'), Core.Language.Translate("Settings"), '20%', 'Center', true,
                [
                    {
                        Label: Core.Language.Translate("Submit"),
                        Type: 'Submit',
                        Class: 'Primary'
                    }
                ]
            );
            Event.preventDefault();
            Event.stopPropagation();
            return false;
        });

        if (Core.Config.Get('AgentFAQSearch') === 1) {
            Core.Agent.Search.OpenSearchDialog(Core.Config.Get('Action'), FAQSearchProfile);
        }
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(FAQ.Agent.FAQ || {}));
