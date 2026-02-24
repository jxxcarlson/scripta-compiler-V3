#!/bin/bash
# transform-images.sh — Convert inline [image ...] to block | image syntax
#
# Transforms:
#   [image URL CAPTION k1:v1 k2:v2 ..]
# To:
#   | image caption:CAPTION k1:v1 k2:v2 ..
#   URL
#
# Usage: ./transform-images.sh <file>       (in-place, backup at file.bak)
#        ./transform-images.sh < file       (stdout)

if [ -n "$1" ]; then
  perl -0777 -i.bak -pe '
    sub transform_image {
      my ($inner) = @_;
      my @tokens = split /\s+/, $inner;
      my $url = shift @tokens;
      my @caption;
      my @props;
      for my $t (@tokens) {
        if (@props || $t =~ /^\w+:\S+$/) {
          push @props, $t;
        } else {
          push @caption, $t;
        }
      }
      my $line = "| image";
      $line .= " caption:" . join(" ", @caption) if @caption;
      $line .= " " . join(" ", @props) if @props;
      return "\n$line\n$url\n";
    }
    s/\[image\s+([^\]]+)\]/transform_image($1)/ge;
  ' "$1"
  echo "Transformed: $1 (backup: $1.bak)"
else
  perl -0777 -pe '
    sub transform_image {
      my ($inner) = @_;
      my @tokens = split /\s+/, $inner;
      my $url = shift @tokens;
      my @caption;
      my @props;
      for my $t (@tokens) {
        if (@props || $t =~ /^\w+:\S+$/) {
          push @props, $t;
        } else {
          push @caption, $t;
        }
      }
      my $line = "| image";
      $line .= " caption:" . join(" ", @caption) if @caption;
      $line .= " " . join(" ", @props) if @props;
      return "\n$line\n$url\n";
    }
    s/\[image\s+([^\]]+)\]/transform_image($1)/ge;
  '
fi
