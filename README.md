# 🚲 shed

## Installation

Install with:

```sh
$ curl -fsSL https://raw.githubusercontent.com/apsislabs/shed/master/shed.sh | sh
```

Update with:

```sh
$ rake -g shed:self:update
```

or

```sh
$ shed self:update
```

## Usage

List all tasks with:

```sh
$ rake -T shed
```

Run a task with:

```sh
$ rake -g shed:{task_name}
```

## Helper

You can add the following function to your `.bashrc` or `.bash_profile`:

```sh
shed () {
	rake -g shed:$1
}
```

This gives you a global shorthand for running `shed` tasks.

```sh
$ shed init
$ shed bootstrap
```
