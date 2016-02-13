---
layout: slidedeck
title: A Guide to Make
---

Eric Anderton - (c) 2016 - Version 1.0

This presentation is a tour of the main features and use of `Make`, 
the dependency management tool.

---
# A Guide to Make

Eric Anderton - (c) 2016 - Version 1.0

Presented using Reveal.js.

Press `SHIFT+P` to toggle presenter mode. Press `ESC`, or refresh your browser 
at any time to return to the cover page.

Note: *if you are viewing this deck alone, Presenter Mode is recommended
as not all the content is presented in the slides.*

---
# Outline

* Background
* Make BASHing
* Design
* Syntax
* Basic Example
* Variables
* Generic Targets
* Text Replacement
* Functions
* Extras
* Further Examples

---
# Background
 
* By Stuart Feldman in April 1976 at Bell Labs
* Ported to just about every platform imaginable, with many variants
* Many derivatives exist; most operating systems have one
* Abstracts dependency management from build steps

???
At first blush, 40 years seems like an eternity for a piece of software, 
yet both C and Unix are just as old.  All three enjoy daily use in some
shape or form even today.  Perhaps computing hasn't changed all *that*
much in half a century?

Make has its roots in C/C++ development, and is ideal for building large
compiled projects as we'll see in later slides.

Like any tool that tries to solve a particular problem, Make isn't a
one-size-fits-all proposition.  We see evidence of this by the presence
of tools like NMake, GNUMake, CMake, SCons, Ant, Paver, Grunt, Gulp, etc.

Make does, however, fit a large number of general cases that are usually
enough for most any project.  The core of Make, dependency management,
is just that: the very core of efficiently building just about anything.

---
# Make BASHing

* Depends on shell execution environment, which is usually BASH
* Can cause barriers to portability
* Oddball syntax quirks
* Is myopic; likes to focus on current directory
* Recursive Make is not fun
* Explicit, not implicit

???
Despite the fact that Make has been ported just about everywhere, it 
does not bring a shell environment along for the ride.  For better or
worse, Make will rely on your native shell environment, whatever
it may be.  For the most part, this isn't a problem for OSX and Linux,
but is a huge hurdle for Windows.

Make is actually shell agnostic, but you'll almost never see a Makefile
that doesn't rely on BASH.  At the same time, BASH also isn't 
everyone's favorite shell to code in.  It has an enormous amount of 
momentum by being the default on BSD/OSX/Linux, so it's more or less 
assumed to be the most reliable target.

As we'll see on later slides, Make's syntax is minimal, relies heavily
on Perl-like symbols for special substitutions, and absolutely needs
real TAB characters to distinguish targets from commands.

Make grew up in a world where filesystems were shallow and small.  A
properly groomed Makefile explicitly calls out all file dependencies,
which can be a challenge for big codebases and deep trees.  Also, 
the various macros provided for wrangling file paths/names don't work
very well with arbitrarily deep trees.

---
# Design

* Built around *file* dependency graph
* Everything goes in the Makefile
* Makefile has one or more targets
* Targets have dependencies and commands used to satisfy
* Targets are unsatisfied if older than dependencies, or do not exist
* Is done when all specified targets are satisfied
* Will grind to a halt if something fails (returns non-zero)


???
If you've developed any piece of software lately, you've probably run
into a Makefile or two.  The structure can be a little strange at first
but it's not hard to grasp.

The Makefile is made up of one or more targets, what files that target 
depends on, and what shell commands should be executed to satisfy the 
production. These usually read like rules 

Much of Make's odd syntax comes from providing shortcuts, variables, and
macros to make authoring of these targets easier, by eliminating
repetition.  In some cases, its possible to create general purpose
targets that can be entirely data-driven.

Make is run by specifying a target, usually a 'phony' target that
doesn't map to a file.  That target in turn relies on other files
that must be satisfied by Make.  This triggers all the dependency
rules and commands needed to satisfy the graph.

The way Make satisfies targets allows Make to only run the commands
that absolutely must be run.  A properly configured Makefile will
not do more work than is needed, saving the developer valuable time.

---
# Makefile Syntax

The core syntax of a Makefile is the following:
```
target: dependencies
[TAB] shell command
```

???
Here, `target` is a filename to be satisfied by Make. 

`target` is said to be *satisfied* by one or more `dependencies`.
These are other file names, which may be in and of themselves,
other targets.

The `[TAB]` prefixed `shell command`, is what Make will run if
`target` doesn't exist, or if `target` is *older* than any files
in `dependencies`.

Vi/Vim users will want to add `autocmd filetype make setlocal noexpandtab`
to their .rc files to avoid potential issues.  Other editors, 
like PyCharm might require more advanced tweaking to avoid tab
expansion.

