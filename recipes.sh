#!/usr/bin/env bash

# jq Recipes
#    _             _____              _
#   (_)           |  __ \            (_)
#    _   __ _     | |__) | ___   ___  _  _ __    ___  ___
#   | | / _` |    |  _  / / _ \ / __|| || '_ \  / _ \/ __|
#   | || (_| |    | | \ \|  __/| (__ | || |_) ||  __/\__ \
#   | | \__, |    |_|  \_\\___| \___||_|| .__/  \___||___/
#  _/ |    | |                          | |
# |__/     |_|                          |_|
#
# I'm assuming you are following along on the command line as you read
# this: typing or pasting each command in as you go, then taking a few
# minutes to examine the output and/or the files created by the
# commands you have run. I've included the output of some commands for
# reference.
#
# The first thing that's needed in order to experiment with jq is ---
# some data! So now I will create a data file with a few lines of log
# entries. Each log entry contains a severity indicator (wrapped in
# [square brackets]) followed by a message.

echo "[DEBUG] foo
[ERROR] bar
[ERROR] baz
[INFO] boz" > example.log

# That creates a file called example.log in your current working
# directory.
#
# Use cat to verify the contents of example.log
#
#    $ cat example.log
#    [DEBUG] foo
#    [ERROR] bar
#    [ERROR] baz
#    [INFO] boz
#
# Now, this is a toy data set but it has the advantage of being easy
# to reason about while learning! Believe me, these four lines
# actually contain enough variation to keep things interesting for the
# rest of this article =D
#
# Now that I have a logfile to analyze, I have many choices as to what
# type of analysis to perform!
#
# First off, why don't I read each line of the file into an
# array. That would be much easier to work with programmatically than a
# plain text file. So I can save myself some coding time later by
# performing this one-time transformation on my log data right now!

jq --slurp --raw-input --raw-output \
    'split("\n") | .' \
    example.log > log_lines.json

# That command created a new file: log_lines.json which contains the
# same information as our original log, but formatted as a JSON array
# ready for loading into ANY programmatic environment.
#
#    $ cat log_lines.json
#    [
#      "[DEBUG] foo",
#      "[ERROR] bar",
#      "[ERROR] baz",
#      "[INFO] boz"
#    ]
#
# Note here a key advantage of working with my own generated "toy"
# data set: it is trivially possible to verify that I (the writer) and
# you (the reader) are definitely working with the exact same data
# set. This confidence in consistency is an invaluable advantage when
# learning the fundamentals of a Turing-complete DSL like jq!
#
# With regard to data integrity, I will also point out that one can
# optionally use jsonlint to validate the result of any jq transform
# was successful.

jsonlint -q log_lines.json

# However, it's worth noting that by default jq CAN NOT output invalid
# JSON. The output from jq is always serialized directly into JSON
# from an object in memory.
#
# In other words: jq never "just prints" a JSON string. Rather, jq
# ALWAYS validates all JSON before attempting to print it out. JSON
# that cannot be validated causes jq to print nothing and exit with an
# error!





# Data Analysis
#  _____        _                                  _           _
# |  __ \      | |               /\               | |         (_)
# | |  | | __ _| |_ __ _        /  \   _ __   __ _| |_   _ ___ _ ___
# | |  | |/ _` | __/ _` |      / /\ \ | '_ \ / _` | | | | / __| / __|
# | |__| | (_| | || (_| |     / ____ \| | | | (_| | | |_| \__ \ \__ \
# |_____/ \__,_|\__\__,_|    /_/    \_\_| |_|\__,_|_|\__, |___/_|___/
#                                                     __/ |
#                                                    |___/
#
# Now that the plain text log has been converted to JSON, I can do
# some data mining.
#
# A very common question when looking at an application log is: how
# many and what kind of errors are in this log? So I'll do that
# analysis now on my toy data set...

jq 'map(split(" ") | {severity: "\(.[0])", message: "\(.[1])"})' \
    log_lines.json > severity_index.json

