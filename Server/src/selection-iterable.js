'use strict';

// an Iterable for extracting selections
// it keeps track of (nested) fragments
// TODO: handle multiple FieldNodes entries (https://github.com/graphql/graphql-js/issues/2304)

class SelectionIterable
{
	// needs either ‘info’ OR ‘selections’ and ‘fragments’
	constructor ({info, selections, fragments})
	{
		if (info)
		{
			this.selections = info.fieldNodes[0].selectionSet.selections;
			this.fragments = info.fragments;
		}
		else
		{
			this.selections = selections;
			this.fragments = fragments;
		}
	}

	* [Symbol.iterator] ()
	{
		for (const selection of this.selections)
		{
			if (selection.kind == 'FragmentSpread')
			{
				const fragment = new SelectionIterable({
					selections: this.fragments[selection.name.value].selectionSet.selections,
					fragments: this.fragments
				});
				for (const frag_selection of fragment)
					yield frag_selection;
			}
			else
				yield {
					name: selection.name.value,
					sub_selections: selection.selectionSet.selections
				};
		}
	}
}

exports.SelectionIterable = SelectionIterable;
