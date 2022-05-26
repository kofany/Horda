########################################
### Horda 1.7 by kofany@irc.tldr.chat ##
### keepnick edition + notice         ##
## find me on irc.tldr.chat           ##
## www.tldr.chat                      ##
########################################
use strict;
use Irssi;
use Irssi::Irc;
use Irssi::UI;
use vars qw($VERSION %IRSSI);
use English qw( −no_match_vars );
my $username = getpwuid $UID;
### Ustawienia glownego hostu i linku do aktualizacji
### jesli chcesz aby przy kazdej aktualizacji 
### pojawial sie konkretny plik dla Ciebie pod Twoim unikalnym
### linkiem napisz do mnie na irc.tldr.chat lub IRCnet
### ############# zmien wartosci ponizej
#myhosts
my $update_link     = "dark-si.de/hkn.pl";
################################
### zmienne uzywane pozniej  ###
my $ver_acc 			= "1.7";
my $h_ver			= $ver_acc + 0.1;
my $perm_nick 			= $username;
my $rjoin_delay			= "60";		
%IRSSI = (
        contact => "kofany",
        name => "Horda",
        description => "Skrypt do zdalnego sterowania Irssi",
		license => "GPLv2",
		changed => "29.01.2022"
	);
# zmienne do ustawienia w irssi za pomoca /set
# np tryb na jaki ma zamykac za pomoca !lock itp
my $default_text       	= "[server]";
my $default_lock_key	= "+k server ";
my $default_lock_mode	= "+isnt ";
my $default_lock_limit	= "+l 10 ";
my $default_kick_mask	= "*!*\@*";
my $hdir = Irssi::get_irssi_dir();
my $filename		= "$hdir/hosty";
my $scriptfile		= "$hdir/scripts/autorun/h.pl";
unless(-e $filename) {
    #Tworzy plik z hostami jesli ten nie istnieje
system("touch $filename");
};
my @hosts = map {chomp $_; $_} `cat $filename`; 
my $go_on		= "1";
push @hosts, $owner;
#sprawdzanie czy host jest na liscie dodanych
sub chk_addr
{
 my ($host_temp) = @_;
 my $found = 0;
 foreach my $temp (@hosts)
 {
    unless($found)
    {
     if($host_temp eq $temp)
     {
      $found = 1;
     }
     else
     {
      $found = 0;
     }
    }
 };
 return $found;
};

sub serv_event {
	my ($server, $data, $nick, $address) = @_;
    
    my ($type, $data) = split(/ /, $data, 2);
    return unless ($type =~ /privmsg/i);
    my ($target, $text) = split(/ :/, $data, 2);
    $text =~ s/^\s+//i;

    # pobieramy ustawienia z irssi :)
    my $lock_key	= Irssi::settings_get_str("horda_lock_key");
    my $lock_mode	= Irssi::settings_get_str("horda_lock_mode");
    my $lock_limit	= Irssi::settings_get_str("horda_lock_limit");
    my $kick_reason	= Irssi::settings_get_str("horda_kick_reason");
    my $kick6		= Irssi::settings_get_bool("horda_kick6");
    my $kick_r 		= Irssi::settings_get_str("horda_kick_reason");
    my $kick_m		= Irssi::settings_get_str("horda_kick_mask");
### wlaczanie wylaczanie nasluchu  na PRIV!!!
if($text =~ "!stop")
{
    if(chk_addr($address))
    {
	$go_on = "0";
    };
};

if($text =~ "!start")
    {
    if(chk_addr($address))
    {
    $go_on = "1";
    };
};
### zmienne ktore mozemy ustawic na PRIV!!!
if($text =~ "!setnick")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $s_nick) = split(/ /, $text, 2);
	if($s_nick eq "")
	{
	$server->command("/quote notice $nick :Nie podano nicka - ustawiam nick na $username - aby zmienic wpisz !setnick jakis_nick");
	$perm_nick = $username;
	}
	else
	{
	$perm_nick = $s_nick;
    $server->command("/quote notice $nick :Nick ustawiono na $s_nick");
	}
	};
    };
};