# I've now created a new file: severity_index.json, which contains an
# array of hashes. Each hash has two keys: severity and message.
#
#     $ cat severity_index.json
#     [
#       {
#         "severity": "[DEBUG]",
#         "message": "foo"
#       },
#       {
#         "severity": "[ERROR]",
#         "message": "bar"
#       },
#       {
#         "severity": "[ERROR]",
#         "message": "baz"
#       },
#       {
#         "severity": "[INFO]",
#         "message": "boz"
#       }
#     ]
#
# Now if I want a count of log lines by severity, I can use the
# following expression:

jq 'group_by(.severity) | map({"\(.[0].severity)" : length})' \
    severity_index.json > totals.json

# Now the output at this point is JSON but I could be terser if I just
# wanted human-readable output. jq provides a LOT of control over
# output formats!
#
#     $ cat totals.json
#     [
#       {
#         "[DEBUG]": 1
#       },
#       {
#         "[ERROR]": 2
#       },
#       {
#         "[INFO]": 1
#       }
#     ]
#
#
# Here's the same query against severity_index.json, but formatted as
# human-readable plain text. Note I've moved the numbers to the left
# hand side of the output, so that they line up with the left edge of
# the screen. This is helpful when formatting data for humans to
# read.

jq -r \
    'group_by(.severity) | map("\(length) \(.[0].severity)") | .[]' \
    severity_index.json > totals.txt

# Note that totals.txt is suitable for including in an email or
# echo'ing into an IRC chat room.
#
#     $ cat totals.txt
#     1 [DEBUG]
#     2 [ERROR]
#     1 [INFO]





# diff for JSON
#      _ _  __  __    __                  _  _____  ____  _   _
#     | (_)/ _|/ _|  / _|                | |/ ____|/ __ \| \ | |
#   __| |_| |_| |_  | |_ ___  _ __       | | (___ | |  | |  \| |
#  / _` | |  _|  _| |  _/ _ \| '__|  _   | |\___ \| |  | | . ` |
# | (_| | | | | |   | || (_) | |    | |__| |____) | |__| | |\  |
#  \__,_|_|_| |_|   |_| \___/|_|     \____/|_____/ \____/|_| \_|
#
# One of the most exciting applications of jq is in testing data set
# integrity. Historically, data integrity testing has meant working
# with large, relatively static data sets that have been transformed
# and filtered through a complex Extract-Transform-Load pipeline
# (ETL).
#
# However in the Web/Mobile century, every application is having an
# ongoing API conversation with external services. The artifacts
# exchanged during these API transactions constitute a relatively
# small, rapidly changing data set.
#
# jq's "does one thing well" approach to JSON processing makes it
# possible to use a single tool to do both large-scale data integrity
# testing; as well as small-but-rapidly-iterating analysis of API
# transaction artifacts!
#
# First I will create a second data set containing only the non-error
# lines from my original example.log file:

jq 'map(select(.severity != "[ERROR]")) | sort' \
    severity_index.json > for_comparison.json

# I've sorted the keys in the second data set just to make the point
# that using the diff command isn't that useful when dealing with JSON
# data sets.
#
# Anyway, here is the file I will be using for comparison with my
# existing severity_index.json data set:
#
#     $ cat for_comparison.json
#     [
#       {
#         "severity": "[DEBUG]",
#         "message": "foo"
#       },
#       {
#         "severity": "[INFO]",
#         "message": "boz"
#       }
#     ]
#
# The simplest test I'd ever want to perform is just finding out if
# two data sets are the same. Here's how jq lets me do that:

jq --slurp --exit-status \
    '.[0] == .[1]' \
    severity_index.json for_comparison.json

# Note the use of the --exit-status flag, which tells jq to return a
# bad exit status if my equality test returns false. With the
# --exit-status flag in place, the code above is sufficient to create
# a Jenkins job that fails if two JSON files are not exactly identical!
#
# So much for exact equality. Moving on to the more interesting
# question of performing a useful diff on two JSON documents.
#
# I can figure out which keys are in the first document but not in the
# second document by using the subtraction operator:

jq --slurp --exit-status \
    '.[0] - .[1]' \
    severity_index.json for_comparison.json

# This lists out only the error keys, since those are the keys that I
# previously filtered out of the for_comparison.json document.
#
# In order to see the results of a diff, it would be best if the
# for_comparison data set contained at least one unique key. So I will
# add a new one:

jq '[{severity: "[DEBUG]", message: "hello world!"}] + .' \
    for_comparison.json > advanced_comparison.json

