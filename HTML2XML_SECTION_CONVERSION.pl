

$_='

<p>START</p>
<h3>Heading3</h3>
<p>Skip H2</p>
<h4/>
<p>Self-close, no title</p>
<h6>Heading6</h6>
<p>skip H5</p>
<h1>Heading1</h1>
<p>Test</p>
<h2>Heading2</h2>
<p>Test</p>
<h3>Heading3</h3>
<p>Test</p>
<h4>Heading4</h4>
<p>Test</p>
<h5>Heading5</h5>
<p>Test</p>
<h6>Heading6</h6>
<p>Test</p>
<h2>Heading2</h2>
<p>Test</p>
<h1>Heading1</h1>
<p>Test</p>
<h6>Heading6</h6>
<p>Skip all level</p>
<h1>Heading1</h1>
<p>END</p>
';

$_ = &HTML2XML_SECTION($_);
print $_;




sub HTML2XML_SECTION
{
	my ($data, $SecCount, $MaxLevel, %sec) = (shift, 1, 6);

	$data= "<h1\/>\n".$data if($data!~/^\s*<h1/si);
	$data=~s/<(h\d)\/>/<$1><\/$1>/sgi;
	while($data=~/<h(\d)((?:(?!<h\d).)*?)<h(\d)/sgi)
	{
		my $temp = $&;
		
		#h3
		$temp=~s/<h1((?:(?!<h\d).)*?)<h3/<h1$1<h2\/>\n<h3/si;
		#h4
		$temp=~s/<h1((?:(?!<h\d).)*?)<h4/<h1$1<h2\/>\n<h3\/>\n<h4/si;
		$temp=~s/<h2((?:(?!<h\d).)*?)<h4/<h2$1<h3\/>\n<h4/si;
		#h5
		$temp=~s/<h1((?:(?!<h\d).)*?)<h5/<h1$1<h2\/>\n<h3\/>\n<h4\/>\n<h5/si;
		$temp=~s/<h2((?:(?!<h\d).)*?)<h5/<h2$1\n<h3\/>\n<h4\/>\n<h5/si;
		$temp=~s/<h3((?:(?!<h\d).)*?)<h5/<h3$1\n<h4\/>\n<h5/si;
		#h6
		$temp=~s/<h1((?:(?!<h\d).)*?)<h6/<h1$1<h2\/>\n<h3\/>\n<h4\/>\n<h5\/>\n<h6/si;
		$temp=~s/<h2((?:(?!<h\d).)*?)<h6/<h2$1\n<h3\/>\n<h4\/>\n<h5\/>\n<h6/si;
		$temp=~s/<h3((?:(?!<h\d).)*?)<h6/<h3$1\n<h4\/>\n<h5\/>\n<h6/si;
		$temp=~s/<h4((?:(?!<h\d).)*?)<h6/<h4$1\n<h5\/>\n<h6/si;
		
		$temp=~s/<(h\d)/<X$1/si;
		$data=~s/<h(\d)((?:(?!<h\d).)*?)<h(\d)/$temp/si;
	}
	$data=~s/<X(h\d)/<$1/sgi;

	$data = $data."\n<EOF class=\"DUMMY\"\/>";
	$data =~s/<(h\d)\b([^><]*)\/>/<$1$2><\/$1>/sgi;

	foreach my $level(reverse(1..$MaxLevel))
	{
		my $ifir = '<xsec0 scount="00"/>';
		if($data=~/<h$level/si)
		{
			while($data=~s#<h$level\b([^><]*)>((?:(?!<\/h$level\d).)*?)<\/h$level>((?:(?!(?:<xsec$level|<\/?h\d|<EOF)).)*?)(<xsec$level|<\/?h\d|<EOF)#
			my $Curr = $&;
			$Curr=~s/<h$level\b([^><]*)>((?:(?!<\/h$level\d).)*?)<\/h$level>((?:(?!(?:<xsec$level|<\/?h\d|<EOF)).)*?)(<xsec$level|<\/?h\d|<EOF)/<sec$level$1>\n<title>$2<\/title>$3\n<\/sec$level>$4/si;
			$ifir=~s/<xsec\d scount="\d+"\/>/<xsec$level scount="$SecCount"\/>/si;
			$Curr=~s/<sec$level\b[^><]*>(?:(?!<\/?sec).)*?<\/sec$level>/$ifir\n/si;
			$sec{$SecCount} = $&;
			$SecCount++;
			($Curr);
			#sige) { }
		}
	}

	$data =~s/\s*<EOF class=\"DUMMY\"\/>//s;
	$SecCount = $SecCount - 1;
	foreach my $key(reverse(1..$SecCount))
	{
		$data =~s/<xsec\d scount="$key"\/>/$sec{$key}/si;
	}
	$data =~s/\s*<title>\s*<\/title>//sgi;
	#$data =~s/<(\/)?sec\d>/<$1sec>/sgi;
	$data =~s/\n\n*/\n/sg;
	
	return $data;
}






