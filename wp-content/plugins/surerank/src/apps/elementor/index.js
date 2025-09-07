import { cn } from '@/functions/utils';
import { STORE_NAME } from '@/store/constants';
import { dispatch } from '@wordpress/data';
import { __ } from '@wordpress/i18n';
import './tooltip.css';

/* global jQuery */

export const handleOpenSureRankDrawer = () => {
	const dispatchToSureRankStore = dispatch( STORE_NAME );
	dispatchToSureRankStore.updateModalState( true );
};

// Custom Material UI style tooltip implementation for Elementor with TailwindCSS
const createSureRankTooltip = ( targetElement, tooltipText ) => {
	if ( ! targetElement || ! tooltipText ) {
		return;
	}

	// Create wrapper with surerank-root class
	const wrapper = document.createElement( 'div' );
	wrapper.className = 'surerank-root';

	// Create tooltip element with TailwindCSS styling
	const tooltip = document.createElement( 'div' );
	tooltip.className = cn(
		'surerank-tooltip',
		'absolute',
		'bg-gray-700',
		'text-white',
		'px-2',
		'py-0.5',
		'rounded',
		'text-[0.6875rem]',
		'font-medium',
		'leading-tight',
		'tracking-wide',
		'invisible',
		'opacity-0',
		'pointer-events-none',
		'origin-top',
		'z-[9999]',
		'top-0',
		'left-0'
	);
	tooltip.textContent = tooltipText;

	// Create arrow element
	const arrow = document.createElement( 'div' );
	arrow.className = cn(
		'absolute',
		'-top-[0.4375rem]',
		'left-1/2',
		'w-0',
		'h-0',
		'border-solid',
		'border-l-[0.375rem]',
		'border-r-[0.375rem]',
		'border-b-[0.375rem]',
		'border-l-transparent',
		'border-r-transparent',
		'border-t-transparent',
		'border-b-gray-700',
		'translate-x-[-50%]',
		'bg-transparent'
	);

	// Append arrow to tooltip
	tooltip.appendChild( arrow );

	// Append tooltip to wrapper
	wrapper.appendChild( tooltip );

	// Append wrapper to body
	document.body.appendChild( wrapper );

	// Position tooltip function
	const positionTooltip = () => {
		const targetRect = targetElement.getBoundingClientRect();

		// Position below the target element (accounting for arrow height)
		const top = targetRect.bottom + 16; // 14px for arrow and spacing
		const centerX = targetRect.left + targetRect.width / 2;

		tooltip.style.top = top + 'px';
		tooltip.style.left = centerX + 'px';
	};

	// Show tooltip
	const showTooltip = () => {
		positionTooltip();
		tooltip.classList.remove(
			'invisible',
			'opacity-0',
			'surerank-tooltip--hidden'
		);
		tooltip.classList.add(
			'visible',
			'opacity-100',
			'surerank-tooltip--visible'
		);
	};

	// Add event listeners
	let showTimeout;
	let hideTimeout;
	let hideAnimationTimeout;

	// Hide tooltip
	const hideTooltip = () => {
		clearTimeout( hideAnimationTimeout );
		tooltip.classList.remove( 'opacity-100' );
		tooltip.classList.add( 'opacity-0' );
		hideAnimationTimeout = setTimeout( () => {
			tooltip.classList.remove( 'visible' );
			tooltip.classList.add( 'invisible', 'surerank-tooltip--hidden' );
		}, 250 );
	};

	const handleMouseEnter = () => {
		clearTimeout( hideTimeout );
		showTimeout = setTimeout( showTooltip, 200 ); // 200ms delay like Material UI
	};

	const handleMouseLeave = () => {
		clearTimeout( showTimeout );
		hideTimeout = setTimeout( hideTooltip, 0 );
	};

	const handleFocus = () => {
		clearTimeout( hideTimeout );
		showTooltip();
	};

	const handleBlur = () => {
		clearTimeout( showTimeout );
		hideTooltip();
	};

	// Attach event listeners
	targetElement.addEventListener( 'mouseenter', handleMouseEnter );
	targetElement.addEventListener( 'mouseleave', handleMouseLeave );
	targetElement.addEventListener( 'focus', handleFocus );
	targetElement.addEventListener( 'blur', handleBlur );

	// Return cleanup function
	return () => {
		clearTimeout( showTimeout );
		clearTimeout( hideTimeout );
		clearTimeout( hideAnimationTimeout );
		targetElement.removeEventListener( 'mouseenter', handleMouseEnter );
		targetElement.removeEventListener( 'mouseleave', handleMouseLeave );
		targetElement.removeEventListener( 'focus', handleFocus );
		targetElement.removeEventListener( 'blur', handleBlur );
		if ( wrapper.parentNode ) {
			wrapper.parentNode.removeChild( wrapper );
		}
	};
};

export const sureRankLogoForBuilder = ( className ) => {
	return `<svg class="${ cn(
		className
	) }" width="12" height="12" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M13.5537 1.5C17.8453 1.5 21.3251 4.97895 21.3252 9.27051C21.3252 12.347 19.5368 15.0056 16.9434 16.2646H21.3252V22.5H18.0889C14.9086 22.5 12.2861 20.1186 11.9033 17.042H11.9014L11.9033 13.7852C14.8283 13.7661 17.0342 11.3894 17.0342 8.45996V6.0293C14.137 6.02947 11.6948 7.97682 10.9443 10.6338C10.1605 9.53345 8.87383 8.8165 7.41992 8.81641H6.38086V9.85352H6.38379C6.44515 12.0356 8.23375 13.786 10.4307 13.7861H10.7061L10.6934 17.042H10.6865C10.2943 20.1082 7.67678 22.4785 4.50391 22.4785H2.6748V1.5H13.5537Z" fill="white"/>
        </svg>`;
};

// eslint-disable-next-line wrap-iife
( function ( $ ) {
	let tooltipCleanup = null;

	$( window ).on( 'load', function () {
		const topBar = $(
			'#elementor-editor-wrapper-v2 header .MuiGrid-root:nth-child(3) .MuiStack-root'
		);

		// Get the button and svg class name from the topbar last child.
		const lastChild = topBar.last();
		const buttonClassName = lastChild.find( 'button' ).attr( 'class' );
		const svgClassName = lastChild.find( 'svg' ).attr( 'class' );

		// Create the button with click handler and insert as the 2nd child.
		const $button = $(
			`<button type="button" class="${ buttonClassName }" aria-label="${ __(
				'Open SureRank SEO',
				'surerank'
			) }" tabindex="0">
				${ sureRankLogoForBuilder( svgClassName ) }
			</button>`
		).on( 'click', handleOpenSureRankDrawer );

		topBar.children().first().after( $button );
		// Add tooltip to the button and store cleanup function.
		tooltipCleanup = createSureRankTooltip(
			$button?.[ 0 ],
			__( 'SureRank Meta Box', 'surerank' )
		);
	} );

	// Cleanup on page unload
	$( window ).on( 'beforeunload', function () {
		if ( tooltipCleanup ) {
			tooltipCleanup();
			tooltipCleanup = null;
		}
	} );
} )( jQuery );
