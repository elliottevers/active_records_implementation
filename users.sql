CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  username VARCHAR(255),
  latitude REAL,
  longitude REAL,
  discovery_radius INTEGER
);

CREATE TABLE conversations(
  id INTEGER PRIMARY KEY,
  sender_id INTEGER,
  recipient_id INTEGER,

  FOREIGN KEY (sender_id) REFERENCES users(id)
);

CREATE TABLE messages(
  id INTEGER PRIMARY KEY,
  body TEXT,
  conversation_id INTEGER,
  user_id INTEGER,

  FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

  INSERT INTO
    users(id, username, latitude, longitude, discovery_radius)
  VALUES
    (1, "Roger", 47.5667, 7.6000, 50),
    (2, "Rafael", 40.4333, -3.7000, 50),
    (3, "Novak", 44.8000, 20.4667, 50);

  INSERT INTO
    conversations(id, sender_id, recipient_id)
  VALUES
    (1, 1, 2),
    (2, 2, 3);

  INSERT INTO
    messages(id, body, conversation_id, user_id)
  VALUES
    (1, "Roger to Rafa", 1, 1),
    (2, "Rafa to Roger", 1, 2),
    (3, "Rafa to Nole", 2, 2),
    (4, "Nole to Rafa", 2, 3);
