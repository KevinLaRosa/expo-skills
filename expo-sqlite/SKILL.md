---
name: expo-sqlite
description: Store and query local data with SQLite in React Native using expo-sqlite or ultra-fast nitro-sqlite with migrations, transactions, and ORM support
license: MIT
compatibility: "Requires: Expo SDK 50+ (expo-sqlite) or React Native 0.71+ (nitro-sqlite), SQLite knowledge"
---

# Expo SQLite

## Overview

Store and query local data with SQLite databases in React Native apps using either `expo-sqlite` (official Expo package) or `nitro-sqlite` (ultra-fast Margelo implementation with 15x better performance).

## When to Use This Skill

- Need local database storage with SQL queries
- Storing structured data (users, transactions, logs, etc.)
- Offline-first applications
- Complex queries with joins and aggregations
- Data persistence across app restarts
- Migrations and schema versioning
- Need full-text search (FTS5)

**Choose expo-sqlite when**:
- Using Expo Go (development)
- Simple to moderate query complexity
- Standard performance requirements
- Want built-in React hooks and context

**Choose nitro-sqlite when**:
- Need maximum performance (15x faster)
- Heavy database operations
- Production apps with large datasets
- Want synchronous query execution
- Building custom database libraries

## Workflow

### Step 1: Choose SQLite Implementation

**Option A: expo-sqlite** (Official, Expo-compatible)
```bash
npx expo install expo-sqlite
```

**Option B: nitro-sqlite** (Ultra-fast, Nitro Modules)
```bash
npm install react-native-nitro-sqlite react-native-nitro-modules
npx pod-install
```

### Step 2: Open Database (expo-sqlite)

```typescript
import * as SQLite from 'expo-sqlite';

// Open database
const db = await SQLite.openDatabaseAsync('myDatabase.db');

// Create table
await db.execAsync(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    created_at INTEGER DEFAULT (strftime('%s', 'now'))
  );
`);
```

### Step 3: Execute Queries (expo-sqlite)

**Insert data**:
```typescript
// Using prepared statements (prevents SQL injection)
const result = await db.runAsync(
  'INSERT INTO users (name, email) VALUES (?, ?)',
  'John Doe',
  'john@example.com'
);

console.log('Inserted ID:', result.lastInsertRowId);
console.log('Rows affected:', result.changes);
```

**Query data**:
```typescript
// Get single row
const user = await db.getFirstAsync<{ id: number; name: string; email: string }>(
  'SELECT * FROM users WHERE email = ?',
  'john@example.com'
);

// Get all rows
const allUsers = await db.getAllAsync<{ id: number; name: string }>(
  'SELECT id, name FROM users ORDER BY name'
);

// Iterate rows (memory-efficient)
for await (const user of db.getEachAsync('SELECT * FROM users')) {
  console.log(user.name);
}
```

**Update and delete**:
```typescript
// Update
await db.runAsync(
  'UPDATE users SET name = ? WHERE id = ?',
  'Jane Doe',
  1
);

// Delete
await db.runAsync('DELETE FROM users WHERE id = ?', 1);
```

### Step 4: Transactions (expo-sqlite)

```typescript
// Automatic rollback on error
await db.withTransactionAsync(async () => {
  await db.runAsync('INSERT INTO users (name, email) VALUES (?, ?)', 'Alice', 'alice@example.com');
  await db.runAsync('INSERT INTO users (name, email) VALUES (?, ?)', 'Bob', 'bob@example.com');
  // If any query fails, entire transaction rolls back
});

// Exclusive transaction (locks database)
await db.withExclusiveTransactionAsync(async () => {
  // No other transactions can run simultaneously
  const users = await db.getAllAsync('SELECT * FROM users');
  // Process users...
});
```

### Step 5: React Integration (expo-sqlite)

**Using Context Provider**:
```typescript
import { SQLiteProvider, useSQLiteContext } from 'expo-sqlite';
import { Suspense } from 'react';

export default function App() {
  return (
    <Suspense fallback={<Text>Loading database...</Text>}>
      <SQLiteProvider
        databaseName="myDatabase.db"
        onInit={async (db) => {
          await db.execAsync(`
            CREATE TABLE IF NOT EXISTS users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL
            );
          `);
        }}
      >
        <UserList />
      </SQLiteProvider>
    </Suspense>
  );
}

