KHARITES
========

[Minimalistic publishing platform](http://kharites.heroku.com/) meant for developers/designers written in Sinatra framework (sinatra.rubyforge.org).

Initial disclaimer! This mess is gonna get raw, like sushi. So, haters to the left.

Anyway...

### Main features
    
*   Every Article may have a totaly different layout.
*   Notes feature for simple day to day notes.
*   Totally open source. Hack it apart and send us a patch!

#### Inspiration

*    [Topfunky's (Geoffrey Grosenbach) Peepcode blog](http://blog.peepcode.com/tutorials/2010/about-this-blog)
*    [Jason Santa Maria](http://jasonsantamaria.com/)
*    [Adam Wiggins](http://about.heroku.com/) [Scanty (The blog that's almost nothing)](http://github.com/adamwiggins/scanty) which also powers his awesome blog [a tornado of razorblades](http://adam.blog.heroku.com/)

### 1 - Articles:

No admin interface. Use your favorite text editor to edit plain-text files and synchronize them to server. It comes with Rake and Capistrano tasks for installing and deploying the application, and for syncing articles from your local machine to the server.

#### Features

*    Sinatra, Rack and Thin
*    YAML configuration
*    Capistrano tasks

### 2 - Notes:

Notes are quick-and-dirty. They are loosely structured and pefect for your fat free Blog.

#### Comments

There are no comments by default. If you wish to activate comments, create an account and a website on Disqus (disqus.com) and enter the website shortname as the :disqus_shortname value in the Blog config struct. 

#### Import data

Christopher Swenson has a [Wordpress importer](github.com/swenson/scanty_wordpress_import)

Other kinds of data can be imported easily, take a look at the rake task :import for an example of loading from a YAML file with field names that match the database schema. 

#### Features

*    Notes (shock!)
*    Ta-ta-tagging
*    [Markdown](http://daringfireball.net/projects/markdown/syntax) (via Maruku)
*    Atom feed
*    Google Analitics
*    Comments via Disqus
*    Web framework = Sinatra
*    [Fluid960gs](http://www.designinfluences.com/fluid960gs/) for layout flexibility

### Requirements

[Kharites-tools](http://github.com/jpablobr/kharites-tools)

[Mongodb](http://www.mongodb.org/display/DOCS/Getting+Started#GettingStarted-InstalltheSoftware)

### Setup

For the latest stable version:

    git clone git://github.com/jpablobr/kharites.git
    cd kharites
    bundle install

#### Articles

Edit the configuration file:

    config/config.example.yml

and save it as config/config.yml

    kharites generate <article-name>
    rake app:start

Load this URL in your browser:

    http://localhost:4567
    http://localhost:4567/<article-name>

Articles are first class citizens on kharites permalink world.
You’re done... SRSLY.


##### Synchronizing content

There are several ways:

*     You can setup remote git repository on your server, just push-ing changes whenever you feel like you want to say something in public. A post-commit hook is completely neccessary in this case, of course. See Capistrano task cap sync:setup:hook for setting this up.
*     You can also push to Githu, and have Github call Kharites by it’s Post-Receive Hooks [Post receive hooks](http://github.com/guides/post-receive-hooks). Github then calls Kharites’s /sync and it will git pull changes from Github. This authenticated By setting up a token in the config file. OMG! Could be overheard in the internets! If you’re worried or prudent, do not use this. (See Capistrano task cap sync:setup:github for adding remote Github repo on the server!)

You can set-up last two options by running Capistrano task cap sync:setup. Choose whether you like to upload your local data as a Git repository to the server (and setup post-receive hook in doing so) or you want to clone data from Github repository. You should add a Post-Receive URL in your repo’s administration on Github as told by the task when it has runned.

#### Notes

Run the server:

    $ Rake app:start

And visit: http://localhost:4567

Log in with the password you selected (config/config.yml), then click New Post. The rest should be self-explanatory.

### Testing

[RSpec](http://wiki.github.com/dchelimsky/rspec)

[Sinatra testing](http://www.sinatrarb.com/testing.html)

Sinatra now relies on Rack::Test and has deprecated the use of Sinatra::Test.

`sudo gem install rack-test`

See `spec/spec_helper.rb`

### TODO

*    Merge articles and notes feeds.
*    Tweak [Hassle](http://github.com/pedro/hassle) to work with articles directory.
*    Better documentation, maybe a wiki...
*    Improve Kharites-tool so it can automate mundane tasks such as synchronization, backups, server basic administration, etc...
*    To use webkit2png.py to take screenshots of each article and display it in a grid, slideshow or whatever!
*    Content synchronization with [Codebasehq respository mirroing](http://www.codebasehq.com/help/other-features/repository-mirroring) for free private repos.
*    Work on better tests suite...
*    Improve notes textarea. (mongo bug when editing notes)
*    Styles for mobile devices (for notes).    

### Resources

*    [Sinatra](http://www.sinatrarb.com)
*    [Post receive hooks](http://github.com/guides/post-receive-hooks)     
*    [Mongodb](http://www.mongodb.org)
*    [HAML](http://haml-lang.com/)
*    [Fluid960gs](http://www.designinfluences.com/fluid960gs/)

### Note on Patches/Pull Requests

Fork the project.
Make your feature addition or bug fix.
Add tests for it. This is important so I don’t break it in a future version unintentionally.
Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
Send me a pull request. Bonus points for topic branches.

### Copyright

Copyright 2009 Jose Pablo Barrantes. MIT Licence, so go for it.
