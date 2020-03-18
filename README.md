[![](https://img.shields.io/travis/com/ckaserer/docker-j2cli/master?style=flat-square)](https://travis-ci.com/ckaserer/docker-j2cli)
![Docker Pulls](https://img.shields.io/docker/pulls/ckaserer/j2cli?color=brightgreen&style=flat-square)
![gplv3](https://img.shields.io/badge/license-GPL%20v3.0-brightgreen.svg?style=flat-square)
![Maintenance](https://img.shields.io/maintenance/yes/2020?style=flat-square)
<br>
<br>

# docker-j2cli

If you want to work with jinja templates from your commandline and want to reduce the risk of "works on my machine". Try our j2cli container image.

## Bonus Features
* base64 encoding and decoding filters for your kubernetes resource files

---

## Preflight

Okay, the whole point is to avoid installing j2 cli on our workstations. To avoid local installation we will use container technology as our abstraction layer.

Therefore we will need to install a container runtime. Please install `docker` on your workstation if you haven't done so already.

In order to make it easier to use j2 as a container a few bash functions are available in the `bashrc` of the git [repository](https://github.com/gepardec/docker-j2cli). I really recommend that you source the [bashrc](https://raw.githubusercontent.com/gepardec/docker-j2cli/master/bashrc) - it abstracts away all the options and parameter used in the docker command for you. In the next section you will see why.

```
source bashrc
```

However it is not just black magic - all commands that are available via the bashrc in this repository will be printed before execution to increase transparency.

---

### Run your j2 command in a container

Just like you would run your j2 command locally you can do so with the `bashrc` function `docker-j2cli`. e.g. to get the cli version of the `j2cli` image you are using simply run

```
docker-j2cli j2 --version
```

which wraps following command for ease of use

```
docker run --rm -it -e TZ=Europe/Vienna -v /home/myuser/path/to/your/current/directory:/mnt gepardec/j2cli j2 --version
```

As you can see the container you are using is deleted after it ran with `--rm`, set the timezone to Europe/Vienna, mount your current directory into the container to alter files on your workstation from the container.

---

## Tutorial

Suppose, you want to have an nginx configuration file template, `nginx.j2`:

```jinja2
server {
  listen 80;
  server_name {{ nginx.hostname }};

  root {{ nginx.webroot }};
  index index.htm;
}
```

And you have a JSON file with the data, `nginx.json`:

```json
{
    "nginx":{
        "hostname": "localhost",
        "webroot": "/var/www/project"
    }
}
```

This is how you render it into a working configuration file:

```bash
$ j2 -f json nginx.j2 nginx.json > nginx.conf
```

The output is saved to `nginx.conf`:

```
server {
  listen 80;
  server_name localhost;

  root /var/www/project;
  index index.htm;
}
```

Alternatively, you can use the `-o nginx.conf` option.

## Tutorial with environment variables

Suppose, you have a very simple template, `person.xml`:

```jinja2
<data><name>{{ name }}</name><age>{{ age }}</age></data>
```

What is the easiest way to use j2 here?
Use environment variables in your bash script:

```bash
$ export name=Andrew
$ export age=31
$ j2 /tmp/person.xml
<data><name>Andrew</name><age>31</age></data>
```

## Using environment variables

Even when you use yaml or json as the data source, you can always access environment variables
using the `env()` function:

```jinja2
Username: {{ login }}
Password: {{ env("APP_PASSWORD") }}
```


## Usage

Compile a template using INI-file data source:

    $ j2 config.j2 data.ini
    
Compile using JSON data source:

    $ j2 config.j2 data.json
    
Compile using YAML data source (requires PyYAML):

    $ j2 config.j2 data.yaml

Compile using JSON data on stdin:

    $ curl http://example.com/service.json | j2 --format=json config.j2

Compile using environment variables (hello Docker!):
    
    $ j2 config.j2
    
Or even read environment variables from a file:

    $ j2 --format=env config.j2 data.env

Or pipe it: (note that you'll have to use the "-" in this particular case):

    $ j2 --format=env config.j2 - < data.env

    
# Reference
`j2` accepts the following arguments:

* `template`: Jinja2 template file to render
* `data`: (optional) path to the data used for rendering.
    The default is `-`: use stdin. Specify it explicitly when using env!

Options:

* `--format, -f`: format for the data file. The default is `?`: guess from file extension.
* `--import-env VAR, -e EVAR`: import all environment variables into the template as `VAR`.
    To import environment variables into the global scope, give it an empty string: `--import-env=`.
    (This will overwrite any existing variables!)
* `-o outfile`: Write rendered template to a file
* `--undefined`: Allow undefined variables to be used in templates (no error will be raised)

* `--filters filters.py`: Load custom Jinja2 filters and tests from a Python file.
    Will load all top-level functions and register them as filters.
    This option can be used multiple times to import several files.
* `--tests tests.py`: Load custom Jinja2 filters and tests from a Python file.
* `--customize custom.py`: A Python file that implements hooks to fine-tune the j2cli behavior.
    This is fairly advanced stuff, use it only if you really need to customize the way Jinja2 is initialized.
    See [Customization](#customization) for more info.

There is some special behavior with environment variables:

* When `data` is not provided (data is `-`), `--format` defaults to `env` and thus reads environment variables
* When `--format=env`, it can read a special "environment variables" file made like this: `env > /tmp/file.env`

## Formats


### env
Data input from environment variables.

Render directly from the current environment variable values:

    $ j2 config.j2

Or alternatively, read the values from a dotenv file:

```
NGINX_HOSTNAME=localhost
NGINX_WEBROOT=/var/www/project
NGINX_LOGS=/var/log/nginx/
```

And render with:

    $ j2 config.j2 data.env
    $ env | j2 --format=env config.j2

If you're going to pipe a dotenv file into `j2`, you'll need to use "-" as the second argument to explicitly:

    $ j2 config.j2 - < data.env

### ini
INI data input format.

data.ini:

```
[nginx]
hostname=localhost
webroot=/var/www/project
logs=/var/log/nginx/
```

Usage:

    $ j2 config.j2 data.ini
    $ cat data.ini | j2 --format=ini config.j2

### json
JSON data input format

data.json:

```
{
    "nginx":{
        "hostname": "localhost",
        "webroot": "/var/www/project",
        "logs": "/var/log/nginx/"
    }
}
```

Usage:

    $ j2 config.j2 data.json
    $ cat data.json | j2 --format=ini config.j2

### yaml
YAML data input format.

data.yaml:

```
nginx:
  hostname: localhost
  webroot: /var/www/project
  logs: /var/log/nginx
```

Usage:

    $ j2 config.j2 data.yml
    $ cat data.yml | j2 --format=yaml config.j2




Extras
======

## Filters


### `docker_link(value, format='{addr}:{port}')`
Given a Docker Link environment variable value, format it into something else.

This first parses a Docker Link value like this:

    DB_PORT=tcp://172.17.0.5:5432

Into a dict:

```python
{
  'proto': 'tcp',
  'addr': '172.17.0.5',
  'port': '5432'
}
```

And then uses `format` to format it, where the default format is '{addr}:{port}'.

More info here: [Docker Links](https://docs.docker.com/userguide/dockerlinks/)

### `env(varname, default=None)`
Use an environment variable's value inside your template.

This filter is available even when your data source is something other that the environment.

Example:

```jinja2
User: {{ user_login }}
Pass: {{ "USER_PASSWORD"|env }}
```

You can provide the default value:

```jinja2
Pass: {{ "USER_PASSWORD"|env("-none-") }}
```

For your convenience, it's also available as a function:

```jinja2
User: {{ user_login }}
Pass: {{ env("USER_PASSWORD") }}
```

Notice that there must be quotes around the environment variable name




Customization
=============

j2cli now allows you to customize the way the application is initialized:

* Pass additional keywords to Jinja2 environment
* Modify the context before it's used for rendering
* Register custom filters and tests

This is done through *hooks* that you implement in a customization file in Python language.
Just plain functions at the module level.

The following hooks are available:

* `j2_environment_params() -> dict`: returns a `dict` of additional parameters for
    [Jinja2 Environment](http://jinja.pocoo.org/docs/2.10/api/#jinja2.Environment).
* `j2_environment(env: Environment) -> Environment`: lets you customize the `Environment` object.
* `alter_context(context: dict) -> dict`: lets you modify the context variables that are going to be
    used for template rendering. You can do all sorts of pre-processing here.
* `extra_filters() -> dict`: returns a `dict` with extra filters for Jinja2
* `extra_tests() -> dict`: returns a `dict` with extra tests for Jinja2

All of them are optional.

The example customization.py file for your reference:

```python
# 
# Example customize.py file for j2cli
# Contains potional hooks that modify the way j2cli is initialized


def j2_environment_params():
    """ Extra parameters for the Jinja2 Environment """
    # Jinja2 Environment configuration
    # http://jinja.pocoo.org/docs/2.10/api/#jinja2.Environment
    return dict(
        # Just some examples

        # Change block start/end strings
        block_start_string='<%',
        block_end_string='%>',
        # Change variable strings
        variable_start_string='<<',
        variable_end_string='>>',
        # Remove whitespace around blocks
        trim_blocks=True,
        lstrip_blocks=True,
        # Enable line statements:
        # http://jinja.pocoo.org/docs/2.10/templates/#line-statements
        line_statement_prefix='#',
        # Keep \n at the end of a file
        keep_trailing_newline=True,
        # Enable custom extensions
        # http://jinja.pocoo.org/docs/2.10/extensions/#jinja-extensions
        extensions=('jinja2.ext.i18n',),
    )


def j2_environment(env):
    """ Modify Jinja2 environment

    :param env: jinja2.environment.Environment
    :rtype: jinja2.environment.Environment
    """
    env.globals.update(
        my_function=lambda v: 'my function says "{}"'.format(v)
    )
    return env


def alter_context(context):
    """ Modify the context and return it """
    # An extra variable
    context['ADD'] = '127'
    return context


def extra_filters():
    """ Declare some custom filters.

        Returns: dict(name = function)
    """
    return dict(
        # Example: {{ var | parentheses }}
        parentheses=lambda t: '(' + t + ')',
    )


def extra_tests():
    """ Declare some custom tests

        Returns: dict(name = function)
    """
    return dict(
        # Example: {% if a|int is custom_odd %}odd{% endif %}
        custom_odd=lambda n: True if (n % 2) else False
    )

# 

```
---

### Sources
* https://github.com/kolypto/j2cli