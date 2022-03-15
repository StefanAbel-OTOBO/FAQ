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
 * @exports TargetNS as FAQ.Agent.ConfirmationDialog
 * @description
 *      This namespace contains the special module functions for ConfirmationDialog.
 */
FAQ.Agent.ConfirmationDialog = (function (TargetNS) {

    /**
     * @name DialogData
     * @memberof FAQ.Agent.ConfirmationDialog
     * @variable
     * @private
     * @description
     *      This variable stores the parameters that are passed from the DTL and contain all the data that the dialog needs.
     */
    var DialogData = [];

    /**
     * @name ShowWaitingDialog
     * @memberof FAQ.Agent.ConfirmationDialog
     * @function
     * @private
     * @param {String} PositionTop position of the dialog.
     * @description
     *      Shows waiting dialog until search screen is ready.
     */
    function ShowWaitingDialog(PositionTop){
        Core.UI.Dialog.ShowContentDialog('<div class="Spacing Center"><span class="AJAXLoader" title="' + Core.Config.Get('LoadingMsg') + '"></span></div>', '', PositionTop, 'Center', true);
    }

    /**
     * @name ShowConfirmationDialog
     * @memberof FAQ.Agent.ConfirmationDialog
     * @function
     * @returns {Boolean} false
     * @description
     *      This function shows a confirmation dialog with 2 buttons: Yes and No.
     */
    TargetNS.ShowConfirmationDialog = function () {

        var LocalDialogData,
            PositionTop,
            Data,
            Buttons;

        // get global saved DialogData for this function
        LocalDialogData = DialogData[$(this).attr('id')];

        // define the position of the dialog
        PositionTop = $(window).scrollTop() + ($(window).height() * 0.3);

        // show waiting dialog
        ShowWaitingDialog(PositionTop);

        // ajax call to the module that deletes the template
        Data = LocalDialogData.DialogContentQueryString;
        Core.AJAX.FunctionCall(Core.Config.Get('Baselink'), Data, function (Response) {

            // 'Confirmation' opens a dialog with 2 buttons: Yes and No
            if (Response.DialogType === 'Confirmation') {

                // define yes and no buttons
                Buttons = [{
                    Label: Core.Language.Translate('Yes'),
                    Class: "Primary",

                    // define the function that is called when the 'Yes' button is pressed
                    Function: function(){

                        // disable Yes and No buttons to prevent multiple submits
                        $('div.Dialog:visible div.ContentFooter button').attr('disabled', 'disabled');

                        // redirect to the module that does the confirmed action after pressing the Yes button
                        location.href = Core.Config.Get('Baselink') + LocalDialogData.ConfirmedActionQueryString;
                    }
                }, {
                    Label: Core.Language.Translate('No'),
                    Type: "Close"
                }];
            }

            // 'Message' opens a dialog with 1 button: Ok
            else if (Response.DialogType === 'Message') {

                // define Ok button
                Buttons = [{
                    Label: Core.Language.Translate('Ok'),
                    Class: "Primary",
                    Type: "Close"
                }];
            }

            // show the confirmation dialog to confirm the action
            Core.UI.Dialog.ShowContentDialog(Response.HTML, LocalDialogData.DialogTitle, PositionTop, "Center", true, Buttons);
        }, 'json');
        return false;
    };

    /**
     * @name Init
     * @memberof FAQ.Agent.Init
     * @function
     * @param {Object} Data - The data that should be binded
     * @description
     *      This function binds a click event to the defined element
     */
    TargetNS.Init = function () {
        var ID,
        FAQData = Core.Config.Get('FAQData');

        // Binding a click event to the defined element.
        if (typeof FAQData !== 'undefined') {
            for (ID in FAQData) {
                DialogData[FAQData[ID].ElementID] = FAQData[ID];
                $(FAQData[ID].ElementSelector).on('click', TargetNS.ShowConfirmationDialog);
            }
        }
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(FAQ.Agent.ConfirmationDialog || {}));
