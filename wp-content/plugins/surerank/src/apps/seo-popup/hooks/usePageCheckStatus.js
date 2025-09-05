import { useSelect } from '@wordpress/data';
import { useMemo } from '@wordpress/element';
import { STORE_NAME } from '@/store/constants';
import { calculatePageCheckStatus } from '../utils/calculate-page-check-status';

/**
 * A simplified hook for getting page check status without suspense
 * Safe to use in components that can't be wrapped in Suspense
 *
 * @return {Object} Status data object with status, initializing, and counts
 */
const usePageCheckStatus = () => {
	const { categorizedChecks = {}, initializing = true } = useSelect(
		( select ) => {
			const storeSelectors = select( STORE_NAME );

			const pageSeoChecks = storeSelectors.getPageSeoChecks() || {};

			return {
				categorizedChecks: pageSeoChecks.categorizedChecks,
				initializing: pageSeoChecks.initializing,
			};
		},
		[]
	);

	const { status, counts } = useMemo(
		() =>
			calculatePageCheckStatus( categorizedChecks ) ?? {
				status: null,
				initializing: true,
				counts: { errorAndWarnings: 0 },
			},
		[ categorizedChecks ]
	);

	return { status, initializing, counts };
};

export default usePageCheckStatus;
