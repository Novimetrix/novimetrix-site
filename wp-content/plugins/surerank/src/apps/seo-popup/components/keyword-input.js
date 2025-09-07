import { Button } from '@bsf/force-ui';
import { PencilLine } from 'lucide-react';
import { useSelect } from '@wordpress/data';
import { __ } from '@wordpress/i18n';
import { STORE_NAME } from '@Store/constants';
import { applyFilters } from '@wordpress/hooks';
import { SeoPopupTooltip } from '@AdminComponents/tooltip';
import PreviewInputWithSuffix from '@AdminComponents/preview-input-with-suffix';

const KeywordInput = () => {
	const { focusKeyword, title, termTitle } = useSelect( ( select ) => {
		const selectors = select( STORE_NAME );
		return {
			focusKeyword: selectors?.getResearchData?.()?.focusKeyword,
			title: selectors.getPostDynamicData()?.title,
			termTitle: selectors.getVariables()?.term?.term_title?.value ?? '',
		};
	} );

	return (
		<div className="[&>div]:w-full w-full">
			<PreviewInputWithSuffix
				value={ focusKeyword || title || termTitle || '' }
				suffix={ <KeywordInputSuffix /> }
			/>
		</div>
	);
};

const KeywordInputSuffix = () => {
	const renderProButton =
		applyFilters( 'surerank-pro.seo-popup-open-research-tab' ) ?? null;

	if ( renderProButton ) {
		return renderProButton;
	}

	return (
		<SeoPopupTooltip
			content={ __( 'Upgrade to Pro', 'surerank' ) }
			placement="top"
			arrow
			className="z-[99999]"
		>
			<Button
				className="cursor-pointer p-0 m-0 focus:[box-shadow:none] bg-transparent hover:bg-transparent pointer-events-auto"
				variant="ghost"
				disabled
				icon={
					<PencilLine
						className="size-5 text-icon-primary"
						strokeWidth={ 1.5 }
					/>
				}
			/>
		</SeoPopupTooltip>
	);
};

export default KeywordInput;