if($text =~ "!say")
    {
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $text_say) = split(/ /, $text, 2);
	$server->command("/quote privmsg $target :".$text_say);
    };
    };
}; 

if($text =~ "!ver")
    {
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $text_say) = split(/ /, $text, 2);
	$server->command("/quote notice $nick :Horda $ver_acc +keepnick +notice edition  by kofany - znajdz mnie na irc.tldr.chat >> kanal #tldr >> https://www.tldr.chat");
    };
    };
};
 
if($text =~ "!add")
{
    if($go_on == "1")
    {
    if(chk_addr($address))
    {
    my ($s_cmd, $text_say) = split(/ /, $text, 2);
	if($text_say eq "")
	{
    $server->command("/quote notice $nick :Lista dodanych hostow: @hosts ");
	}
	elsif($text_say eq $owner)
	{
	$server->command("/quote notice $nick :Wyglada na to ze $text_say juz istnieje na liscie hostow");
	}
	elsif(my ($matched) = grep $_ eq $text_say, @hosts)
	{
	$server->command("/quote notice $nick :Wyglada na to ze $matched juz istnieje na liscie hostow");
	}
	else
	{
	push @hosts, $text_say;
	$server->command("/quote notice $nick :Dodano $text_say");
	open(FH, '>>', $filename) or die $!;
	print FH $text_say;
	print FH "\n";
	close(FH);
	};
	};
	};
};

if($text =~ "!del")
{
    if($go_on == "1")
    {
    if(chk_addr($address))
    {
    my ($s_cmd, $text_say) = split(/ /, $text, 2);
	if($text_say eq $owner)
	{
	$server->command("/quote notice $nick :Nie usuniesz naczelnego Hordy!");
	}
	elsif($text_say eq "")
	{
    $server->command("/quote notice $nick :Aktualnie slucham polecen od @hosts ");
	}
	else
	{
	@hosts = grep {!/$text_say/} @hosts;
	system("sed -i.bak '/^$text_say/d' $filename");
	$server->command("/quote notice $nick :Usunieto host $text_say ");
	}    
	};
	};
};

if($text =~ "!msg")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $s_nick, $text_say) = split(/ /, $text, 3);
	$server->command("/msg $s_nick ".$text_say);
    };
    };
};

if($text =~ "!nick")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	$server->command("/quote nick $perm_nick");
    };
    };
};

if($text =~ "!0")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	$server->command("/quote nick 0");
    };
    };
};

if($text =~ "!rand")
    {
    if($go_on == "1")
    { 
    if(chk_addr($address))
    {
	my @chars = ("A".."Z", "a".."z");
	my $rnick;
	$rnick .= $chars[rand @chars] for 1..8;
    my ($s_cmd);
    $server->command("/quote nick $rnick");
    };
    };
};

if($text =~ "&j")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $s_chan) = split(/ /, $text, 2);
	$server->command("/quote join $s_chan");
	};
    };
};
if($text =~ "!rjoin")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $s_chan) = split(/ /, $text, 2);
	select(undef, undef, undef, rand($rjoin_delay));
	$server->command("/quote ping $server");
	select(undef, undef, undef, rand($rjoin_delay));
	$server->command("/quote ping $server");
	select(undef, undef, undef, rand($rjoin_delay));
	$server->command("/quote join $s_chan");
	};
    };
};


if($text =~ "&p")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $s_chan, $text_say) = split(/ /, $text, 3);
	$server->command("/part $s_chan ".$text_say);
	};
    };
};

if($text =~ "!rpart")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $s_chan, $text_say) = split(/ /, $text, 3);
	select(undef, undef, undef, rand($rjoin_delay));
	$server->command("/quote ping $server");
	select(undef, undef, undef, rand($rjoin_delay));
	$server->command("/quote ping $server");
	select(undef, undef, undef, rand($rjoin_delay));
	$server->command("/part $s_chan ".$text_say);
	};
    };
};