function UserList() {
  const db = useSQLiteContext();
  const [users, setUsers] = useState([]);

  useEffect(() => {
    async function loadUsers() {
      const result = await db.getAllAsync('SELECT * FROM users');
      setUsers(result);
    }
    loadUsers();
  }, []);

  return <FlatList data={users} ... />;
}
```

### Step 6: Migrations (expo-sqlite)

```typescript
import { migrateDbIfNeeded } from 'expo-sqlite';

async function setupDatabase() {
  const db = await SQLite.openDatabaseAsync('myDatabase.db');

  await migrateDbIfNeeded(db, {
    1: async (db) => {
      // Version 1: Initial schema
      await db.execAsync(`
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        );
      `);
    },
    2: async (db) => {
      // Version 2: Add email column
      await db.execAsync('ALTER TABLE users ADD COLUMN email TEXT;');
    },
    3: async (db) => {
      // Version 3: Add index
      await db.execAsync('CREATE INDEX idx_users_email ON users(email);');
    },
  });

  return db;
}
```

### Step 7: Using nitro-sqlite (Performance)

**Basic usage**:
```typescript
import { open } from 'react-native-nitro-sqlite';

// Open database
const db = open({ name: 'myDatabase.sqlite' });

// Synchronous queries (ultra-fast)
const { rows } = db.execute('SELECT * FROM users WHERE id = ?', [1]);

// Async queries (background thread)
const result = await db.executeAsync('SELECT * FROM users');

// Transactions with rollback
db.transaction((tx) => {
  tx.execute('INSERT INTO users (name) VALUES (?)', ['Alice']);
  tx.execute('INSERT INTO users (name) VALUES (?)', ['Bob']);
  // throw new Error() to rollback
});

// Batch operations
db.executeBatch([
  ['INSERT INTO users (name) VALUES (?)', ['User1']],
  ['INSERT INTO users (name) VALUES (?)', ['User2']],
  ['INSERT INTO users (name) VALUES (?)', ['User3']],
]);
```

## Guidelines

**Do:**
- Always use prepared statements (prevents SQL injection)
- Use transactions for multiple related operations
- Create indexes on frequently queried columns
- Use migrations for schema changes
- Close databases when done (cleanup)
- Use FTS5 for full-text search
- Profile queries with EXPLAIN QUERY PLAN
- Normalize data to reduce redundancy

**Don't:**
- Don't concatenate user input into SQL strings (SQL injection risk)
- Don't perform heavy queries on main thread (use async)
- Don't forget to handle errors (try/catch)
- Don't store large blobs (use file system + store paths)
- Don't skip migrations (maintain schema versions)
- Don't use SELECT * (specify columns needed)
- Don't query inside render (use useEffect/useState)

## Examples

### Full-Text Search (FTS5)

```typescript
// Create FTS5 table
await db.execAsync(`
  CREATE VIRTUAL TABLE articles_fts USING fts5(
    title,
    content,
    author
  );
`);

// Insert searchable data
await db.runAsync(
  'INSERT INTO articles_fts (title, content, author) VALUES (?, ?, ?)',
  'React Native Performance',
  'How to optimize your React Native app...',
  'John Doe'
);

// Search
const results = await db.getAllAsync(
  "SELECT * FROM articles_fts WHERE articles_fts MATCH 'optimize'",
);
```

### TypeScript Type Safety

```typescript
type User = {
  id: number;
  name: string;
  email: string;
  created_at: number;
};

const users = await db.getAllAsync<User>('SELECT * FROM users');
// users is typed as User[]

const user = await db.getFirstAsync<User>('SELECT * FROM users WHERE id = ?', 1);
// user is typed as User | null
```

### Using with Drizzle ORM

```typescript
import { drizzle } from 'drizzle-orm/expo-sqlite';
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import * as SQLite from 'expo-sqlite';

const users = sqliteTable('users', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  name: text('name').notNull(),
  email: text('email').unique(),
});

const expo = SQLite.openDatabaseSync('myDatabase.db');
const db = drizzle(expo);

// Type-safe queries
const allUsers = await db.select().from(users);
const user = await db.insert(users).values({
  name: 'John',
  email: 'john@example.com',
});
```

### Key-Value Store

```typescript
import { openDatabaseSync, type SQLiteDatabase } from 'expo-sqlite';
import { createKysely } from 'expo-sqlite/kysely';

// Use built-in KV store
import { KVStore } from 'expo-sqlite/kv-store';

