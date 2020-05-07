# askjanet

__A q & a site for janet__

If you're going to run this, make sure you drop a `.env` file in the root (the same folder as `project.janet`) that looks like this:

```
ENCRYPTION_KEY=<encryption key>
JOY_ENV=development
DATABASE_URL=<your database name>.sqlite3
MAILGUN_API_KEY=<your mailgun api key>
MAILGUN_BASE_URL=https://api.mailgun.net/v3/
MAILGUN_DOMAIN=<your mailgun domain>
```

### `<encryption key>`

This is a hex encoded [cipher](https://github.com/joy-framework/cipher) encryption key, go ahead and generate one from a janet repl with:

```clojure
(import cipher)

(cipher/bin2hex (cipher/encryption-key))
```

The rest of the `<>` stuff is largely up to you.

Happy hacking!
