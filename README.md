# Nesta - a CMS for Ruby Developers

A CMS for small web sites and blogs, written in
[Sinatra](http://www.sinatrarb.com/ "Sinatra").

Content can be written in
[Markdown](http://daringfireball.net/projects/markdown/ "Daring Fireball:
Markdown") or [Textile](http://textism.com/tools/textile/) and stored in text
files (though you can also use Haml if you need to add some HTML to your
pages). There's no database; write your content in your editor. Publish by
pushing to a git repository.

## Installation

Begin by cloning the git repository:

    $ git clone git://github.com/gma/nesta.git

Nesta's dependencies are managed with bundler, which handles installing the
necessary gems for you:

    $ gem install bundler
    $ cd nesta
    $ bundle install

You'll need a config file. You can start with the default and tweak it to suit
later:

    $ cp config/config.yml.sample config/config.yml

Create some sample web pages (optional):

    $ bundle exec rake setup:sample_content

That's it - you can launch a local web server in development mode using
shotgun...

    $ bundle exec shotgun app.rb

...then point your web browser at http://localhost:9393. Start editing the
files in `nesta/content`, and you're on your way.

See [http://effectif.com/nesta](http://effectif.com/nesta) for more
documentation.

## Deployment

capistrano is required for deploying any changes to the nesta code
base.  deployment of content changes is achieved through a post commit
hook on the server.

### Content Deployment

Deployment of content is achieve via a post commit hook that is setup
on the web server.

1. Setup working directory

    git clone git@github.com:recruitmilitary/nesta.git
    git submodule sync
    git submodule update --init
    cd content
    git remote add staging ssh://deploy@web1.recruitmilitary.com/home/deploy/git/search-and-employ-staging.git

2. Make changes in content

    cd content
    *change*, *change*, *change*

3. Push content to staging

    cd content
    git push staging master

4. Push content to production

    cd content
    git push production master

### Capistrano Deployment

For both content and nesta code there are two environments setup for
deployment, both staging and production.

Simply provide the name of the environment you want to deploy to:

    cap staging deploy
    cap production deploy

If you don't specify an environment staging will be used by default.
