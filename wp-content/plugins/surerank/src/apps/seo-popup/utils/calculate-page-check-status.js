/**
 * Calculate page check status and counts from categorized checks
 *
 * @param {Object} categorizedChecks - The categorized checks object
 * @return {Object} Object containing status and counts
 */
export const calculatePageCheckStatus = ( categorizedChecks = {} ) => {
	const {
		badChecks = [],
		fairChecks = [],
		passedChecks = [],
		suggestionChecks = [],
	} = categorizedChecks;

	// Calculate status
	let status = 'success';
	if ( badChecks.length > 0 ) {
		status = 'error';
	} else if ( fairChecks.length > 0 ) {
		status = 'warning';
	} else if ( suggestionChecks.length > 0 ) {
		status = 'suggestion';
	}

	// Calculate counts
	const counts = {
		errorAndWarnings:
			badChecks.length + fairChecks.length + suggestionChecks.length,
		success: passedChecks.length,
		error: badChecks.length,
		warning: fairChecks.length,
		suggestion: suggestionChecks.length,
	};

	return { status, counts };
};
