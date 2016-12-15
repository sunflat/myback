# myback

This is a backup (dump) management tool for MySQL.

- mainly focused on rails application development
- only tested on macOS with rbenv

## Installation

```
$ gem install specific_install
$ gem specific_install sunflat/myback
```

## Usage

Make a `.env` file in the current directory with the following content:

```
MYBACK_DB_NAME=<database name>
MYBACK_BACKUP_DIR=<destination directory to make backup files>
```

Make a backup of the database.

```
$ myback backup BACKUP_NAME
```

Show backup list. A backup name has a timestamp suffix.

```
$ myback ls
BACKUP_NAME_2016_01_01_01_01_01
```

Restore the backup.

```
$ myback restore BACKUP_NAME_2016_01_01_01_01_01
```

Show more commands. See the implementation `lib/myback/cli.rb` for details!

```
$ myback help
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

