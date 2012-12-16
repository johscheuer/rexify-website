#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;

use Cwd qw(getcwd);
use Mojolicious::Lite;

plugin 'RenderFile';

sub get_random {
	my $count = shift;
	my @chars = @_;
	
	srand();
	my $ret = "";
	for(1..$count) {
		$ret .= $chars[int(rand(scalar(@chars)-1))];
	}
	
	return $ret;
}

get '/' => sub {
   my ($self) = @_;
   $self->render('index');
};

# special code to handle ,,rexify --search'' requests
get '/get/recipes' => sub {
   my ($self) = @_;
   my $ua = Mojo::UserAgent->new;
   $self->render_text($ua->get("https://raw.github.com/krimdomu/rex-recipes/master/recipes.yml")->res->body);
};

# special code to handle ,,rexify --use'' requests
get '/get/mod/*mod' => sub {
   my ($self) = @_;

   my $cur_dir = getcwd;

   my $mod = $self->param("mod");
   my $mod_name = $mod . ".pm";

   if( ! -d "/tmp/scratch") {
      mkdir "/tmp/scratch";
   }

   chdir("/tmp/scratch");

   my $u = get_random(32, 'a' .. 'z');  
   system("git clone git://github.com/krimdomu/rex-recipes.git $u >/dev/null 2>&1");
   chdir("$u");

   system("tar czf ../$u.tar.gz $mod $mod_name >/dev/null 2>&1");

   chdir($cur_dir);

   $self->render_file(filepath => "/tmp/scratch/$u.tar.gz");
};

get '/*file' => sub {
   my ($self) = @_;

   my $template = $self->param("file");

   if(-f "public/$template") {
      warn "Found file\n";
      return $self->render_file(filepath => "public/$template");
   }

   if(-d "templates/$template") {
      return $self->redirect_to("$template/index.html");
   }

   if(-f "templates/$template.ep") {
      $template =~ s/\.html$//;
      $self->render($template);
   }
   else {
      $self->render('404', status => 404);
   }

};

app->start;

__DATA__

@@ 404.html.ep

% layout 'default';
% title '404 - File not found';

<h1>404 - I'm really sorry :(</h1>
<p>Hello. I'm a Webserver. And i'm there to serve files for you. But i'm really sorry :( I can't find the file you want to see.</p>

@@ navigation.html.ep

<div id="nav">
   <a href="http://rexify.org/"><img id="nav_img" src="http://rexify.org/images/title.png" alt="(R)?ex - What do you want to deploy today?"></a>
   <div class="navlinks"><a href="/">Home</a>&nbsp;&nbsp;&nbsp;<a href="/get" title="Install Rex on your systems">Get Rex</a>&nbsp;&nbsp;&nbsp;<a href="/contribute">Contribute</a>&nbsp;&nbsp;&nbsp;<a href="/howtos" title="Examples, Howtos and Documentation">Howtos/Docs</a>&nbsp;&nbsp;&nbsp;<a href="/api" title="The complete API documentation">API</a>&nbsp;&nbsp;&nbsp;<a href="https://github.com/krimdomu/Rex/wiki">Wiki</a></div>
</div>



@@ layouts/frontpage.html.ep
<html>
   <head>
      <meta http-equiv="content-type" content="text/html; charset=utf-8">
   
      <title><%= title %></title>

      <link rel="stylesheet" href="/css/default.css?6" type="text/css" media="screen" charset="utf-8">
      <link rel="stylesheet" href="/css/highlight.css?6" type="text/css" media="screen" charset="utf-8">

      <meta name="description" content="(R)?ex - manage all your boxes from a central point - Datacenter Automation and Configuration Management">
      <meta name="keywords" content="Systemadministration, Datacenter, Automation, Rex, Rexfiy, Rexfile, Example, Remote, Configuration, Management, Framework, SSH, Linux">

      
      
   </head>
   <body>

      %= include 'navigation';

      <%= content %>
      

      <div id="footer">
         <div class="links">
            Stay in Touch: <a href="https://groups.google.com/group/rex-users/">Google Group</a> / <a href="http://twitter.com/jfried83">Twitter</a> / <a href="https://github.com/krimdomu/Rex">Github</a> / <a href="http://www.freelists.org/list/rex-users">Mailinglist</a> / <a href="irc://irc.freenode.net/rex">irc.freenode.net #rex</a>&nbsp;&nbsp;&nbsp;-.ô.-&nbsp;&nbsp;&nbsp;<a href="http://www.disclaimer.de/disclaimer.htm" target="_blank">Disclaimer</a>
         </div>
      </div>

     <a href="http://github.com/Krimdomu/Rex"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png" alt="Fork me on GitHub"></a>


   </div>
      
   </body>

      <script type="text/javascript" charset="utf-8" src="http://rexify.org/js/jquery-1.5.2.min.js"></script>
   <script type="text/javascript" charset="utf-8" src="http://rexify.org/js/highlight.js"></script>

   <script type="text/javascript" charset="utf-8">


      $(".perl").each(function(a,b) {

         HighlightCode(b);
            
      });

      if($.browser.msie) {
         $("#nav_img").css("float", "left");
      }
      if($.browser.opera) {
         $("#nav_img").css("float", "left");
      }


      $(".navlinks").show();

   </script>

