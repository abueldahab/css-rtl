#!/usr/bin/perl
# css-rtl.pl - a CSS LTR ? RTL converter
# Copyright Ahmad AlTwaijiry 2011 (Inspired by r2 https://github.com/ded/r2)
# https://github.com/mrahmadt/
# License MIT


$cssIntput = $ARGV[0];

unless(-e $cssIntput){
print "file $cssIntput not found!\n\n";
exit;
}

$cssOutput='';

if($ARGV[1] eq "-o"){
$cssOutput = $ARGV[2];
if($cssOutput eq "") { $cssOutput = "$cssIntput" . ".rtl";}
print "Input: $cssIntput\n";
print "Output: $cssOutput\n";
}

%Namereplaceit = ();

%Valuereplaceit = ();



# for float & clear
$Valuereplaceit{'left'} = 'right';
$Valuereplaceit{'right'} = 'left';

# for direction
$Valuereplaceit{'ltr'} = 'rtl';
$Valuereplaceit{'rtl'} = 'ltr';


$Namereplaceit{'margin-left'} = 'margin-right';
$Namereplaceit{'margin-right'} = 'margin-left';
$Namereplaceit{'padding-left'} = 'padding-right';
$Namereplaceit{'padding-right'} = 'padding-left';
$Namereplaceit{'border-left'} = 'margin-right';
$Namereplaceit{'border-left-width'} = 'border-right-width';
$Namereplaceit{'border-right-width'} = 'border-left-width';
$Namereplaceit{'border-radius-bottomleft'} = 'border-radius-bottomright';
$Namereplaceit{'border-radius-bottomright'} = 'border-radius-bottomleft';
$Namereplaceit{'-moz-border-radius-bottomright'} = '-moz-border-radius-bottomleft';
$Namereplaceit{'-moz-border-radius-bottomleft'} = '-moz-border-radius-bottomright';
$Namereplaceit{'left'} = 'right';
$Namereplaceit{'right'} = 'left';

#print $Namereplaceit[0][1];;

local $/=undef;
open(CSSIN,"<$cssIntput") || die("Can not open $cssIntput");
$CSSDATA = <CSSIN>;
close CSSIN;

$CSSDATA=trim($CSSDATA); #remove space
$CSSDATA =~ s/\/\*[\s\S]+?\*\///g;  #comments
$CSSDATA =~ s/[\n\r]//g; # line breaks and carriage returns

$CSSDATA =~ s/\s*([:;,{}])\s*/\1/g; # space between selectors, declarations, properties and values
$CSSDATA =~ s/\s+/ /g; # replace multiple spaces with single spaces

@CSS = split(/([^{]+\{[^}]+\})+?/g,$CSSDATA);

$output = '';

foreach $line (@CSS){
if($line eq '') {next;}
# break rule into selector|declaration parts
($selector,$declarations) = split(/\{/,$line);
$declarations =~ s/\}$//g;
$output .= $selector . "{\n";
@decl = split(/;(?!base64)/,$declarations);
        foreach $de (@decl){
                if($de eq '') {next;}
                    ($n,@v) = split(/:/,$de);
                    $v = join(':',@v);
					if(exists $Namereplaceit{$n}){
						$n =  $Namereplaceit{$n};
					}
					if(exists $Valuereplaceit{$v}){
						$v =  $Valuereplaceit{$v};
					}
					
					#padding margin border-radius -moz-border-radius -webkit-border-radius
					if( ($n eq 'padding') or ($n eq 'margin') or ($n eq 'border-radius') or ($n eq '-moz-border-radius') or ($n eq '-webkit-border-radius')){
						$v = quad($v);
					}
					#FIXME for 
					#box-shadow:0 3px 7px rgba(0,0,0,0.3);
					#-moz-box-shadow:0 3px 7px rgba(0,0,0,0.3);
					#-webkit-box-shadow:0 3px 7px rgba(0,0,0,0.3);

					$output .= "$n:$v;\n";
        }
$output .= "}\n";

}

if($cssOutput ne ''){
open(CSS,">$cssOutput") || die("Can not write to $cssOutput\n");
print CSS $output;
close CSS;
}else{
print $output;
}

sub trim($){
my $text=shift;
$text =~ s/^\s+//mg;
$text =~ s/\s+$//mg;
return $text;
}

#padding margin
sub quad($) {
# 1px 2px 3px 4px => 1px 4px 3px 2px
my $v=shift;
my @m = split(/\s+/,$v);

if($#m != 4){ return $v; }
return $m[0] ." ". $m[3] ." ". $m[2] ." ". $m[1];
}


