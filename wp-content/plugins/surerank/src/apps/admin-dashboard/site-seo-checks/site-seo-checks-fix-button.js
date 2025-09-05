import { SeoPopupTooltip } from '@/apps/admin-components/tooltip';
import { Text, Button } from '@bsf/force-ui';
import { __ } from '@wordpress/i18n';

const pricingLink = window?.surerank_globals?.pricing_link ?? '';

const FixButton = ( {
	size = 'xs',
	disabled = true,
	tooltipProps,
	title = __( 'Fix SEO Issues with AI', 'surerank' ),
	description = __(
		'Let AI automatically detect and resolve on-page SEO problems, such as missing SEO descriptions, image alt tags, and more.',
		'surerank'
	),
	link = pricingLink,
	linkLabel = __( 'Upgrade Now', 'surerank' ),
	iconPosition = 'left',
	icon,
	button_label = __( 'Fix It for Me', 'surerank' ),
	...props
} ) => {
	return (
		<SeoPopupTooltip
			arrow
			interactive
			placement="top-end"
			{ ...tooltipProps }
			content={
				<div className="space-y-1">
					<Text size={ 12 } weight={ 600 } color="inverse">
						{ title }
					</Text>
					<Text
						size={ 12 }
						weight={ 400 }
						color="inverse"
						className="leading-relaxed"
					>
						{ description }
					</Text>
					<div className="mt-1.5">
						<Button
							size="xs"
							variant="link"
							className="[&>span]:px-0 no-underline hover:no-underline focus:[box-shadow:none] text-link-inverse hover:text-link-inverse-hover"
							tag="a"
							href={ link }
							target="_blank"
						>
							{ linkLabel }
						</Button>
					</div>
				</div>
			}
		>
			<Button
				className="w-fit"
				size={ size }
				icon={ icon }
				iconPosition={ iconPosition }
				disabled={ disabled }
				{ ...props }
			>
				{ button_label }
			</Button>
		</SeoPopupTooltip>
	);
};

export default FixButton;
