       _             _____            _    _                 _
      (_)           / ____|          | |  | |               | |
       _  __ _     | |     ___   ___ | | _| |__   ___   ___ | | __
      | |/ _` |    | |    / _ \ / _ \| |/ / '_ \ / _ \ / _ \| |/ /
      | | (_| |    | |___| (_) | (_) |   <| |_) | (_) | (_) |   <
      | |\__, |     \_____\___/ \___/|_|\_\_.__/ \___/ \___/|_|\_\
     _/ |   | |
    |__/    |_|


Noah Sussman's jq Cookbook
===========

How to use jq, [the command-line JSON processor.](http://stedolan.github.io/jq/)

I provide some snippets of Client-Side JavaScript code to facilitate
loading JSON documents into the browser. These snippets require [jQuery](http://api.jquery.com/)
in order to run.

I use
[uglifyjs](https://github.com/mishoo/UglifyJS2/blob/master/README.md)
to format JavaScript. This is optional, you don't *need* `uglifys` in
order to use the `jq` recipes.

Avid readers may also wish to avail themselves of
[jsonlint](https://github.com/zaach/jsonlint).

I refer to
[Jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins)
throughout, but you can mentally substitute the name of your own CI
server and everything will work just the same. All the code here is
entirely platform-independent.

## If you have not used *jq* before

If you have not used *jq* before then this tutorial will annoy
you.

Please refer first to the examples and documentation found in the very
fine [manual](http://stedolan.github.io/jq/manual/).

Or just type `man jq` at the prompt --- everything you need is
documented <a href="http://infiniteundo.com/post/80891241176/how-to-read-a-manpage" >in the manpage</a>
for jq!

jq is a DSL (domain-specific language) so expect to take a day or two
(at least) to read through the manual and fully understand jq's
capabilities.
