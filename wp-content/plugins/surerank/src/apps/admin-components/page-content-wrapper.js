import PageHeader from './page-header';

const PageContentWrapper = ( {
	children,
	title,
	description,
	icon,
	secondaryButton,
	info_tooltip = null,
} ) => {
	if ( ! children ) {
		return null;
	}

	return (
		<div className="flex flex-col justify-start-start gap-7 w-full h-full">
			<PageHeader
				title={ title }
				description={ description }
				icon={ icon }
				secondaryButton={ secondaryButton }
				info_tooltip={ info_tooltip }
			/>
			{ children }
		</div>
	);
};

export default PageContentWrapper;
