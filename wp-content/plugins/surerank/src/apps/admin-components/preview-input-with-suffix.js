import { Button, Input } from '@bsf/force-ui';
import { __ } from '@wordpress/i18n';
import { PencilLine } from 'lucide-react';

const PreviewInputWithSuffix = ( {
	value,
	onClick,
	suffix = null,
	placeholder = __( 'Enter your focus keyword', 'surerank' ),
	suffixProps = {},
	props = {},
} ) => {
	const handleClick = ( event ) => {
		event.preventDefault();
		event.stopPropagation();

		if ( typeof onClick !== 'function' ) {
			return;
		}

		onClick();
	};

	return (
		<Input
			className="[&_input]:transition-[color,outline] [&_input]:duration-200"
			size="md"
			placeholder={ placeholder }
			suffix={
				suffix ?? (
					<Button
						variant="ghost"
						className="p-0 m-0 cursor-pointer focus:[box-shadow:none] hover:bg-transparent pointer-events-auto"
						onClick={ handleClick }
						icon={
							<PencilLine
								className="size-5 text-icon-primary"
								strokeWidth={ 1.5 }
							/>
						}
						{ ...suffixProps }
					/>
				)
			}
			value={ value }
			readOnly
			{ ...props }
		/>
	);
};

export default PreviewInputWithSuffix;