const db = openDatabaseSync('myDatabase.db');
const kv = new KVStore(db);

// Set values
await kv.setItem('theme', 'dark');
await kv.setItem('user', { id: 1, name: 'John' });

// Get values
const theme = await kv.getItem('theme');  // 'dark'
const user = await kv.getItem('user');    // { id: 1, name: 'John' }
```

### Database Encryption (SQLCipher)

```typescript
import * as SQLite from 'expo-sqlite';

// Open encrypted database
const db = await SQLite.openDatabaseAsync('encrypted.db', {
  enableCRSQLite: true,
  encryptionKey: 'your-secure-key-here',
});

// Use normally - data is encrypted at rest
```

### Performance: expo-sqlite vs nitro-sqlite

```typescript
// expo-sqlite (async, moderate performance)
const db = await SQLite.openDatabaseAsync('myDatabase.db');
const users = await db.getAllAsync('SELECT * FROM users');  // ~50ms for 1000 rows

// nitro-sqlite (sync, ultra-fast)
import { open } from 'react-native-nitro-sqlite';
const db = open({ name: 'myDatabase.sqlite' });
const { rows } = db.execute('SELECT * FROM users');  // ~3ms for 1000 rows (15x faster)
```

### Attach Multiple Databases

```typescript
// nitro-sqlite only
db.execute('ATTACH DATABASE ? AS secondary', ['./secondary.db']);

// Query across databases
const results = db.execute(`
  SELECT main.users.*, secondary.orders.*
  FROM users
  JOIN secondary.orders ON users.id = orders.user_id
`);
```

## Resources

- [Expo SQLite Docs](https://docs.expo.dev/versions/latest/sdk/sqlite/)
- [Nitro SQLite GitHub](https://github.com/margelo/react-native-nitro-sqlite)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Drizzle ORM](https://orm.drizzle.team/)
- [FTS5 Full-Text Search](https://www.sqlite.org/fts5.html)

## Tools & Commands

- `npx expo install expo-sqlite` - Install Expo SQLite
- `npm install react-native-nitro-sqlite` - Install Nitro SQLite
- `.schema` - View table schemas (in SQLite CLI)
- `EXPLAIN QUERY PLAN` - Analyze query performance

## Troubleshooting

### SQL syntax errors

**Problem**: Query fails with syntax error

**Solution**:
1. Test query in [SQLite Online](https://sqliteonline.com/)
2. Check prepared statement placeholders (`?`)
3. Verify table/column names
4. Use backticks for reserved keywords: `` `order` ``

### Database locked

**Problem**: "database is locked" error

**Solution**:
```typescript
// Use exclusive transaction for write operations
await db.withExclusiveTransactionAsync(async () => {
  await db.runAsync('INSERT ...');
});

// Or for nitro-sqlite
db.transaction((tx) => {
  tx.execute('INSERT ...');
});
```

### Migration fails

**Problem**: Migration doesn't run or fails

**Solution**:
```typescript
// Check current version
const version = await db.getFirstAsync<{ user_version: number }>(
  'PRAGMA user_version'
);
console.log('Current version:', version.user_version);

// Drop and recreate (development only!)
await db.execAsync('DROP TABLE IF EXISTS users');
```

### Performance issues

**Problem**: Queries are slow

**Solution**:
1. Add indexes: `CREATE INDEX idx_users_email ON users(email)`
2. Use `EXPLAIN QUERY PLAN` to check query execution
3. Batch operations in transactions
4. Consider nitro-sqlite for 15x performance boost
5. Limit result sets: `LIMIT 100`

### TypeScript type errors

**Problem**: Query results not typed correctly

**Solution**:
```typescript
// Define type explicitly
type User = { id: number; name: string };
const users = await db.getAllAsync<User>('SELECT id, name FROM users');

// Or use Drizzle ORM for automatic typing
```

---

## Notes

- expo-sqlite works with Expo Go (development)
- nitro-sqlite requires custom dev client (faster, production-ready)
- FTS3, FTS4, FTS5 enabled by default in expo-sqlite
- SQLCipher encryption available via config plugin
- Drizzle ORM and Knex.js supported for type-safe queries
- Performance: nitro-sqlite ~15x faster than expo-sqlite
- Both support iOS, Android, Web (expo-sqlite only)
- Use transactions for data integrity
- Always use prepared statements (security)
