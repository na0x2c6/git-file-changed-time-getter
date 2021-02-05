#!/usr/bin/env perl

use strict;

open (F, 'git ls-tree -r HEAD|');

my %list;
my %all_file;

# 辞書作る
while (<F>) {
    my @info = split /\s+/;

    my $filename = $info[-1];
    my $hash     = $info[-2];

    $list{$filename} = $hash;
    $all_file{$filename} = 1;
}

close(F);

open (COMMITS, 'git rev-list HEAD |');

# timestamp 取りつつ tree を get
my $prevtimestamp;
my $timestamp;
while (<COMMITS>) {
    my $commit = $_;

    (keys %list) or last;

    open (TMP, 'git cat-file -p ' . $commit . '|');
    my $tree;
    while (<TMP>) {
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
    close(TMP);

    open (BLOBS, "git ls-tree -r $tree |");

    my %remained = %all_file;
    while (<BLOBS>) {
        my @tmp = split(/\s+/);
        my $filename = $tmp[-1];
        my $blobhash = $tmp[-2];

        if ($remained{$filename}) {
            delete $remained{$filename};
        }

        if (!$list{$filename}) {
            next;
        }

        if ($list{$filename} !~ /$blobhash/) {
            print $filename . ": " . $prevtimestamp . " \n";
            delete ($list{$filename});
            delete ($all_file{$filename});
        }
    }

    foreach my $filename (keys(%remained)) {
        print $filename . ": " . $prevtimestamp . " \n";
        delete ($list{$filename});
        delete ($all_file{$filename});
    }

    $prevtimestamp = $timestamp;

    close (BLOBS);
}

close (COMMITS);
