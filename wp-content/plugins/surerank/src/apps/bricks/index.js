import { __ } from '@wordpress/i18n';
import { sureRankLogoForBuilder, handleOpenSureRankDrawer } from '../elementor';

/* global jQuery */
/* eslint-disable */

// eslint-disable-next-line wrap-iife
( function ( $ ) {
	document.addEventListener( 'DOMContentLoaded', function () {
		const toolbar = $( '#bricks-toolbar .right, #bricks-toolbar .end' );
		const button = $( `<li aria-label="${ __(
			'Open SureRank SEO',
			'surerank'
		) }" data-balloon-pos="bottom" data-balloon="SureRank" tabindex="0">
						<span class="bricks-svg-wrapper">${ sureRankLogoForBuilder(
							'surerank'
						) }</span>
					</li>` );
		button.on( 'click', handleOpenSureRankDrawer );
		// Append after 4th child.
		toolbar.children().eq( 3 ).after( button );
	} );
} )( jQuery );
