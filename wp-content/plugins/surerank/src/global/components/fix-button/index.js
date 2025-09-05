import { SeoPopupTooltip } from '@/apps/admin-components/tooltip';
import { Text, Button } from '@bsf/force-ui';
import { __ } from '@wordpress/i18n';
import { cn } from '@Functions/utils';
const pricingLink = window?.surerank_globals?.surerank_url ?? '';

const FixButton = ( {
	size = 'xs',
	tooltipProps,
	title = __( 'Fix SEO Issues with AI', 'surerank' ),
	description = (
		<>
			<span>
				{ __(
					'Let AI automatically detect and resolve on-page SEO problems, such as missing SEO descriptions, image alt tags, and more.',
					'surerank'
				) }
			</span>
			<br />
			<span className="mt-2 block">
				{ __( 'Coming Soon in SureRank Pro.', 'surerank' ) }
			</span>
		</>
	),
	link = pricingLink,
	linkLabel = __( 'Join Waitlist', 'surerank' ),
	iconPosition = 'left',
	icon,
	button_label = __( 'Fix It for Me', 'surerank' ),
	hidden = true,
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
				{ ...props }
				className={ cn( 'w-fit underline', hidden && 'hidden' ) }
				size={ size }
				icon={ icon }
				iconPosition={ iconPosition }
				variant="link"
			>
				{ button_label }
			</Button>
		</SeoPopupTooltip>
	);
};

export default FixButton;