if($text eq "!close")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my $serv_nick = $server->{nick};
	my $witem = Irssi::window_item_find($target);
	my $channel = $witem->{name};
	my @to_kick = ();
	my @nick_list = ();
	foreach my $hash ($witem->nicks())
	{
	my $nick = $hash->{nick};
  	my $host = $hash->{host};

	next if ($nick eq $serv_nick or chk_addr($host));
	my $is_op = $hash->{op};
	my $is_voice = $hash->{voice};
		
#	if (!$is_op or 
#   $is_voice or
#   !$is_op && !$is_voice)
#	{
    push(@to_kick,$nick);
    my $mod = ($is_op == 1) ? "\@" : ($is_voice == 1) ? "+" : undef;
    push(@nick_list, $mod.$nick);
#		};
	};
	while (@to_kick)
	{
	$server->send_raw("KICK $target ".join(",", @to_kick[0..5])." :$kick_r");
	@to_kick = @to_kick[6..$#to_kick];
	};
	};
    };
};

if($text =~ "!op")
{
    if($go_on == "1")
    { 
    if(chk_addr($address))
    {
	my ($s_cmd, $s_nick) = split(/ /, $text, 2);
	$server->command("/quote mode $target +o $s_nick");
	};
    };
};

if($text =~ "!k")
{
    if($go_on == "1")
    { 
    if(chk_addr($address))
    {
	my ($s_cmd, $s_nick, $text_say) = split(/ /, $text, 3);
	$server->command("/kick $target $s_nick ".$text_say);
	};
    };
};

if($text =~ "!kbi")
{
    if($go_on == "1")
    { 
    if(chk_addr($address))
    {
	my ($s_cmd, $s_nick, $text_say) = split(/ /, $text, 3);
	if($text_say eq "")
	{	
	$server->command("/ban $target ".$s_nick);
	$server->command("/kick $target $s_nick ".$kick_r);
	}
	else
	{
	$server->command("/ban $target ".$s_nick);	
	$server->command("/kick $target $s_nick ".$text_say);		
	}
	};
    };
};

if($text =~ "!b")
    {
    if($go_on == "1")
    { 
    if(chk_addr($address))
	{
	my ($s_cmd, $s_nick) = split(/ /, $text, 2);
	$server->command("/ban $target ".$s_nick);
	};
    };
};

if($text =~ "!ub")
{ 
    if($go_on == "1")
    { 
    if(chk_addr($address))
	{
	my ($s_cmd, $s_mask) = split(/ /, $text, 2);
	$server->command("/quote mode $target -b ".$s_mask);
	};
    };
};
		    
if($text =~ "!dop")
{
    if($go_on == "1")
    { 
    if(chk_addr($address))
    {
	my ($s_cmd, $s_nick) = split(/ /, $text, 2);
	$server->command("/quote mode $target -o $s_nick");
	};
    };
};
    
if($text =~ "!v")
{
    if($go_on == "1")
    { 
    if(chk_addr($address))
	{
	my ($s_cmd, $s_nick) = split(/ /, $text, 2);
	$server->command("/quote mode $target +v $s_nick");
	};
    };
};

if($text =~ "!dv")
{
    if($go_on == "1")
    { 
    if(chk_addr($address))
    {
	my ($s_cmd, $s_nick) = split(/ /, $text, 2);
	$server->command("/quote mode $target -v $s_nick");
	};
    };
};

if($text =~ "!topic")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	my ($s_cmd, $topic) = split(/ /, $text, 2);
	$server->command("/topic $target ".$topic);
	};
    };
};

if($text eq "!a")
{
    if($go_on == "1")
    { 
    if(chk_addr($address))
	{
	 $server->command("/quote notice $nick :Rozkazuj moj panie;)");
	}
	else
	{
	 $server->command("/quote notice $nick :nie, niestety, nie pogadamy :)");
	};
    };
};

if($text eq "!lock")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	    $server->command("/quote mode $target " . $lock_mode . $lock_key . $lock_limit);
	};
    };
};

