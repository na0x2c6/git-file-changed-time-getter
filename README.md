## About
A Perl script that wrapped some git command to get the updated-times (committed-times) from HEAD's tree for [git](https://git-scm.com/).

## How to use

```
$ perl ./time-getter.pl
```

## ATTENTION
On basically git concept, objects that have time state (_committer committed time_ and _author committed time_) is **ONLY** commit-objects.

Probably this concept is itself intentionally, so **this wrapper script is expected to use in some cases as a workaround**.

So if possible, you should consider another approach to the case before using this wrapper script.

## NOTE
- This script prints timestamps where each blob object has changed between trees that are traced by commit-objects history. So if a file is changed in a branch and merged to the main branch with merge commit (e.g. using `--no-ff` option), **the timestamp comes from the merge commit**.
- All timestamps are _committer-commit_ timestamps, not _author-commit_ timestamps.
