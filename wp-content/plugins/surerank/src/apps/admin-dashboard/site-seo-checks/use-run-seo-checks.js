import { useState } from '@wordpress/element';
import { useDispatch } from '@wordpress/data';
import { STORE_NAME } from '@AdminStore/constants';
import apiFetch from '@wordpress/api-fetch';
import { addQueryArgs } from '@wordpress/url';

/**
 * Custom hook for running SEO checks
 *
 * @return {Object} Hook return object containing isLoading state and handleRunChecksAgain function
 */
export const useRunSeoChecks = () => {
	const dispatch = useDispatch( STORE_NAME );
	const [ isLoading, setIsLoading ] = useState( false );
	const { setSiteSeoAnalysis } = dispatch;

	const handleRunChecksAgain = async () => {
		if ( isLoading ) {
			return;
		}
		setIsLoading( true );
		const url = surerank_globals.site_url;
		const force = true;

		let settingsResponse = {};
		let otherResponse = {};
		let generalResponse = {};

		try {
			settingsResponse = await apiFetch( {
				path: addQueryArgs( '/surerank/v1/checks/settings', {
					url,
					force,
				} ),
			} );
		} catch ( error ) {}

		try {
			otherResponse = await apiFetch( {
				path: addQueryArgs( '/surerank/v1/checks/other', {
					url,
					force,
				} ),
			} );
		} catch ( error ) {}

		try {
			generalResponse = await apiFetch( {
				path: addQueryArgs( '/surerank/v1/checks/general', {
					url,
					force,
				} ),
			} );
		} catch ( error ) {}

		const hasAnyData =
			Object.keys( settingsResponse ).length > 0 ||
			Object.keys( otherResponse ).length > 0 ||
			Object.keys( generalResponse ).length > 0;

		if ( hasAnyData ) {
			setSiteSeoAnalysis( {
				report: {
					...generalResponse,
					...settingsResponse,
					...otherResponse,
				},
			} );
		}

		setIsLoading( false );
	};

	return { isLoading, handleRunChecksAgain };
};
