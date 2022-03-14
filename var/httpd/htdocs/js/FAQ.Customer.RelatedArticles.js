/* OTOBO is a web-based ticketing system for service organisations.

Copyright (C) 2019-2022 Rother OSS GmbH, https://otobo.de/

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/

"use strict";

var FAQ = FAQ || {};
FAQ.Customer = FAQ.Customer || {};

/**
 * @namespace
 * @exports TargetNS as FAQ.Customer.RelatedArticles
 * @description
 *      This namespace contains the special module functions for FAQ.
 */
FAQ.Customer.RelatedArticles = (function (TargetNS) {

    /**
     * @private
     * @name ShowRelatedArticles
     * @memberof FAQ.Customer.RelatedArticles
     * @function
     * @description
     *      This function slides in and out the related articles
     */
    function ShowRelatedArticles() {
        if ( $(window).width() > 1023 ) { return }

        $('#FAQRelatedArticles').css( 'top', '' );
        $('#FAQRelatedArticles').css( 'bottom', '16px' );
        $('#FAQRelatedArticles > .WidgetSimple > .Header').off('click').one('click', function() {
            var Height = $(window).height() - 48;
            $('#FAQRelatedArticles').css( 'bottom', '' );
            $('#FAQRelatedArticles').css( 'top', Height + 'px' );
            return false;
        });
    }

    /**
     * @name Init
     * @memberof FAQ.Customer.RelatedArticles
     * @function
     * @description
     *      This function initialize the FAQ module (functionality for related articles).
     */
    TargetNS.Init = function() {
        $('#FAQRelatedArticles').on('click', ShowRelatedArticles);
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(FAQ.Customer.RelatedArticles || {}));
