import { Accordion, Text } from '@bsf/force-ui';
import { __ } from '@wordpress/i18n';
import { useMemo } from '@wordpress/element';
import PageChecksHoc from '../page-seo-checks/page-checks-hoc';
import PageBuilderPageSeoChecksHoc from '../page-seo-checks/page-builder-page-checks-hoc';
import {
	isBricksBuilder,
	isPageBuilderActive,
} from '../page-seo-checks/analyzer/utils/page-builder';
import { ENABLE_PAGE_LEVEL_SEO } from '@/global/constants';

const Analyze = () => {
	// Conditional rendering logic based on page builder status
	const PageChecksComponent = useMemo( () => {
		// Keep the page checks excluded for Bricks Builder and when this feature is disabled,
		if ( ! ENABLE_PAGE_LEVEL_SEO || isBricksBuilder() ) {
			return null;
		}
		const isPageBuilder = isPageBuilderActive();
		if ( isPageBuilder ) {
			return PageBuilderPageSeoChecksHoc;
		}
		return PageChecksHoc;
	}, [] );

	// Early return if no valid component is found.
	if ( ! PageChecksComponent ) {
		return (
			<div>
				<Text
					color="help"
					size={ 14 }
					className="text-center py-5 border-0.5 border-solid border-border-secondary rounded-md"
				>
					{ __(
						'SEO analysis is not available for this page.',
						'surerank'
					) }
				</Text>
			</div>
		);
	}

	return (
		<Accordion autoClose={ true } defaultValue="page-checks" type="boxed">
			<Accordion.Item
				value="page-checks"
				className="bg-background-primary overflow-hidden"
			>
				<Accordion.Trigger className="text-base [&>svg]:size-5 pr-2 pl-3 py-3">
					{ __( 'Page Checks', 'surerank' ) }
				</Accordion.Trigger>
				<Accordion.Content>
					<div className="pt-3">
						<PageChecksComponent />
					</div>
				</Accordion.Content>
			</Accordion.Item>
		</Accordion>
	);
};

export default Analyze;
