exports.projects =
{
	nested_fields:
	{
		sessions: {
			depends_on: [{selection: 'root', fields: 'id'}],
			resolver: () => {}
		},
		contributors: {
			depends_on: [{selection: 'sessions,' fields: 'id'}],
			resolver: () => {}
		}
	}
}

/*
simpel & (beliebig oft) verschachtelt

*/