So, if a programmer updates a source file, or deletes the target, 
Make will spring into action to run the needed commands to 
re-create `target`. 

Make brings much more to the table, which will be covered in later
slides.

---
# Basic Example

```
# basic makefile

myfile.txt: myfile.src
  cp myfile.src myfile.txt

all: myfile.txt

clean:
  -rm myfile.txt

.PHONY: clean, all
```
Lines prefixed with a `#` are comments and are ignored by Make

When `make myfile.txt` is run, Make executes the `cp` command above to 
satisfy the target.  Running `make all` has the same effect.

???
In this simple example, we have a Makefile that has three targets: 
one for a text file called `myfile.txt`, a target called `all`, 
and a target called `clean`..

Running `make myfile.txt` will generate the file if, and only if, it
doesn't already exist.

Running `make all` will also trigger the `myfile.txt` target, since
it depends on that file.

The `clean` target is special.  It has no dependencies, and will
remove `myfile.txt`, as the name suggests.  The dash at the start
of the line tells Make to ignore the return code - Make won't exit
prematurely if the `rm` command fails.

The `.PHONY` target at the bottom is a special kind of target that 
Make treats differently than other targets.

`.PHONY` tells make that `all` and `clean` aren't
real files, and that it should ignore those files if they happen to 
exist in the current directory.

`.PHONY` effectively lets us configure Make to have arbitrary
(and convienent) targets, instead of having to specify files to be 
built.  As a convention, most Makefiles have `all` and `clean` targets.


---
# Basic Example Output
```
make myfile.txt
$ make myfile.txt
cp myfile.src myfile.txt

$ make myfile.txt
make: `myfile.txt' is up to date.

$ make clean
rm myfile.txt

$ make all
cp myfile.src myfile.txt

$ make all
make: Nothing to be done for `all'.
```
???

Note that Make refuses to repeat work that is already done.

It's this economy that is Make's chief strength.  A properly coded 
Makefile will allow the tool to always arrive at the fastest
possible way to satisfy any given dependency graph.

Obviously, this approach doesn't scale very well.  Make has more
tricks up its sleeve to help us write a more compact and 
maintainable Makefile...

---
# Variables

Make lets us define variables, just like any other programming
language.

```
CC := g++
CC_FLAGS ?= -w
SOURCES = main.cpp mylib.cpp
SOURCES += myotherlib.cpp
SOURCES := yetanotherlib.cpp $(SOURCES)

sometarget:
  echo $(SOURCES)
  echo '$$0.02: Make can be fun.'
```

* `=` Lazy Assignment - permits recursive expansion on evaluation
* `:=` Immediate - evaulated at declaration time$
* `?=` Set if absent - only set if the variable doesn't already have a value
* `+=` Appends value to variable; lazy-assigns if not set
* `$(...)` Variable interpolation; substitues variable contents at location
* `$$` Substitutes a single '$'

???
Variables are essential to readable and useful Makefiles.  Like any 
other form of encapsulation, it does make the file a little harder to
read, but the resulting file can be shorter and more generic as
a result.

It's generally a good idea to prefer `:=` unless your variable absolutely
must be evaluated when it is used.

---
# Automatic Variables

https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html

Within a target, Make provides us with some special substitutions that
allow for much more concise commands:

```
myfile.txt: myfile.src
  cp $^ $@ 
```

The most common automatic variables are:

* `$@` The target name
* `$^` All the prerequisites 
* `$<` The first prerequisite
* `$?` All prerequisites newer than target

Automatic variables like `$%`, `$+`, `$|`, and `$*` are far less common
and cover much more advanced usage of Make than is in this presentation.

---
# Generic Targets

It's possible to tell Make how to satisfy a kind of target, based on
some simple pattern matching.

```
OBJECTS := myfile.txt someotherfile.txt thirdfile.txt

%.txt: %.src
  @echo 'building $*'
  cp $< $@

all: $(OBJECTS)

.PHONY: all
```

In this example, the `all` target is satisfied by three `.txt` files.
Make will use the declared `.txt to .src` generic target satisfy `all`,
and will look for the same files with the `.src` suffix to do so.

---
# Text Replacement

Make has some basic text-replacement features for variables.  These are
most often used to help generate lists of dependencies based on a 
set of source files and their extensions.

```
SOURCES := myfile.src someotherfile.src thirdfile.src
OBJECTS := $(SOURCES:.src=.txt)
```

The above assigns a list of `.txt` files to `OBJECTS`, by replacing all 
the `.src` extensions with `.txt`.

???
The above approach is used most often with C++ projects, due to the
reliable coupling of sources (.c, .cc, .cpp, or .cxx files) and the 
compiler's object file extension (usually .o, or .obj).

