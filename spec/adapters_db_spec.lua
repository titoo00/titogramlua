local api = require('spec.test_helper')

describe('db adapter', function()
    describe('module', function()
        it('api.db exists', function()
            assert.is_table(api.db)
        end)

        it('has connect function', function()
            assert.is_function(api.db.connect)
        end)

        it('requires driver option', function()
            assert.has_error(function()
                api.db.connect({})
            end)
        end)

        it('rejects unsupported drivers', function()
            assert.has_error(function()
                api.db.connect({ driver = 'oracle' })
            end, 'Unsupported database driver: oracle. Supported: sqlite, postgres')
        end)
    end)

    describe('sqlite', function()
        local db

        before_each(function()
            db = api.db.connect({ driver = 'sqlite', path = ':memory:' })
        end)

        after_each(function()
            if db then db:close() end
        end)

        it('connects to in-memory database', function()
            assert.is_truthy(db)
            assert.is_true(db:is_connected())
        end)

        it('reports driver type', function()
            assert.equals('sqlite', db._driver)
        end)

        it('creates tables', function()
            local ok, err = db:execute('CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)')
            assert.is_true(ok)
        end)

        it('inserts and queries rows', function()
            db:execute('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)')
            db:execute('INSERT INTO users (id, name, age) VALUES (?, ?, ?)', {1, 'Alice', 30})
            db:execute('INSERT INTO users (id, name, age) VALUES (?, ?, ?)', {2, 'Bob', 25})

            local rows = db:query('SELECT * FROM users ORDER BY id')
            assert.equals(2, #rows)
            assert.equals('Alice', rows[1].name)
            assert.equals(30, rows[1].age)
            assert.equals('Bob', rows[2].name)
            assert.equals(25, rows[2].age)
        end)

        it('queries with WHERE parameters', function()
            db:execute('CREATE TABLE items (id INTEGER PRIMARY KEY, label TEXT)')
            db:execute('INSERT INTO items VALUES (?, ?)', {1, 'foo'})
            db:execute('INSERT INTO items VALUES (?, ?)', {2, 'bar'})
            db:execute('INSERT INTO items VALUES (?, ?)', {3, 'baz'})

            local rows = db:query('SELECT * FROM items WHERE id = ?', {2})
            assert.equals(1, #rows)
            assert.equals('bar', rows[1].label)
        end)

        it('returns empty table for no results', function()
            db:execute('CREATE TABLE empty_test (id INTEGER)')
            local rows = db:query('SELECT * FROM empty_test')
            assert.is_table(rows)
            assert.equals(0, #rows)
        end)

        it('reports changes count on execute', function()
            db:execute('CREATE TABLE counts (id INTEGER PRIMARY KEY, val TEXT)')
            db:execute('INSERT INTO counts VALUES (1, "a")')
            db:execute('INSERT INTO counts VALUES (2, "b")')
            db:execute('INSERT INTO counts VALUES (3, "c")')

            local ok, changes = db:execute('DELETE FROM counts WHERE id > ?', {1})
            assert.is_true(ok)
            assert.equals(2, changes)
        end)

        it('handles execute errors gracefully', function()
            local ok, err = db:execute('INSERT INTO nonexistent VALUES (1)')
            assert.is_false(ok)
            assert.is_string(err)
        end)

        it('handles query errors gracefully', function()
            local rows, err = db:query('SELECT * FROM nonexistent')
            assert.is_nil(rows)
            assert.is_string(err)
        end)

        describe('transactions', function()
            it('commits a transaction', function()
                db:execute('CREATE TABLE tx_test (id INTEGER PRIMARY KEY, val TEXT)')
                local ok = db:transaction(function(conn)
                    conn:execute('INSERT INTO tx_test VALUES (1, "a")')
                    conn:execute('INSERT INTO tx_test VALUES (2, "b")')
                end)
                assert.is_true(ok)
                local rows = db:query('SELECT * FROM tx_test')
                assert.equals(2, #rows)
            end)

            it('rolls back on error', function()
                db:execute('CREATE TABLE tx_rollback (id INTEGER PRIMARY KEY, val TEXT)')
                local ok, err = db:transaction(function(conn)
                    conn:execute('INSERT INTO tx_rollback VALUES (1, "a")')
                    error('deliberate error')
                end)
                assert.is_false(ok)
                assert.truthy(tostring(err):find('deliberate error'))
                local rows = db:query('SELECT * FROM tx_rollback')
                assert.equals(0, #rows)
            end)

            it('supports manual begin/commit', function()
                db:execute('CREATE TABLE manual_tx (id INTEGER)')
                db:begin()
                db:execute('INSERT INTO manual_tx VALUES (1)')
                db:execute('INSERT INTO manual_tx VALUES (2)')
                db:commit()
                local rows = db:query('SELECT * FROM manual_tx')
                assert.equals(2, #rows)
            end)

            it('supports manual rollback', function()
                db:execute('CREATE TABLE manual_rb (id INTEGER)')
                db:begin()
                db:execute('INSERT INTO manual_rb VALUES (1)')
                db:rollback()
                local rows = db:query('SELECT * FROM manual_rb')
                assert.equals(0, #rows)
            end)
        end)

        it('closes connection', function()
            db:close()
            assert.is_false(db:is_connected())
        end)

        it('handles NULL values', function()
            db:execute('CREATE TABLE nulls (id INTEGER, val TEXT)')
            db:execute('INSERT INTO nulls (id) VALUES (?)', {1})
            local rows = db:query('SELECT * FROM nulls')
            assert.equals(1, #rows)
            assert.equals(1, rows[1].id)
            assert.is_nil(rows[1].val)
        end)

        it('handles large datasets', function()
            db:execute('CREATE TABLE large (id INTEGER PRIMARY KEY, data TEXT)')
            db:begin()
            for i = 1, 1000 do
                db:execute('INSERT INTO large VALUES (?, ?)', {i, 'row_' .. i})
            end
            db:commit()
            local rows = db:query('SELECT COUNT(*) as cnt FROM large')
            assert.equals(1000, rows[1].cnt)
        end)

        it('handles multiple data types', function()
            db:execute('CREATE TABLE types (i INTEGER, r REAL, t TEXT, b BLOB)')
            db:execute('INSERT INTO types VALUES (?, ?, ?, ?)', {42, 3.14, 'hello', 'binary'})
            local rows = db:query('SELECT * FROM types')
            assert.equals(1, #rows)
            assert.equals(42, rows[1].i)
            assert.near(3.14, rows[1].r, 0.001)
            assert.equals('hello', rows[1].t)
        end)

        it('supports UPDATE operations', function()
            db:execute('CREATE TABLE updatable (id INTEGER PRIMARY KEY, val TEXT)')
            db:execute('INSERT INTO updatable VALUES (1, "old")')
            db:execute('UPDATE updatable SET val = ? WHERE id = ?', {'new', 1})
            local rows = db:query('SELECT val FROM updatable WHERE id = 1')
            assert.equals('new', rows[1].val)
        end)

        it('supports aggregations', function()
            db:execute('CREATE TABLE agg (val INTEGER)')
            for i = 1, 5 do
                db:execute('INSERT INTO agg VALUES (?)', {i * 10})
            end
            local rows = db:query('SELECT SUM(val) as total, AVG(val) as avg_val FROM agg')
            assert.equals(150, rows[1].total)
            assert.equals(30, rows[1].avg_val)
        end)

        it('accepts sqlite3 as driver alias', function()
            local db2 = api.db.connect({ driver = 'sqlite3', path = ':memory:' })
            assert.is_truthy(db2)
            assert.is_true(db2:is_connected())
            db2:close()
        end)

        describe('prepared statement cache', function()
            it('caches compiled statements keyed by sql', function()
                db:execute('CREATE TABLE cache_t (id INTEGER PRIMARY KEY, name TEXT)')
                -- repeated identical sql should reuse the same compiled statement
                db:execute('INSERT INTO cache_t VALUES (?, ?)', {1, 'a'})
                local first_stmt = db._stmt_cache['INSERT INTO cache_t VALUES (?, ?)']
                assert.is_truthy(first_stmt)
                db:execute('INSERT INTO cache_t VALUES (?, ?)', {2, 'b'})
                local second_stmt = db._stmt_cache['INSERT INTO cache_t VALUES (?, ?)']
                assert.equals(first_stmt, second_stmt)
            end)

            it('returns correct results across repeated reuse', function()
                db:execute('CREATE TABLE reuse_t (id INTEGER PRIMARY KEY, val TEXT)')
                for i = 1, 5 do
                    db:execute('INSERT INTO reuse_t VALUES (?, ?)', {i, 'v' .. i})
                end
                -- the same query string is reused with different parameters; each
                -- call must reflect the bound parameter, not a stale binding.
                for i = 1, 5 do
                    local rows = db:query('SELECT val FROM reuse_t WHERE id = ?', {i})
                    assert.equals(1, #rows)
                    assert.equals('v' .. i, rows[1].val)
                end
            end)

            it('reuses a query statement and stays correct after a write', function()
                db:execute('CREATE TABLE mix_t (id INTEGER PRIMARY KEY, val TEXT)')
                db:execute('INSERT INTO mix_t VALUES (1, "old")')
                local r1 = db:query('SELECT val FROM mix_t WHERE id = ?', {1})
                assert.equals('old', r1[1].val)
                db:execute('UPDATE mix_t SET val = ? WHERE id = ?', {'new', 1})
                -- same cached SELECT statement, must observe the updated row
                local r2 = db:query('SELECT val FROM mix_t WHERE id = ?', {1})
                assert.equals('new', r2[1].val)
            end)

            it('clears the cache on close', function()
                db:execute('CREATE TABLE close_t (id INTEGER)')
                db:execute('INSERT INTO close_t VALUES (?)', {1})
                assert.truthy(next(db._stmt_cache))
                db:close()
                assert.is_nil(next(db._stmt_cache))
                db = nil -- prevent after_each from double-closing
            end)
        end)
    end)
end)