if($text eq "!unlock")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	$server->command("/quote mode $target -skl");
	$server->command("/quote mode $target -s");
	$server->command("/quote mode $target -k");
	$server->command("/quote mode $target -l");
	};
    };
};

if($text eq "!clean")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
	if (-f $filename)
	{
	$server->command("/quote notice $nick :Usuwam userliste");
	system("cat /dev/null > $filename");
	};
	sleep(2);
	@hosts = ();
	push @hosts, $owner;
	};
    };
};

if($text eq "!info")
{
    if($go_on == "1")
    { 
	if(chk_addr($address))
	{
		$server->command("/quote notice $nick :Komenda !stop - zatrzymuje dzialanie nasluchu w danej sesji (uzywaj na priv)");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !start - wzawia dzialanie nasluchu w danej sesji (uzywaj na priv)");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !setnick nick - ustawia glowny nick sesji (uzywaj na priv)");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !say tekst - wypowiada tekst na danym kanale ");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !add host - dodaje host ktorego slucha skrypt format ident\@host");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !del host - usuwa host ktorego slucha skrypt");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !msg nick tekst - wysyla wiadomosc do danego nicka");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !nick - zmienia nick na ustawiony komenda !setnick");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !0 - nick 0");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !rand - zmienia nick na losowy");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda &j #kanal - wejscie na kanal natychmiastowe - przy duzej ilosci sesji floodjoin...");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !rjoin #kanal - wejdzoe z losowym opoznieniem");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda &p #kanal tekst_part - wyjscie z kanalu natychmiastowe z podanym tekstem ");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !rpart #kanal tekst_part - wyjscie z kanalu z podanym losowym opoznieniem z okreslonym tekstem");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !close - zamyka kanal + masskick");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !op nick - wiadomo");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !k nick tekst - wykopuje nick z okreslonym tekstem");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !kbi nick tekst - kick ban z okreslonym tekstem");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !b nick - banuje osobe po hoscie.");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !ub host - odbanowuje dany host np. !ub *!k\@okkin.fi");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !dop nick - deopuje nick");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !v nick - daje voice");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !dv nick - zabiera voice");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !topic tekst - ustawia topic z danym tekstem");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !a - Powie Ci czy Twoj host jest dopisany po notice :)");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !lock - zamyka kanal bez mass kick");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !unlock - otwiera kanal");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !update - aktualizuje skrypt");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !ver - wyswietla nr wersji");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !clean - usuwa userliste - owner pozostaje bez zmian");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !kn nick - wlacza keepnick ");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !ukn - wylacza keepnick");
		sleep(0.2);
		$server->command("/quote notice $nick :Komenda !info - wyswietla powyzsze info (uzywaj tylko na priv do 1 sesji!!)");
	};
	};
};
#keepnick
if($text =~ "!kn")
    {
    if($go_on == "1")
    { 
    if(chk_addr($address))
	{
	my ($s_cmd, $s_nick) = split(/ /, $text, 2);
	$server->command("/keepnick ".$s_nick);
	};
    };
};

if($text =~ "!ukn")
    {
    if($go_on == "1")
    { 
    if(chk_addr($address))
	{
	my ($s_cmd, $s_nick) = split(/ /, $text, 2);
	$server->command("/unkeepnick");
	};
    };
};


