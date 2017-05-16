# Perl 6 GraphQL Modules

This is a simple [Perl 6](https://perl6.org) example using
[GraphQL](http://graphql.tilmes.org/).

A simple program grabs the Perl 6 [modules
list](https://modules.perl6.org/.json) and loads it into a very simple
[Redis](https://redis.io/).

The Schema is based around three types, **Distribution**, **Author**,
and **Tag** and links between them.

It was used as an example at a talk for the [Milwaukee Perl
Mongers](https://www.meetup.com/Milwaukee-Perl-Mongers/) on May 31,
2017.

