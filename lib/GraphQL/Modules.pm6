use v6;

use Redis::Async;
use JSON::Fast;

my $r = Redis::Async.new('localhost:6379');

class Model
{
    method authors()
    { $r.smembers('authors') }

    method distributions()
    { $r.smembers('dists') }

    method tags()
    { $r.smembers('tags') }

    method author($author_id)
    { from-json ($r.get("author:$author_id") or return) }

    method distribution($name)
    { from-json ($r.get("dist:$name") or return) }

    method tag($tag)
    { from-json ($r.get("tag:$tag") or return) }

    method author-distributions($author_id)
    { $r.smembers("author-dist:$author_id") }

    method tag-distributions($tag)
    { $r.smembers("tag-dist:$tag") }
}

class Tag {...}

class Author {...}

#| A specific distribution of a Perl6 module
class Distribution
{
    #| Name of the distribution
    has Str $.name;
    #| Description of the distribution
    has Str $.description;
    #| author id of the Author of the distribution
    has Str $.author_id;
    #| build id
    has Str $.build_id;
    #| date updated
    has Str $.date_updated;
    #| Number of open github issues
    has Int $.issues;
    #| Number of github stars
    has Int $.stars;
    #| URL of the repository
    has Str $.url;
    #| URL of the META6.json metdata file for the distribution
    has Str $.meta_url;
    #| Travis integration status
    has Str $.travis_status;
    #| URL to the Travis integration
    has Str $.travis_url;
    has $.tag-list;        # Won't show up in GraphQL

    method new(Str $name)
    {
        my $d = Model.distribution($name) or return;

        $d<tag-list> = $d<tags>:delete; # Rename

        nextwith(|$d);
    }

    #| Author object of the distribution
    method author() returns Author
    {
        Author.new($!author_id);
    }

    #| Tag objects associated with the distribution
    method tags() returns Array[Tag]
    {
        Array[Tag].new($!tag-list.map({ Tag.new($_) }));
    }
}

#| Authors of distributions
class Author
{
    #| Id of an Author
    has Str $.author_id;

    method new(Str $author_id)
    {
        my $d = Model.author($author_id) or return;
        nextwith(|$d);
    }

    #| Distributions associated with this author
    method distributions() returns Array[Distribution]
    {
        Array[Distribution].new(
            Model.author-distributions($!author_id)
                 .map({ Distribution.new($_) })
        );
    }
}

#| Tag for categorizing distributions
class Tag
{
    #| String id of the tag
    has Str $.tag;

    method new(Str $tag)
    {
        my $d = Model.tag($tag) or return;
        nextwith(|$d);
    }

    #| Distributions associated with this tag
    method distributions() returns Array[Distribution]
    {
        Array[Distribution].new(
            Model.tag-distributions($!tag)
                 .map({ Distribution.new($_) })
        );
    }
}

#| Main query class for the server
class Query
{
    #| List all the authors
    method authors() returns Array[Author]
    {
        Array[Author].new(
            Model.authors.map({ Author.new($_) })
        );
    }

    #| List all the distributions
    method distributions() returns Array[Distribution]
    {
        Array[Distribution].new(
            Model.distributions.map({ Distribution.new($_) })
        );
    }

    #| List all the tags
    method tags() returns Array[Tag]
    {
        Array[Tag].new(
            Model.tags.map({ Tag.new($_) })
        );
    }

    #| A specific author
    method author(Str :$author_id!) returns Author
    {
        Author.new($author_id)
    }

    #| A specific distribution
    method distribution(Str :$name!) returns Distribution
    {
        Distribution.new($name)
    }

    #| A specific tag
    method tag(Str :$tag!) returns Tag
    {
        Tag.new($tag)
    }
}