if($text eq "!update")
{
    if($go_on == "1")
    {
	if(chk_addr($address))
	{
    	$server->command("/quote notice $nick :Aktualizuje Horde!");
		system("wget -q $update_link -O $hdir/hnew.pl");
		system("awk -v var="my \$owner           = \"$owner\";" '/#myhosts/{ print var } 1' hnew.pl >> tempfile && mv tempfile hnew.pl");
		system("cp $hdir/scripts/autorun/hkn.pl $hdir/hold.pl");
		system("cp $hdir/hnew.pl $hdir/scripts/autorun/hkn.pl");
		$server->command("/quote notice $nick :Rozpoczynam aktulizacje do $h_ver");
		sleep(1);
		sleep(rand(5));
	if (-s  $scriptfile)
	{
	Irssi::command("script unload h.pl");
	Irssi::command("script load autorun/h.pl");
	$server->command("/quote notice $nick :Horda zaktualizowana do $h_ver");
	};
    };
	};
};
};
Irssi::settings_add_str("Horda","horda_lock_key", $default_lock_key);
Irssi::settings_add_str("Horda","horda_lock_mode", $default_lock_mode);
Irssi::settings_add_str("Horda","horda_lock_limit", $default_lock_limit);
Irssi::settings_add_str("Horda","horda_kick_reason", ":We are the Horde!");
Irssi::settings_add_str("Horda","horda_kick_mask",$default_kick_mask);
Irssi::settings_add_bool("Horda","horda_kick6",1);
Irssi::signal_add_last("server event", "serv_event");


my(%keepnick);		# nicks we want to keep
my(%getnick);		# nicks we are currently waiting for
my(%inactive);		# inactive chatnets
my(%manual);		# manual nickchanges

sub change_nick {
    my($server,$nick) = @_;
    $server->redirect_event('keepnick nick', 1, ":$nick", -1, undef,
			    {
			     "event nick" => "redir keepnick nick",
			     "" => "event empty",
			    });
    $server->send_raw("NICK :$nick");
}

sub check_nick {
    my($server,$net,$nick);

    %getnick = ();	# clear out any old entries

    for $net (keys %keepnick) {
	next if $inactive{$net};
	$server = Irssi::server_find_chatnet($net);
	next unless $server;
	next if lc $server->{nick} eq lc $keepnick{$net};

	$getnick{$net} = $keepnick{$net};
    }

    for $net (keys %getnick) {
	$server = Irssi::server_find_chatnet($net);
	next unless $server;
	next unless ref($server) eq 'Irssi::Irc::Server'; # this only work on IRC
	$nick = $getnick{$net};
	if (lc $server->{nick} eq lc $nick) {
	    delete $getnick{$net};
	    next;
	}
	$server->redirect_event('keepnick ison', 1, '', -1, undef,
				{ "event 303" => "redir keepnick ison" });
	$server->send_raw("ISON :$nick");
    }
}

sub load_nicks {
    my($file) = Irssi::get_irssi_dir."/keepnick";
    my($count) = 0;
    local(*CONF);

    %keepnick = ();
    open CONF, "<", $file;
    while (<CONF>) {
	my($net,$nick) = split;
	if ($net && $nick) {
	    $keepnick{lc $net} = $nick;
	    $count++;
	}
    }
    close CONF;

    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_crap',
		       "Loaded $count nicks from $file");
}

sub save_nicks {
    my($auto) = @_;
    my($file) = Irssi::get_irssi_dir."/keepnick";
    my($count) = 0;
    local(*CONF);

    return if $auto && !Irssi::settings_get_bool('keepnick_autosave');

    open CONF, ">", $file;
    for my $net (sort keys %keepnick) {
	print CONF "$net\t$keepnick{$net}\n";
	$count++;
    }
    close CONF;

    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_crap',
		       "Saved $count nicks to $file")
	unless $auto;
}

sub server_printformat {
    my($server,$level,$format,@params) = @_;
    my($emitted) = 0;
    for my $win (Irssi::windows) {
	for my $item ($win->items) {
	    next unless ref $item;
	    if ($item->{server}{chatnet} eq $server->{chatnet}) {
		$item->printformat($level,$format,@params);
		$emitted++;
		last;
	    }
	}
    }
    $server->printformat(undef,$level,$format,@params)
	unless $emitted;
}

# if anyone changes their nick, check if we want their old one.
sub sig_message_nick {
    my($server,$newnick,$oldnick) = @_;
    my($chatnet) = lc $server->{chatnet};
    if (lc $oldnick eq lc $getnick{$chatnet}) {
	change_nick($server, $getnick{$chatnet});
    }
}