# I'm choosing to prepend to the data set here because I want to drive
# home my point about diff not being a good tool for this sort of
# analysis (even on very small data sets like this one). The "rules"
# for outputting JSON documents are too fast-and-loose for a tool like
# diff which was designed for logfile and plain text analysis.
#
# Anyhow, an interesting capability of jq is the concurrent
# application of multiple filters to the input stream while still
# returning the output as a single JSON document. So if I want to
# produce a third JSON document showing the difference between the two
# documents under comparison, I can do that like so:

jq --slurp \
    '{missing: (.[0] - .[1]), added: (.[1] - .[0])}' \
    severity_index.json advanced_comparison.json > an_actual_diff.json

# Now I have created an_actual_diff.json which you should examine
# using your favorite text editor. It contains a JSON object with two
# keys: "missing" and "added." Just like a diff!
#
# Now I can easily report how many keys present in the original
# index of log entries, were missing from the comparison file:

jq \
    '.missing | length | "\(.) keys were not found."' \
    an_actual_diff.json

# This should give you output like "2 keys were not found." Again,
# this sort of output is perfect for echo'ing into a chatroom or
# including in an automated notification email.




# API Testing
#           _____ _____   _______        _   _
#     /\   |  __ \_   _| |__   __|      | | (_)
#    /  \  | |__) || |      | | ___  ___| |_ _ _ __   __ _
#   / /\ \ |  ___/ | |      | |/ _ \/ __| __| | '_ \ / _` |
#  / ____ \| |    _| |_     | |  __/\__ \ |_| | | | | (_| |
# /_/    \_\_|   |_____|    |_|\___||___/\__|_|_| |_|\__, |
#                                                     __/ |
#                                                    |___/
#
# Earlier I said that a jq expression with the --exit-status flag
# enabled is sufficient to fail a Jenkins job if a JSON document
# doesn't meet expectations.
#
# JSON documents come from all kinds of sources but typically when
# someone says "API testing" they mean that they want to craft URLs
# based on some existing, written RESTful API specification, then
# retrieve JSON documents from a remote host by requesting those URLs
# and downloading the (JSON) responses. As a final step, validation is
# performed that demonstrates the JSON document returned by an API
# query matches what one might expect based upon the API specifiation.
#
# Using curl to retrieve JSON responses is beyond the scope of this
# article. But do consider that there are very many places where Web
# and mobile applications expose their API data --- making a curl
# request is just the tip of the iceberg! Other options include HAR
# capture with Chrome Inspector, network traffic inspection via
# Charles or WireShark and of course investigation of json documents
# cached in your browser / filesystem.
#
# In any case, the larger point is that comparing JSON documents and
# then failing the build is easy with jq!
#
# Now I will examine some common use cases that come up when testing
# JSON documents retrieved from a remote API.
#
# Just imagine for a moment that the two files we've created (and been
# working with) are the results of two calls to different instances of
# the same API: "foohost/v1/severity_index" and
# "barhost/v1/severity_index" for the sake of pretending =D
#
# Anyhow, back to looking at the useful comparisons that jq can
# perform against two JSON documents that (should) have commonalities
# with regard to structure.
#
# The first snag one is likely to run into in data testing is... data
# dependencies that result in fragile tests. Of course an API smoke
# test has to be dependent to some extent on the data returned (that's
# the whole point). But it sucks to have to break the build because
# someone updated the UI copy or because a cached query was
# updated.
#
# Often I can attain a sufficient level of data independence by simply
# validating that a JSON document has a top-level structure that
# matches the API specification.
#
# Here's an example of how to "diff" the top-level keys in a JSON
# document, ignoring the values of those keys.

jq --slurp \
    '{missing_keys: (([.[0][].severity]) - ([.[1][].severity]) | unique),
        added_keys: (([.[1][].severity]) - ([.[0][].severity]))}' \
    severity_index.json advanced_comparison.json

# Now I can turn that into a test that causes Jenkins to fail the
# build when the file being compared does not use all the same
# top-level keys as the original file:

jq --slurp --exit-status \
    '(([.[0][].severity]) - ([.[1][].severity]) | empty)' \
    severity_index.json advanced_comparison.json