Note that the use of generic targets along with this feature do nothing
at all to the filename or file's path.  It's this property that 
reveals Make as a tool peferring a flat file structure.  If it is not
desirable for intermediate files (like object files) to be added to
the same directory as the source files, One must resort to much more
text manipulation to avoid it.

---
# Built-in Functions

Make provides some powerful built-in processing capabilities in order
to further slim down your typical Makefile.

```
# use 'find' to dynamically find all the source files
SOURCES := $(shell find . -name '*.c' -or -name '*.js')

# wildcard is more portable than 'find'
FILES := $(wildcard spec/*.coffee)

# get the directory of one or more filenames (/foo/bar/ / /home/foo/)
DIRS := $(dirname /foo/bar/baz.c /gorf.c /home/foo/x.c)

# filter out text
JS_SOURCES := $(filter %.js, $(SOURCES))
```

https://www.gnu.org/software/make/manual/html_node/Functions.html
---
# Extras

```
# Make will emit every command's text to the console - '@' prevents that.
hello:
  @echo 'hello world'

# Additional Makefile code can be pulled in using `include`
include common.in

# Set the preferred shell
SHELL := git bash

# Make has a conditional syntax (usually used for OS detection)
ifeq ($(OS),Windows_NT)
  OS := 'windows'
else
  OS := 'bsd/linux'
endif
```

???
The `include` directive is seldom seen outside of automake/autoconf 
setups.  Considering that its possible to use `include` for libraries
of generic make rules, its rather underrated.  For instance, a 
developer could put all the generic build capabilities into a common
include file, and place the project specific targets and file
lists in the main Makefile.

While it's possible to change the shell using `SHELL`, that doesn't
mean that you've arrived at an easy hack for Windows portability. 
You still have to avoid unix/linux specific commands like `find`, and
stick to whatever functions Make provides instead.

---
# Javascript

An example of CoffeeScript compilation ("transpiling") using Make. 

```
PATH  := node_modules/.bin:$(PATH)
SHELL := /bin/bash

template_source := templates/*.handlebars
template_js     := build/templates.js

$(template_js): $(templates_source)
  mkdir -p $(dir $@)
  handlebars $(templates_source) > $@

source_files := $(wildcard lib/*.coffee)
build_files  := $(source_files:%.coffee=build/%.js)

spec_coffee  := $(wildcard spec/*.coffee)
spec_js      := $(spec_coffee:%.coffee=build/%.js)

build/%.js: %.coffee
  coffee -co $(dir $@) $<
```

???
Here we have an example of compiling CoffeeScript files using some
very generic rules.  

While your particular stack may not use Handlebars or CoffeeScript,
there's no reason why this can't be adapted to, say, AngularJS and 
TypeScript.

---
# Javascript Continued

An example of how one might package an application's frontend Javascript 
resources files, using uglifyjs.

```
app_bundle := build/app.js

libraries  := vendor/jquery.js \
  node_modules/handlebars/dist/handlebars.runtime.js \
  node_modules/underscore/underscore.js \
  node_modules/backbone/backbone.js

$(app_bundle): $(libraries) $(build_files) $(template_js)
  uglifyjs -cmo $@ $^

%.css: %.less
  lessc $? > $@

lint: $(libraries) $(build_files) $(template_js)
  jshint $?

all: $(app_bundle)
```
An example of what most of us tend to put into our Gruntfiles right away. 

Even with the explicit `libraries` listing, this is fewer lines of code
compared to a Gruntfile of the same capability.

---
# Watch

Since Make is basically for command line automation, a Grunt-style 'watch' 
target can be configured by using a command like `watchman`.

```
watch:
    watchman watch $(shell pwd)
    watchman -- trigger $(shell pwd) remake *.js *.css -- make all
```

???
Of course we want the equivalent of `grunt watch`.  Since that's out of
scope for a tool like Make, we'll need an external command that does the 
job instead.  A phony `watch` target backed on Facebook's `watchman` 
makes this possible.

---
# Thank you

Thanks for viewing this presentation.

---
#Additional Reading

About Make:
* https://en.wikipedia.org/wiki/Make_(software)
* https://en.wikipedia.org/wiki/Makefile

Tutorials and Blog Posts About Make:
* http://www.puxan.com/web/blog/HowTo-Write-Simple-Makefiles
* http://mrbook.org/blog/tutorials/make/
* http://www.puxan.com/web/blog/HowTo-Write-Generic-Makefiles
* https://stackoverflow.com/questions/714100/os-detecting-makefile
* https://blog.jcoglan.com/2014/02/05/building-javascript-projects-with-make/
* https://algorithms.rdio.com/post/make/
* https://stackoverflow.com/questions/448910/makefile-variable-assignment

Reference:
* https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
* https://www.gnu.org/software/make/manual/html_node/Functions.html
