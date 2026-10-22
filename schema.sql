PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS users (
 id TEXT PRIMARY KEY, username TEXT NOT NULL UNIQUE, display_name TEXT NOT NULL,
 avatar_key TEXT, bio TEXT NOT NULL DEFAULT '',
 role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user','moderator','admin')),
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS sessions (
 id_hash TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 expires_at TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS chats (
 id TEXT PRIMARY KEY, kind TEXT NOT NULL CHECK (kind IN ('direct','group','channel','bot')),
 title TEXT NOT NULL DEFAULT '', owner_id TEXT NOT NULL REFERENCES users(id),
 description TEXT NOT NULL DEFAULT '', is_public INTEGER NOT NULL DEFAULT 0,
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS chat_members (
 chat_id TEXT NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
 user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 member_role TEXT NOT NULL DEFAULT 'member' CHECK (member_role IN ('member','admin','owner')),
 joined_at TEXT NOT NULL DEFAULT (datetime('now')), PRIMARY KEY (chat_id,user_id)
);
CREATE TABLE IF NOT EXISTS messages (
 id TEXT PRIMARY KEY, chat_id TEXT NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
 sender_id TEXT NOT NULL REFERENCES users(id), reply_to_id TEXT REFERENCES messages(id),
 forwarded_from_id TEXT REFERENCES messages(id), body TEXT NOT NULL DEFAULT '',
 media_key TEXT, media_type TEXT, deleted_at TEXT,
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_messages_chat_created ON messages(chat_id,created_at);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id,created_at);
CREATE TABLE IF NOT EXISTS reactions (
 message_id TEXT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
 user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE, emoji TEXT NOT NULL,
 created_at TEXT NOT NULL DEFAULT (datetime('now')), PRIMARY KEY (message_id,user_id,emoji)
);
CREATE TABLE IF NOT EXISTS comments (
 id TEXT PRIMARY KEY, message_id TEXT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
 user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE, body TEXT NOT NULL,
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS bot_tokens (
 token_hash TEXT PRIMARY KEY, bot_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 created_at TEXT NOT NULL DEFAULT (datetime('now')), revoked_at TEXT
);
CREATE TABLE IF NOT EXISTS reports (
 id TEXT PRIMARY KEY, reporter_id TEXT NOT NULL REFERENCES users(id),
 message_id TEXT REFERENCES messages(id) ON DELETE SET NULL, reason TEXT NOT NULL,
 status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','reviewing','closed')),
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
