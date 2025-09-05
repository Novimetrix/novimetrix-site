import apiFetch from '@wordpress/api-fetch';
import {
	Button,
	Select,
	toast,
	Loader,
	Skeleton,
	Container,
	Alert,
	Text,
} from '@bsf/force-ui';
import { useDispatch, useSuspenseSelect, useSelect } from '@wordpress/data';
import { STORE_NAME } from '@/admin-store/constants';
import { __ } from '@wordpress/i18n';
import { useState, Suspense } from '@wordpress/element';
import { handleDisconnectConfirm } from '../admin-components/user-dropdown';
import { X } from 'lucide-react';
import ModalWrapper from '@AdminComponents/modal-wrapper';

const SiteSelectorPopup = () => {
	const { toggleSiteSelectorModal } = useDispatch( STORE_NAME );
	const searchConsole = useSelect(
		( select ) => select( STORE_NAME ).getSearchConsole(),
		[]
	);

	const isSiteSelected = () => {
		return !! searchConsole?.hasSiteSelected;
	};

	return (
		<ModalWrapper
			maxWidth="max-w-[480px]"
			isOpen={ toggleSiteSelectorModal }
		>
			<Container
				className="relative bg-white rounded-lg shadow-lg max-w-md w-full"
				direction="column"
				gap="xs"
			>
				{ /* Header */ }
				<Container
					className="border-b border-gray-200 p-5 pb-2"
					justify="between"
					align="start"
					gap="xs"
					direction="column"
				>
					<Container
						justify="between"
						align="start"
						gap="xs"
						className="w-full"
					>
						<Text className="text-lg font-semibold">
							{ __( 'Search Console Account', 'surerank' ) }
						</Text>
						{ isSiteSelected() && (
							<Button
								icon={ <X /> }
								onClick={ toggleSiteSelectorModal }
								variant="ghost"
								className="p-0"
							/>
						) }
					</Container>
					<Container direction="column" gap="xs">
						<Text className="text-sm text-gray-600">
							{ __(
								'Please select a site below to view its data.',
								'surerank'
							) }
						</Text>
					</Container>
				</Container>

				{ /* Body */ }
				<Suspense
					fallback={
						<Container direction="column" className="gap-5">
							<Container
								direction="column"
								className="gap-1.5 px-5 pt-2"
							>
								<Skeleton className="h-5 w-1/4" />
								<Skeleton className="h-10 w-full" />
							</Container>
							<Container justify="end" className="p-4 gap-3">
								<Skeleton className="h-10 w-20" />
								<Skeleton className="h-10 w-20" />
							</Container>
						</Container>
					}
				>
					<SiteSelectorInputs />
				</Suspense>
			</Container>
		</ModalWrapper>
	);
};

const SiteSelectorInputs = () => {
	const searchConsole = useSuspenseSelect(
		( select ) => select( STORE_NAME ).getSearchConsole(),
		[]
	);
	const { toggleSiteSelectorModal, setSearchConsole, setConfirmationModal } =
		useDispatch( STORE_NAME );
	const [ isLoading, setIsLoading ] = useState( false );
	const [ selectedSite, setSelectedSite ] = useState(
		searchConsole?.selectedSite || searchConsole?.tempSelectedSite || ''
	);

	const handleSelectSite = ( site ) => {
		setSelectedSite( site );
	};

	const noSitesAvailable =
		! searchConsole?.sites || searchConsole?.sites.length === 0;

	const handleDisconnect = () => {
		setConfirmationModal( {
			open: true,
			title: __( 'Disconnect Search Console Account', 'surerank' ),
			description: __(
				'Are you sure you want to disconnect your Search Console account from SureRank?',
				'surerank'
			),
			onConfirm: handleDisconnectConfirm,
			confirmButtonText: __( 'Disconnect', 'surerank' ),
		} );
	};

	const handleProceed = async () => {
		if ( ! selectedSite ) {
			toast.error( __( 'Please select a site', 'surerank' ) );
			return;
		}
		if ( isLoading ) {
			return;
		}
		setIsLoading( true );
		try {
			const response = await apiFetch( {
				path: '/surerank/v1/site',
				method: 'PUT',
				data: { url: selectedSite },
			} );
			if ( ! response.success ) {
				throw new Error(
					response.message ?? __( 'Failed to proceed', 'surerank' )
				);
			}
			toast.success( __( 'Site selected successfully', 'surerank' ) );
			toggleSiteSelectorModal();
			setSearchConsole( {
				selectedSite,
				hasSiteSelected: true,
			} );
		} catch ( error ) {
			toast.error( error.message );
		} finally {
			setIsLoading( false );
		}
	};

	const setInitialFocus = ( node ) => {
		if ( ! node ) {
			return;
		}
		setTimeout( () => {
			node.focus();
		}, 100 );
	};

	return (
		<>
			<Container direction="column" gap="xs" className="p-5 pt-2 pb-3">
				<Select
					onChange={ handleSelectSite }
					size="md"
					value={ selectedSite }
					combobox
					className="p-1"
				>
					<Select.Button
						label={ __( 'Select a site', 'surerank' ) }
						placeholder={ __( 'Select a site', 'surerank' ) }
						render={ ( selectedValue ) =>
							selectedValue || __( 'Select a site', 'surerank' )
						}
						ref={ setInitialFocus }
					/>
					<Select.Options>
						{ searchConsole?.sites?.map( ( option ) => (
							<Select.Option
								key={ option.siteUrl }
								value={ option.siteUrl }
								selected={ selectedSite === option.siteUrl }
							>
								{ option.siteUrl }
							</Select.Option>
						) ) }
					</Select.Options>
				</Select>

				{ noSitesAvailable && (
					<Container className="mt-4">
						<Alert
							variant="warning"
							className="shadow-none m-0 testtest [&>div>p]:mr-0"
							content={
								<div className="flex flex-col gap-0.5">
									<span className="text-text-primary text-sm font-semibold">
										{ __(
											'No Verified Site Found',
											'surerank'
										) }
									</span>
									<span className="text-text-primary">
										{ __(
											'Add and verify your site in Google Search Console to start seeing insights here. ',
											'surerank'
										) }
										<a
											href="https://support.google.com/webmasters/answer/34592?hl=en"
											target="_blank"
											rel="noopener noreferrer"
											className="text-blue-600 no-underline hover:no-underline"
										>
											{ __( 'Learn more', 'surerank' ) }
										</a>
									</span>
								</div>
							}
						/>
					</Container>
				) }
			</Container>
			{ /* Footer */ }
			<Container
				className="border-0 border-solid border-t border-gray-200 gap-3 p-4"
				justify="end"
			>
				<Button
					destructive
					iconPosition="left"
					size="md"
					tag="button"
					type="button"
					variant="outline"
					onClick={ handleDisconnect }
				>
					{ __( 'Disconnect', 'surerank' ) }
				</Button>
				<Button
					variant="primary"
					size="md"
					onClick={ handleProceed }
					icon={ isLoading && <Loader variant="secondary" /> }
					iconPosition="left"
					disabled={ isLoading }
				>
					{ __( 'Proceed', 'surerank' ) }
				</Button>
			</Container>
		</>
	);
};

export default SiteSelectorPopup;
