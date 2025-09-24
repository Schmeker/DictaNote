# dictanote

A new Flutter project.

## Getting Started

This project is contains a Flutter app, working together with a postgre sql database.

For the database:
-- Table: users
    CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

-- Table: lists
CREATE TABLE lists (
    id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    type INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table: items
    CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    list_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    completed BOOLEAN DEFAULT FALSE NOT NULL,
    amount VARCHAR(255),
    priority SMALLINT,
    updated_at TIMESTAMP NOT NULL,
    time_till TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (list_id) REFERENCES lists(id) ON DELETE CASCADE
);

-- Table: participates
CREATE TABLE participates (
    user_id INT NOT NULL,
    list_id INT NOT NULL,
    PRIMARY KEY (user_id, list_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (list_id) REFERENCES lists(id) ON DELETE CASCADE
);


