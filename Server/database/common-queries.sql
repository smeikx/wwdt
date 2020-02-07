-- create project
INSERT INTO projects
	(title, description)
VALUES
	('Neues Projekt', 'Dieses Projekt dient reinen Demozwecken und hat deshalb wohl keine Zukunft – schade.');

SET @demo_project = (SELECT id FROM projects WHERE title = 'Neues Projekt');


-- create session + segment
INSERT INTO sessions
	(fk_project_id, title)
VALUES
	(@demo_project, 'Neue Session');

SET @demo_session = (SELECT id FROM sessions WHERE title = 'Neue Session');

INSERT INTO segments
	(fk_session_id, start_time)
VALUES
	(@demo_session, '2020-01-01 00:00:00');

UPDATE segments
SET
	end_time = '2020-01-01 00:42:00'
WHERE
	end_time = NULL;


-- create contributor
INSERT INTO contributors 
	(email_address, forename, surname)
VALUES
	('bo@jack.ch', 'Bojack', 'Pferdmann');

SET @demo_user = (SELECT id FROM contributor WHERE email_address = 'bo@jack.ch');


-- add contributor to session
INSERT INTO contributors_per_session
	(fk_session_id, fk_contributor_id)
VALUES
	(@demo_session, @demo_user);


-- assign session role to contributor
SET @demo_role = (SELECT id FROM roles WHERE title = 'Moderation');

INSERT INTO role_per_session
	(fk_project_id, fk_contributor_id, fk_role_id)
VALUES
	(@demo_project, @demo_user, @demo_role);


-- create mark + metadata + tags
INSERT INTO metadata
	(item_type, title, description, fk_creator_id, tags)
VALUES
	('mark', 'wichtiger Moment', 'hier passiert was Wichtiges', @demo_user, 'wichtig\ninteressant\naufschlussreich');

SET @demo_metadata = LAST_INSERT_ID();

INSERT INTO tags
	(fk_session_id, tag)
VALUES
	(@demo_session, 'wichtig'),
	(@demo_session, 'interessant'),
	(@demo_session, 'aufschlussreich');

INSERT INTO marks
	(fk_session_id, fk_metadata_id, timestamp)
VALUES
	(@demo_session, @demo_metadata, '2020-01-01 00:00:16');

-- rate item
-- 