<!-- Piwik --> 
<script type="text/javascript">
var pkBaseURL = (("https:" == document.location.protocol) ? "https://rexify.org/stats/" : "http://rexify.org/stats/");
document.write(unescape("%3Cscript src='" + pkBaseURL + "piwik.js' type='text/javascript'%3E%3C/script%3E"));
</script><script type="text/javascript">
try {
var piwikTracker = Piwik.getTracker(pkBaseURL + "piwik.php", 1);
piwikTracker.trackPageView();
piwikTracker.enableLinkTracking();
} catch( err ) {}
</script><noscript><p><img src="http://rexify.org/stats/piwik.php?idsite=1" style="border:0" alt="" /></p></noscript>
<!-- End Piwik Tracking Code -->


   <script type="text/javascript" charset="utf-8">
      var to_move = 724;
      if($.browser.msie) {
         $("#nav_img").css("float", "left");
         to_move = 730;
      }
      if($.browser.opera) {
         $("#nav_img").css("float", "left");
      }

      function slide_left() {

         $("#bilderlinie").animate({"left": "-=" + to_move}, 2000, function() {
                  if(parseInt($("#bilderlinie").css("left")) < -1650) {
                     window.setTimeout(function() { slide_right(); }, 7000);
                  }
                  else {
                     window.setTimeout(function() { slide_left(); }, 7000);
                  }
               });

      }

      function slide_right() {
         $("#bilderlinie").animate({"left": "+=" + to_move}, 2000, function() {
                  if(parseInt($("#bilderlinie").css("left")) == 0) { 
                     window.setTimeout(function() { slide_left(); }, 7000);
                  }
                  else {
                     window.setTimeout(function() { slide_right(); }, 7000);
                  }
               
               });
      }

      window.setTimeout(function() { slide_left(); }, 5000);

   </script>


</html>


@@ layouts/default.html.ep
<html>
   <head>
      <meta http-equiv="content-type" content="text/html; charset=utf-8">
   
      <title><%= title %></title>

      <link rel="stylesheet" href="/css/default.css?6" type="text/css" media="screen" charset="utf-8">
      <link rel="stylesheet" href="/css/highlight.css?6" type="text/css" media="screen" charset="utf-8">

      %= content_for 'header';
      
   </head>
   <body>

      %= include 'navigation';

      <div id="header">
         <img src="http://rexify.org/images/new-header.png" />
      </div>

      <div id="site">
      <div id="page">

         <%= content %>

      </div>
      </div>

      

      <div id="footer">
         <div class="links">
            Stay in Touch: <a href="https://groups.google.com/group/rex-users/">Google Group</a> / <a href="http://twitter.com/jfried83">Twitter</a> / <a href="https://github.com/krimdomu/Rex">Github</a> / <a href="http://www.freelists.org/list/rex-users">Mailinglist</a> / <a href="irc://irc.freenode.net/rex">irc.freenode.net #rex</a>&nbsp;&nbsp;&nbsp;-.ô.-&nbsp;&nbsp;&nbsp;<a href="http://www.disclaimer.de/disclaimer.htm" target="_blank">Disclaimer</a>
         </div>
      </div>

     <a href="http://github.com/Krimdomu/Rex"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png" alt="Fork me on GitHub"></a>


   </div>
      
   </body>

      <script type="text/javascript" charset="utf-8" src="http://rexify.org/js/jquery-1.5.2.min.js"></script>
   <script type="text/javascript" charset="utf-8" src="http://rexify.org/js/highlight.js"></script>

   <script type="text/javascript" charset="utf-8">


      $(".perl").each(function(a,b) {

         HighlightCode(b);
            
      });

      if($.browser.msie) {
         $("#nav_img").css("float", "left");
      }
      if($.browser.opera) {
         $("#nav_img").css("float", "left");
      }


      $(".navlinks").show();

   </script>

<!-- Piwik --> 
<script type="text/javascript">
var pkBaseURL = (("https:" == document.location.protocol) ? "https://rexify.org/stats/" : "http://rexify.org/stats/");
document.write(unescape("%3Cscript src='" + pkBaseURL + "piwik.js' type='text/javascript'%3E%3C/script%3E"));
</script><script type="text/javascript">
try {
var piwikTracker = Piwik.getTracker(pkBaseURL + "piwik.php", 1);
piwikTracker.trackPageView();
piwikTracker.enableLinkTracking();
} catch( err ) {}
</script><noscript><p><img src="http://rexify.org/stats/piwik.php?idsite=1" style="border:0" alt="" /></p></noscript>
<!-- End Piwik Tracking Code -->


   <script type="text/javascript" charset="utf-8">
      var to_move = 724;
      if($.browser.msie) {
         $("#nav_img").css("float", "left");
         to_move = 730;
      }
      if($.browser.opera) {
         $("#nav_img").css("float", "left");
      }

      function slide_left() {

         $("#bilderlinie").animate({"left": "-=" + to_move}, 2000, function() {
                  if(parseInt($("#bilderlinie").css("left")) < -1650) {
                     window.setTimeout(function() { slide_right(); }, 7000);
                  }
                  else {
                     window.setTimeout(function() { slide_left(); }, 7000);
                  }
               });

      }

      function slide_right() {
         $("#bilderlinie").animate({"left": "+=" + to_move}, 2000, function() {
                  if(parseInt($("#bilderlinie").css("left")) == 0) { 
                     window.setTimeout(function() { slide_left(); }, 7000);
                  }
                  else {
                     window.setTimeout(function() { slide_right(); }, 7000);
                  }
               
               });
      }

      window.setTimeout(function() { slide_left(); }, 5000);

   </script>


</html>

