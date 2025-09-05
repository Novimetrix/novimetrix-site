import KeywordInput from '@SeoPopup/components/keyword-input';
import MetaSettingsScreen from './meta-settings';
import { ENABLE_PAGE_LEVEL_SEO } from '@Global/constants';
import PageSeoCheckStatusButton from '@SeoPopup/components/header/page-seo-check-status-button';
import { applyFilters } from '@wordpress/hooks';
import { isBricksBuilder } from '../page-seo-checks/analyzer/utils/page-builder';

const MetaSettings = () => {
	//we will show settings here
	const SeoPopupProTabContent = !! applyFilters( 'surerank-pro.seo-popup' );

	return (
		<>
			{ ENABLE_PAGE_LEVEL_SEO &&
				! isBricksBuilder() &&
				SeoPopupProTabContent && (
					<div className="flex items-center gap-2">
						<KeywordInput />
						<PageSeoCheckStatusButton />
					</div>
				) }
			<MetaSettingsScreen />
		</>
	);
};

export default MetaSettings;
