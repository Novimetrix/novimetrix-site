import PageContentWrapper from '@AdminComponents/page-content-wrapper';
import { __ } from '@wordpress/i18n';
import withSuspense from '@AdminComponents/hoc/with-suspense';
import GeneratePageContent from '@Functions/page-content-generator';
import { createLazyRoute } from '@tanstack/react-router';

export const PAGE_CONTENT = [
	{
		container: {
			direction: 'column',
			gap: 6,
		},
		content: [
			{
				id: 'author_archive',
				type: 'switch',
				storeKey: 'author_archive',
				label: __( 'Enable Author Archive', 'surerank' ),
				description: __(
					'Displays all posts published by a specific author. Useful for showcasing an author’s contributions and helping search engines understand authorship and topical relevance.',
					'surerank'
				),
			},
			{
				id: 'date_archive',
				type: 'switch',
				storeKey: 'date_archive',
				label: __( 'Enable Date Archive', 'surerank' ),
				description: __(
					'Groups posts by month or year. Helps visitors explore content chronologically and allows search engines to better index time-based content.',
					'surerank'
				),
			},
		],
	},
];

const ArchivePages = () => {
	return (
		<PageContentWrapper
			title={ __( 'Archive Pages', 'surerank' ) }
			description={ __(
				'Archive Pages let visitors access links to view posts by author or by date. This makes it easier for people to find content based on who wrote it or when it was published.',
				'surerank'
			) }
		>
			<GeneratePageContent json={ PAGE_CONTENT } />
		</PageContentWrapper>
	);
};

export const LazyRoute = createLazyRoute( '/archive_pages' )( {
	component: withSuspense( ArchivePages ),
} );

export default withSuspense( ArchivePages );
