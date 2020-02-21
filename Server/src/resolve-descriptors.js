exports.projects =
{
	nested_fields:
	{
		sessions: [{selection: 'root', fields: 'id'}],
		contributors: [{selection: 'sessions,' fields: 'id'}]
	}
}

