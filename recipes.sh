#!/usr/bin/env bash

#    _             _____              _
#   (_)           |  __ \            (_)
#    _   __ _     | |__) | ___   ___  _  _ __    ___  ___
#   | | / _` |    |  _  / / _ \ / __|| || '_ \  / _ \/ __|
#   | || (_| |    | | \ \|  __/| (__ | || |_) ||  __/\__ \
#   | | \__, |    |_|  \_\\___| \___||_|| .__/  \___||___/
#  _/ |    | |                          | |
# |__/     |_|                          |_|
#
# The first thing that's needed in order to experiemnt with jq is ---
# some data! So now I will create a data file with a few lines of log
# entries. Each log entry contains a severity indicator (wrapped in
# [square brackets]) followed by a message.
#

echo "[DEBUG] foo
[ERROR] bar
[ERROR] baz
[INFO] boz" > example.log

# This is a toy example but it has the advantage of being easy to
# reason about while learning! Believe me, these four lines actually
# contain enough variation to keep things interesting for the rest of
# this article =D
#
# Now that I have a logfile to analyze, I have many choices as to what
# type of analysis to perform!
#
# First off, why don't I read each line of the file into an
# array. That would be much easier to work with programatically than a
# plain text file. So I can save myself some coding time later by
# performing this one-time transformation on my log data right now!

jq --slurp --raw-input --raw-output \
    'split("\n") | .' \
    example.log > log_lines.json

# That command created a new file: log_lines.json which contains the
# same information as our original log, but formatted as a JSON array
# ready for loading into ANY programatic environment.
#
# Optionally I can use jsonlint to validate the transform was
# successful.

jsonlint -q log_lines.json

# However, it's worth noting that (at least in theory) jq CAN NOT
# output invalid JSON. The JSON output from jq is always serialized
# from an object in memory.
#
# In other words: jq never "just prints" the JSON --- rather jq ALWAYS
# validates all JSON before attempting to print it out. JSON that
# cannot be validated causes jq to print nothing and exit with an
# error!
#
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
# Now if I want a count of log lines by severity, I can do that:

jq 'group_by(.severity) | map({"\(.[0].severity)" : length})' \
    severity_index.json

# Now the output at this point is JSON but I could be terser if I just
# wanted human-readable output. jq provides a LOT of control over
# output formats!
#
# Here's the same query against severity_index.json, but formatted as
# human-readable plain text. Note I've moved the numbers to the left
# hand side of the output, so that they line up with the left edge of
# the screen. This is helpful when formatting data for humans to
# read.

jq -r \
    'group_by(.severity) | map("\(length) \(.[0].severity)") | .[]' \
    severity_index.json
