import {
	useSelect,
	useDispatch,
	select as staticSelect,
} from '@wordpress/data';
import { useState, useCallback, useEffect, Suspense } from '@wordpress/element';
import { Alert } from '@bsf/force-ui';
import { __ } from '@wordpress/i18n';
import { PageChecks } from '..';
import {
	refreshPageChecks,
	isPageBuilderActive,
	isBricksBuilder,
} from './analyzer/utils/page-builder';
import RefreshButtonPortal from '../refresh-button-portal';
import { STORE_NAME } from '@/store/constants';
import PageChecksListSkeleton from './page-checks-list-skeleton';

const PageBuilderPageSeoChecksHoc = () => {
	const pageSeoChecks = useSelect(
		( select ) => select( STORE_NAME ).getPageSeoChecks(),
		[]
	);
	const { categorizedChecks } = pageSeoChecks;
	const modalState = useSelect(
		( select ) => select( STORE_NAME ).getModalState(),
		[]
	);
	const refreshCalled = useSelect(
		( select ) => select( STORE_NAME ).getRefreshCalled(),
		[]
	);
	const {
		setPageSeoCheck,
		setRefreshCalled,
		ignorePageSeoCheck,
		restorePageSeoCheck,
	} = useDispatch( STORE_NAME );

	const [ brokenLinkState, setBrokenLinkState ] = useState( {
		isChecking: false,
		checkedLinks: new Set(),
		brokenLinks: new Set(),
		allLinks: [],
	} );

	const handleIgnoreCheck = ( checkId ) => {
		ignorePageSeoCheck( checkId );
	};
	const handleRestoreCheck = ( checkId ) => {
		restorePageSeoCheck( checkId );
	};

	const [ isRefreshing, setIsRefreshing ] = useState( false );
	const isPageBuilderEditor = isPageBuilderActive();

	const handleRefreshWithBrokenLinks = useCallback( async () => {
		setRefreshCalled( true ); // // Ensure subsequent opens don't auto-refresh
		await refreshPageChecks(
			setIsRefreshing,
			setBrokenLinkState,
			setPageSeoCheck,
			staticSelect,
			pageSeoChecks,
			brokenLinkState
		);
	}, [
		setIsRefreshing,
		setBrokenLinkState,
		setPageSeoCheck,
		pageSeoChecks,
		brokenLinkState,
		setRefreshCalled,
	] );

	useEffect( () => {
		if ( modalState && ! refreshCalled ) {
			refreshPageChecks(
				setIsRefreshing,
				setBrokenLinkState,
				setPageSeoCheck,
				staticSelect,
				pageSeoChecks,
				brokenLinkState
			);
			setRefreshCalled( true ); // Dispatch action to set refreshCalled
		}
	}, [
		isPageBuilderEditor,
		modalState,
		refreshCalled, // Use state instead of ref
		setPageSeoCheck,
		pageSeoChecks,
		brokenLinkState,
		setRefreshCalled,
	] );

	// Bricks builder doesn't support page level SEO checks
	if ( isBricksBuilder() ) {
		return null;
	}

	return (
		<div className="p-1 space-y-2 flex-1 flex flex-col">
			{
				<>
					<RefreshButtonPortal
						isRefreshing={ isRefreshing }
						isChecking={ pageSeoChecks.isCheckingLinks }
						onClick={ handleRefreshWithBrokenLinks }
					/>
					<div className="p-2 [&_p.mr-10]:mr-0">
						<Alert
							variant="info"
							content={
								<span className="flex items-start gap-2">
									<p>
										{ __(
											'Please save changes in the editor before refreshing the checks.',
											'surerank'
										) }
									</p>
									<span className="-mr-3 refresh-button-container shrink-0" />
								</span>
							}
							className="shadow-none"
						/>
					</div>
				</>
			}
			<div className="flex-1">
				<Suspense fallback={ <PageChecksListSkeleton /> }>
					<PageChecks
						pageSeoChecks={ {
							...pageSeoChecks,
							...categorizedChecks,
							isCheckingLinks: pageSeoChecks.isCheckingLinks,
						} }
						onIgnore={ handleIgnoreCheck }
						onRestore={ handleRestoreCheck }
					/>
				</Suspense>
			</div>
		</div>
	);
};

export default PageBuilderPageSeoChecksHoc;