# if we change our nick, check it to see if we wanted it and if so
# remove it from the list.
sub sig_message_own_nick {
    my($server,$newnick,$oldnick) = @_;
    my($chatnet) = lc $server->{chatnet};
    if (lc $newnick eq lc $keepnick{$chatnet}) {
	delete $getnick{$chatnet};
	if ($inactive{$chatnet}) {
	    delete $inactive{$chatnet};
	    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_unhold',
			       $newnick, $chatnet);
	}
    } elsif (lc $oldnick eq lc $keepnick{$chatnet} &&
	     lc $newnick eq lc $manual{$chatnet}) {
	$inactive{$chatnet} = 1;
	delete $getnick{$chatnet};
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_hold',
			   $oldnick, $chatnet);
    }
}

sub sig_message_own_nick_block {
    my($server,$new,$old,$addr) = @_;
    Irssi::signal_stop();
    if (Irssi::settings_get_bool('keepnick_quiet')) {
	Irssi::printformat(MSGLEVEL_NICKS | MSGLEVEL_NO_ACT,
			   'keepnick_got_nick', $new, $server->{chatnet});
    } else {
	server_printformat($server, MSGLEVEL_NICKS | MSGLEVEL_NO_ACT,
			   'keepnick_got_nick', $new, $server->{chatnet});
    }
}

# if anyone quits, check if we want their nick.
sub sig_message_quit {
    my($server,$nick) = @_;
    my($chatnet) = lc $server->{chatnet};
    if (lc $nick eq lc $getnick{$chatnet}) {
	change_nick($server, $getnick{$chatnet});
    }
}

sub sig_redir_keepnick_ison {
    my($server,$text) = @_;
    my $nick = $getnick{lc $server->{chatnet}};
    change_nick($server, $nick)
      unless $text =~ /:\Q$nick\E\s?$/i;
}

sub sig_redir_keepnick_nick {
    my($server,$args,$nick,$addr) = @_;
    Irssi::signal_add_first('message own_nick', 'sig_message_own_nick_block');
    Irssi::signal_emit('event nick', @_);
    Irssi::signal_remove('message own_nick', 'sig_message_own_nick_block');
}

# main setup is reread, so let us do it too
sub sig_setup_reread {
    load_nicks;
}

# main config is saved, and so we should save too
sub sig_setup_save {
    my($mainconf,$auto) = @_;
    save_nicks($auto);
}

# Usage: /KEEPNICK [-net <chatnet>] [<nick>]
sub cmd_keepnick {
    my(@params) = split " ", shift;
    my($server) = @_;
    my($chatnet,$nick,@opts);

    # parse named parameters from the parameterlist
    while (@params) {
	my($param) = shift @params;
	if ($param =~ /^-(chat|irc)?net$/i) {
	    $chatnet = shift @params;
	} elsif ($param =~ /^-/) {
	    Irssi::print("Unknown parameter $param");
	} else {
	    push @opts, $param;
	}
    }
    $nick = shift @opts;

    # check if the ircnet specified (if any) is valid, and if so get the
    # server for it
    if ($chatnet) {
	my($cn) = Irssi::chatnet_find($chatnet);
	unless ($cn) {
	    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_crap',
			       "Unknown chat network: $chatnet");
	    return;
	}
	$chatnet = $cn->{name};
	$server = Irssi::server_find_chatnet($chatnet);
    }

    # if we need a server, check if the one we got is connected.
    unless ($server || ($nick && $chatnet)) {
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_crap',
			   "Not connected to server");
	return;
    }

    # lets get the chatnet, and the nick we want
    $chatnet ||= $server->{chatnet};
    $nick    ||= $server->{nick};

    # check that we really have a chatnet
    unless ($chatnet) {
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_crap',
			   "Unable to find server network, maybe you forgot /server add before connecting?");
	return;
    }

    if ($inactive{lc $chatnet}) {
	delete $inactive{lc $chatnet};
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_unhold',
			   $nick, $chatnet);
    }

    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_add', $nick,
		       $chatnet);

    $keepnick{lc $chatnet} = $nick;

    save_nicks(1);
    check_nick();
}

