#!/usr/bin/env perl

use strict;

open (TREES, 'git ls-tree -r HEAD|');

my %blob_hash;
my %files_should_print;

# make the HEAD tree info
while (<TREES>) {
    my @info = split /\s+/;

    my $filename = $info[-1];
    my $hash     = $info[-2];

    $blob_hash{$filename} = $hash;
    $files_should_print{$filename} = 1;
}

close(TREES);

$? and die;

open (COMMITS, 'git rev-list HEAD |');

my $prev_timestamp;
while (<COMMITS>) {
    (keys %files_should_print) or last;

    my $commit = $_;

    open (COMMIT_CONTENT, 'git cat-file -p ' . $commit . '|');
    my $tree;
    my $timestamp;
    while (<COMMIT_CONTENT>) {
        if (/tree/) {
            my @tmp = split /\s+/;
            $tree = $tmp[1];
            next
        }
        if (/committer/) {
            my @tmp = split /\s+/;
            $timestamp = $tmp[-2];
            last;
        }
    }
    close(COMMIT_CONTENT);

    open (BLOBS, "git ls-tree -r $tree |");

    my %remained = %files_should_print;
    while (<BLOBS>) {
        my @tmp = split(/\s+/);
        my $filename = $tmp[-1];
        my $blobhash = $tmp[-2];

        if ($remained{$filename}) {
            delete $remained{$filename};
        }

        if (!$files_should_print{$filename}) {
            next;
        }


        if ($blob_hash{$filename} !~ /$blobhash/) {
            do_print($filename, $prev_timestamp);
        }
    }

    foreach my $filename (keys(%remained)) {
        do_print($filename, $prev_timestamp);
    }

    $prev_timestamp = $timestamp;

    close (BLOBS);
}

# For files that never changed from the root commit.
foreach my $filename (keys(%files_should_print)) {
    do_print($filename, $prev_timestamp);
}


sub do_print() {
    my ($filename, $timestamp) = @_;
    print $filename . "\t" . $timestamp . " \n";
    delete ($files_should_print{$filename});
}

close (COMMITS);
