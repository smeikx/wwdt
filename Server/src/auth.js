'use strict';

const logged_in_users = new Set();

exports.isLoggedIn = (user_id) =>
{
	return logged_in_users.has(user_id);
}

exports.logIn = (user_id) =>
{
	logged_in_users.add(user_id);
}

exports.logOut = (user_id) =>
{
	logged_in_users.delete(user_id);
}