# Usage: /UNKEEPNICK [<chatnet>]
sub cmd_unkeepnick {
    my($chatnet,$server) = @_;

    # check if the ircnet specified (if any) is valid, and if so get the
    # server for it
    if ($chatnet) {
	my($cn) = Irssi::chatnet_find($chatnet);
	unless ($cn) {
	    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_crap',
			       "Unknown chat network: $chatnet");
	    return;
	}
	$chatnet = $cn->{name};
    } else {
	$chatnet = $server->{chatnet};
    }

    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_remove',
		       $keepnick{lc $chatnet}, $chatnet);

    delete $keepnick{lc $chatnet};
    delete $getnick{lc $chatnet};

    save_nicks(1);
}

# Usage: /LISTNICK
sub cmd_listnick {
    my(@nets) = sort keys %keepnick;
    my $net;
    if (@nets) {
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_list_header');
	for (@nets) {
	    $net = Irssi::chatnet_find($_);
	    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_list_line',
			       $keepnick{$_},
			       $net ? $net->{name} : ">$_<",
			       $inactive{$_}?'inactive':'active');
	}
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_list_footer');
    } else {
	Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'keepnick_list_empty');
    }
}

sub cmd_nick {
    my($data,$server) = @_;
    my($nick) = split " ", $data;
    return unless $server;
    $manual{lc $server->{chatnet}} = $nick;
}

Irssi::settings_add_bool('keepnick', 'keepnick_autosave', 1);
Irssi::settings_add_bool('keepnick', 'keepnick_quiet', 0);

Irssi::theme_register(
[
 'keepnick_crap',
 '{line_start}{hilight Keepnick:} $0',

 'keepnick_add',
 '{line_start}{hilight Keepnick:} Now keeping {nick $0} on [$1]',

 'keepnick_remove',
 '{line_start}{hilight Keepnick:} Stopped trying to keep {nick $0} on [$1]',

 'keepnick_hold',
 '{line_start}{hilight Keepnick:} Nickkeeping deactivated on [$1]',

 'keepnick_unhold',
 '{line_start}{hilight Keepnick:} Nickkeeping reactivated on [$1]',

 'keepnick_list_empty',
 '{line_start}{hilight Keepnick:} No nicks in keep list',

 'keepnick_list_header',
 '',

 'keepnick_list_line',
 '{line_start}{hilight Keepnick:} Keeping {nick $0} in [$1] ($2)',

 'keepnick_list_footer',
 '',

 'keepnick_got_nick',
 '{hilight Keepnick:} Nickstealer left [$1], got {nick $0} back',

]);

Irssi::signal_add('message quit', 'sig_message_quit');
Irssi::signal_add('message nick', 'sig_message_nick');
Irssi::signal_add('message own_nick', 'sig_message_own_nick');

Irssi::signal_add('redir keepnick ison', 'sig_redir_keepnick_ison');
Irssi::signal_add('redir keepnick nick', 'sig_redir_keepnick_nick');

Irssi::signal_add('setup saved', 'sig_setup_save');
Irssi::signal_add('setup reread', 'sig_setup_reread');

Irssi::command_bind("keepnick", "cmd_keepnick");
Irssi::command_bind("unkeepnick", "cmd_unkeepnick");
Irssi::command_bind("listnick", "cmd_listnick");
Irssi::command_bind("nick", "cmd_nick");

Irssi::timeout_add(12000, 'check_nick', '');

Irssi::Irc::Server::redirect_register('keepnick ison', 0, 0,
			 undef,
			 {
			  "event 303" => -1,
			 },
			 undef );

Irssi::Irc::Server::redirect_register('keepnick nick', 0, 0,
			 undef,
			 {
			  "event nick" => 0,
			  "event 432" => -1,	# ERR_ERRONEUSNICKNAME
			  "event 433" => -1,	# ERR_NICKNAMEINUSE
			  "event 437" => -1,	# ERR_UNAVAILRESOURCE
			  "event 484" => -1,	# ERR_RESTRICTED
			 },
			 undef );

load_nicks;
