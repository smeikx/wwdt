-- last tested with mariadb Ver 15.1 Distrib 10.4.10-MariaDB

CREATE OR REPLACE DATABASE tisch
	CHARACTER SET = 'utf8mb4'
	COLLATE = 'utf8mb4_german2_ci';

USE tisch;



CREATE TABLE projects (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(127) NOT NULL UNIQUE,
	creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	description VARCHAR(2047)
);



CREATE TABLE sessions (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_project_id INT NOT NULL,
		FOREIGN KEY(fk_project_id) REFERENCES projects(id),
	title VARCHAR(127) NOT NULL,
	default_permission BIT(2) DEFAULT b'10'
);

/* PERMISSIONS
are of type BIT(2)
------------------
00 → invisible
01 → visible
10 → editable */


CREATE TABLE session_timestamps (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	end_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- known types of media files
CREATE TABLE media_types (
	id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	media_type VARCHAR(63) NOT NULL UNIQUE
);



-- (semi) automatic recordings (audio & video)
CREATE TABLE recordings (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	media_type ENUM('audio', 'video') NOT NULL,
	creation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	duration INT UNSIGNED, -- in seconds
	file_path VARCHAR(255) NOT NULL UNIQUE
);


CREATE TABLE transcripts (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_record_id INT NOT NULL,
		FOREIGN KEY(fk_record_id) REFERENCES recordings(id),
	file_path VARCHAR(255) NOT NULL UNIQUE
);



-- list of all contributors
-- XXX: password not yet in use!
CREATE TABLE contributors (
	id INT AUTO_INCREMENT PRIMARY KEY,
	email_address VARCHAR(254) NOT NULL UNIQUE, -- https://stackoverflow.com/a/7717596
	forename VARCHAR(127) NOT NULL,
	surname VARCHAR(127),
	password VARCHAR(63) /*, NOT NULL*/
);


CREATE TABLE project_roles (
	id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(127) UNIQUE NOT NULL,
	description VARCHAR(127)
);


CREATE TABLE session_roles (
	id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(127) UNIQUE NOT NULL,
	description VARCHAR(127)
);


CREATE TABLE role_per_project (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_project_id INT NOT NULL,
		FOREIGN KEY(fk_project_id) REFERENCES projects(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES project_roles(id)
);


CREATE TABLE role_per_session (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES session_roles(id)
);


-- allows to track who participated in a session without them directly uploading anything
CREATE TABLE contributors_per_session (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),

	CONSTRAINT unique_contributor_per_session
		UNIQUE (fk_session_id, fk_contributor_id)
);



-- Paths match the following pattern:
-- …/project_title-id/session_title-id/contributor_name-id/upload_id.foo
CREATE TABLE uploads (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	upload_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	upload_name VARCHAR(255) NOT NULL,
	display_name VARCHAR(255) NOT NULL,
	file_path VARCHAR(511) UNIQUE NOT NULL,
	media_type TINYINT UNSIGNED,
		FOREIGN KEY(media_type) REFERENCES media_types(id)
);


-- marks are time-bound, user-generated pieces of information
CREATE TABLE marks (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	creation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	title VARCHAR(127) NOT NULL,
	description TEXT
);


CREATE TABLE timestamps_per_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_mark_id INT NOT NULL UNIQUE, -- not PRIMARY to potentially allow multiple timestamps per mark
		FOREIGN KEY(fk_mark_id) REFERENCES marks(id),
	`timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- tags for associating marks with each other
-- each tag exists only once per session
CREATE TABLE tags (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	title VARCHAR(63) NOT NULL,

	CONSTRAINT unique_tag_per_session
		UNIQUE (fk_session_id, title)
);



CREATE TABLE tags_per_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_mark_id INT NOT NULL,
		FOREIGN KEY(fk_mark_id) REFERENCES marks(id),
	fk_tag_id INT NOT NULL,
		FOREIGN KEY(fk_tag_id) REFERENCES tags(id),

	CONSTRAINT unique_tag_per_mark
		UNIQUE (fk_mark_id, fk_tag_id)
);


CREATE TABLE tags_per_upload (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_upload_id INT NOT NULL,
		FOREIGN KEY(fk_upload_id) REFERENCES uploads(id),
	fk_tag_id INT NOT NULL,
		FOREIGN KEY(fk_tag_id) REFERENCES tags(id)
);


-- deliberately allows multiple positions per timestamped mark
-- coordinates range between 0 and 1, describing the position relative to the upper left corner of a frame
CREATE TABLE frame_positions_per_timestamped_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_timestamped_mark_id INT NOT NULL,
		FOREIGN KEY(fk_timestamped_mark_id) REFERENCES timestamps_per_mark(id),
	fk_recording_id INT NOT NULL,
		FOREIGN KEY(fk_recording_id) REFERENCES recordings(id),
	x FLOAT UNSIGNED NOT NULL,
	y FLOAT UNSIGNED NOT NULL,

	CONSTRAINT unique_recording_per_timestamped_mark
		UNIQUE (fk_timestamped_mark_id, fk_recording_id)
);


-- files are always bound to a mark
CREATE TABLE uploads_per_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_mark_id INT NOT NULL,
		FOREIGN KEY(fk_mark_id) REFERENCES marks(id),
	fk_upload_id INT NOT NULL,
		FOREIGN KEY(fk_upload_id) REFERENCES uploads(id)
);



CREATE TABLE arrangements (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	title VARCHAR(127) NOT NULL,
	description VARCHAR(511),
	creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- coordinates refer to a single cell and are relative to the centre of the grid
-- (0, 0 is the cell in the centre)


CREATE TABLE marks_per_arrangement (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arrangement_id INT NOT NULL,
		FOREIGN KEY(fk_arrangement_id) REFERENCES arrangements(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_mark_id INT NOT NULL,
		FOREIGN KEY(fk_mark_id) REFERENCES marks(id),
	x INT NOT NULL,
	y INT NOT NULL
);


CREATE TABLE labels_per_arrangement (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arrangement_id INT NOT NULL,
		FOREIGN KEY(fk_arrangement_id) REFERENCES arrangements(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	title VARCHAR(127) NOT NULL,
	description VARCHAR(511),
	x INT NOT NULL,
	y INT NOT NULL
);


CREATE TABLE connections_per_arrangement (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arrangement_id INT NOT NULL,
		FOREIGN KEY(fk_arrangement_id) REFERENCES arrangements(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	from_x INT NOT NULL,
	from_y INT NOT NULL,
	to_x INT NOT NULL,
	to_y INT NOT NULL
);



CREATE TABLE permission_per_upload (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_upload_id INT NOT NULL,
		FOREIGN KEY(fk_upload_id) REFERENCES uploads(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	permission BIT(2) NOT NULL
);


CREATE TABLE permission_per_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_mark_id INT NOT NULL,
		FOREIGN KEY(fk_mark_id) REFERENCES marks(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	permission BIT(2) NOT NULL
);


CREATE TABLE permission_per_arrangement (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arrangement_id INT NOT NULL,
		FOREIGN KEY(fk_arrangement_id) REFERENCES arrangements(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	permission BIT(2) NOT NULL
);


CREATE TABLE permission_per_session_role (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES session_roles(id),
	permission BIT(2) NOT NULL
);


CREATE TABLE permission_per_project_role (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES project_roles(id),
	permission BIT(2) NOT NULL
);

