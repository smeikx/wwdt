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
10 → editable
11 → permission changeable
 */


CREATE TABLE episodes (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	end_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- known types of media files
CREATE TABLE media_types (
	id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	media_type VARCHAR(63) NOT NULL UNIQUE,
	description VARCHAR(511)
);



-- (semi) automatic recordings (audio & video)
CREATE TABLE recordings (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	recording_type ENUM('audio', 'video') NOT NULL,
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


-- combine project and session roles for structural simplicity
CREATE TABLE roles (
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
		FOREIGN KEY(fk_role_id) REFERENCES roles(id)
);


CREATE TABLE role_per_session (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES roles(id)
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


CREATE TABLE ratings_per_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_mark_id INT NOT NULL UNIQUE,
		FOREIGN KEY(fk_mark_id) REFERENCES marks(id),
	fk_contributor_id INT NOT NULL UNIQUE,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	rating TINYINT,

	CONSTRAINT unique_rating_per_user_per_mark
		UNIQUE (fk_mark_id, fk_contributor_id)
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


/* POSITION & SIZE
Coordinates refer to a single cell and are relative to the centre of the grid,
(0, 0 is the cell in the centre).
‘width’ and ‘height’ describe how far an object extends to the right and downwards respectively.
If width and height are both 0, the object occupies one cell.
*/

CREATE TABLE object_data (
	id INT AUTO_INCREMENT PRIMARY KEY,
	x INT NOT NULL,
	y INT NOT NULL,
	width INT UNSIGNED DEFAULT 0,
	height INT UNSIGNED DEFAULT 0
);


CREATE TABLE marks_per_arrangement (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arrangement_id INT NOT NULL,
		FOREIGN KEY(fk_arrangement_id) REFERENCES arrangements(id),
	fk_mark_id INT NOT NULL,
		FOREIGN KEY(fk_mark_id) REFERENCES marks(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_object_data_id INT NOT NULL,
		FOREIGN KEY(fk_object_data_id) REFERENCES object_data(id)
);


CREATE TABLE uploads_per_arrangement (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arrangement_id INT NOT NULL,
		FOREIGN KEY(fk_arrangement_id) REFERENCES arrangements(id),
	fk_upload_id INT NOT NULL,
		FOREIGN KEY(fk_upload_id) REFERENCES uploads(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_object_data_id INT NOT NULL,
		FOREIGN KEY(fk_object_data_id) REFERENCES object_data(id)
);


CREATE TABLE labels (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arrangement_id INT NOT NULL,
		FOREIGN KEY(fk_arrangement_id) REFERENCES arrangements(id),
	title VARCHAR(127) NOT NULL,
	describtion TEXT,
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_object_data_id INT NOT NULL,
		FOREIGN KEY(fk_object_data_id) REFERENCES object_data(id)
);


/* XXX ONE COLUMN, MULTIPLE DIFFERENT FOREIGN KEYS
In order to refer to different tables within one column,
an additional column containing an enum is used to keep
track of the referenced table:

	mark → marks_per_arrangement.id
	upload → uploads_per_arrangement.id
	label → labels.id

The enum approch has been chosen over more ‘correct’ methods,
(like https://stackoverflow.com/a/7844911), in order to
achieve better readability and easier to construct queries
*/

CREATE TABLE connections_per_arrangement (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	from_object_type ENUM('mark', 'upload', 'label') NOT NULL,
	fk_from_object_id INT NOT NULL,
	to_object_type ENUM('mark', 'upload', 'label') NOT NULL,
	fk_to_object_id INT NOT NULL
	-- TODO: create a TRIGGER, as proposed here:
	-- https://stackoverflow.com/a/56699758
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


CREATE TABLE permission_per_role (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES roles(id),
	permission BIT(2) NOT NULL
);

