#############################################################
#vars used for comment block in order generated in comments
#############################################################
my $name;#provided by user
my $class;#known
my $section;#provided by user
my $professor;#known
my $term;#known
my $project;#provided by user
my $fileName;#provided by user

my $overallPurpose;#provided by user

my @libs;#generated via parsing

my @constructors;#generated via parsing
my @getters;#parsed then determined by user
my @setters;#parsed determined by user
my @methods;#generated via parsing
my @methodComments;#given by user, prompted per function, positions match methods

#formatting
my $paddingChar = "-";
my $spaceChar = " ";
my $paddingInterruptLeftChar = ">";
my $paddingInterrptRightChar = "<";
my $cornerChar = "+";
my $rightCommentChar = "!";
my $lineLength = 80;#arbitrary
my $leftTabSize = 3;#arbitrary
#############################################################
#vars used to affect program functionality
#############################################################
my $debugMode=0;#verbose
my $blnParseForFunctions=1;#unsupported

#############################################################
#subroutines to aid in making all things seem cleaner
#############################################################

#1 arg to print if in debug mode
sub printDebugLine {
	if ($debugMode) {
		print @_;
	}
}

#1 arg to recieve input
sub getCleanInputFromSTDIN {
	$_[0] = <STDIN>;
	chomp($_[0]);
}

#1 arg = var to recieve contents
sub readFileContents {
	printDebugLine $fileName;
	open FILE,$fileName or die "\r\nfailed to open file\r\n";
	my $defaultLineDelim = $/;
	$/ = undef;
	$_[0] = <FILE>;
	$/ = $defaultLineDelim;
	close FILE;
}

#1 arg for how many times
#2 arg to recieve
sub addPadding {
	for (my $counter = 0; $counter < $_[0]; $counter++) {
		$_[1]=$_[1].$paddingChar;
	}
}

sub addSpace {
	for (my $counter = 0; $counter < $_[0]; $counter++) {
		$_[1]=$_[1].$spaceChar;
	}
}
######################################################################################
#Parsing logic
######################################################################################
#go go gadget, this guy works alone -- no args but requires that a filename has been provided
sub findFunctions {
	my $fileContents;
	readFileContents($fileContents);
	@methods = $fileContents =~ m/public\s*\w*\s*\w*\s+\w+\s*\(.*\)\s*{|protected\s*\w*\s+\w+\s*\(.*\)\s*{|private\s+\w*\s+\w+\s*\(.*\)\s*{/ig;
	@libs = $fileContents =~ m/import\s+\w+\s+([a-z\-_.A-Z0-9]+);|import\s+([a-z\-_.A-Z0-9]+);/g;
	printDebugLine "\r\nfunctions matched(".@methods."):\r\n";
	printDebugLine @methods;
	printDebugLine "\r\n";
		
	#find constructors
	#ask user for their purposes
	my @newMethods;
	my $className = $fileName;
	$className =~ s/\.java//g;
	printDebugLine "\r\nclassName determined to be:".$className."\r\n";
	foreach my $function (@methods) {
		$function = substr($function,0,length($function)-2);
		#$function =~ s/public|private|protected/ /g;
		chomp($function);

		if ($function =~ m/\s+$className\s*/) {push @constructors, $function;}
		else {
			push @newMethods,$function;
			my $fpurpose;
			print "\r\nType notes for ".$function.", if it is a getter or setter put in G or S -- hit enter to finish\r\n";
			getCleanInputFromSTDIN($fpurpose);
			if ($fpurpose eq "G") {pop @newMethods; push @getters,$function;}
			elsif ($fpurpose eq "S") {pop @newMethods; push @setters,$function;}
			else{ 
			push @methodComments, $fpurpose;
			}
		}
	}
	@methods = @newMethods;
	printDebugLine "\r\nLibs\r\n";
	printDebugLine @libs;
	printDebugLine "\r\nConstructors\r\n";
	printDebugLine @constructors;
	printDebugLine "\r\ngetters\r\n";
	printDebugLine @getters;
	printDebugLine "\r\nsetters\r\n";
	printDebugLine @setters;
	printDebugLine "\r\nMethods and their comments\r\n";
	printDebugLine @methods;
	printDebugLine @methodComments;
}
#like find functions just needs a filename to latch onto
sub findLibs {
}
######################################################################################
#Heavy comment generation
######################################################################################

#1 arg to generate one or more properly formatted lines for the comment block
#2 arg to recieve
#arg 1 optional to flag as beginning or end line using beginning or end as value
#assumes filename given
sub generateCommentLine {
	if ($_[0] eq "beginning") {
		my $tmpPad;
		addPadding((int ($lineLength-(length($fileName." Program")+2))/2),$tmpPad);
		printDebugLine "\r\n!".$tmpPad."!\r\n";
		$_[1] = $_[1]."//".$tmpPad.$paddingInterruptLeftChar.$fileName." Program".$paddingInterrptRightChar.$tmpPad.$cornerChar."\r\n";
	} elsif ($_[0] eq "end") {
		my $tmpPad;
		addPadding($lineLength,$tmpPad);
		printDebugLine "\r\n!".$tmpPad."!\r\n";
		$_[1] = $_[1]."//".$tmpPad.$cornerChar."\r\n";
	} else {
		my $tabSpace;
		my $rightSpace;
		if (length($_[0])>(int 0.8*$lineLength)) {
			addSpace($leftTabSize,$tabSpace);
			addSpace($lineLength-(int 0.8*$lineLength)-$leftTabSize,$rightSpace);
		#a dedicated reader will see the fun behavior that could occur here... but the odds are against it
			$_[1] = $_[1]."//".$tabSpace.(substr($_[0],0,(int 0.8*$lineLength))).$rightSpace.$rightCommentChar."\r\n";
			generateCommentLine(substr($_[0],(int 0.8*$lineLength)),$_[1]);
		} else {
			addSpace($leftTabSize,$tabSpace);
			addSpace($lineLength-length($tabSpace.($_[0])),$rightSpace);
			$_[1] = $_[1]."//".$tabSpace.($_[0]).$rightSpace.$rightCommentChar."\r\n";
		}
	}
}

#this guy handles himself -- no args, however assumes the vars at top are populated
sub writeCommentBlock {
my $commentStr;#contains commentblock
generateCommentLine("beginning" 											,$commentStr);
generateCommentLine(""														,$commentStr);
generateCommentLine("NAME:       ".$name 									,$commentStr);
generateCommentLine("CLASS:      CS3330 - Object Oriented Programming" 		,$commentStr);
generateCommentLine("PROFESSOR:  Dean Zeller ".$section						,$commentStr);
generateCommentLine("TERM:       Fall, 2013"								,$commentStr);
generateCommentLine("PROJECT:    ".$project 								,$commentStr);
generateCommentLine("FILENAME:   ".$fileName 								,$commentStr);
generateCommentLine("",														,$commentStr);
generateCommentLine("OVERALL PURPOSE"										,$commentStr);
$leftTabSize = $leftTabSize*3;
generateCommentLine($overallPurpose											,$commentStr);
$leftTabSize = $leftTabSize/3;
generateCommentLine(""														,$commentStr);
generateCommentLine("LIBRARIES AND EXTERNAL FUNCTIONS"						,$commentStr);
$leftTabSize = $leftTabSize*3;
foreach my $lib (@libs) {
	if (length($lib)> 2){
		generateCommentLine($lib,											,$commentStr);
	}
}
if (@libs+0 == 0) {generateCommentLine("none"								,$commentStr);}
$leftTabSize = $leftTabSize/3;
generateCommentLine(""														,$commentStr);
generateCommentLine("METHODS"												,$commentStr);
$leftTabSize = $leftTabSize*3;
my $constructors = (join ", ",@constructors);
generateCommentLine("Constructors:   ".($constructors eq "" ? "none" : $constructors) ,$commentStr);
my $setters = (join ", ",@setters);
generateCommentLine("Set Functions:  ".$setters								,$commentStr);
my $getters = (join ", ",@getters);
generateCommentLine("Get Functions:  ".$getters								,$commentStr);
for (my $counter = 0; $counter < @methods; $counter++) {
generateCommentLine($methods[$counter]." -- ".$methodComments[$counter]		,$commentStr);
}
$leftTabSize = $leftTabSize/3;
generateCommentLine("CREDITS"												,$commentStr);
$leftTabSize = $leftTabSize*2;
generateCommentLine("This comment block was generated by ".
"Ben Sammons' Stellar Zeller Parser. Ben is not responsible".
"for the actual code in this       document in any way. ".$name." IS. (c) ".$name." 2013" ,$commentStr);
$leftTabSize = $leftTabSize/2;
generateCommentLine("end"													,$commentStr);
open FILE, $fileName or die "failed to open file again for writing";
$fileContents; 
readFileContents($fileContents);
truncate FILE, 0;
close FILE;
open FILE, ">", $fileName;
print FILE $commentStr.$fileContents;
close FILE;
}

######################################################################################
#Controlling logic, calls the subs and whatnot
######################################################################################
my $joy;
addPadding(25,$joy);
print $joy;
print "\ntype your functions out without their logic (just the headers) and then run this. Remember,\n".
"Documentation should be done during development, not after. (The program does work fine on finished code theoretically)\n\n";
print $joy;
print "\r\nEnter file to comment: ";
getCleanInputFromSTDIN($fileName);
print "Enter your name: ";
getCleanInputFromSTDIN($name);
print "Enter section letter (A,B,C):";
getCleanInputFromSTDIN($section);
if ($section eq "A") { $section = "(Lab A - 8:00 T, TA: Michael Brush)"}
elsif ($section eq "B") { $section ="(Lab B - 2:00 T, TA: William Starms)"}
elsif ($section eq "C") {$section ="(Lab C - 11:00 M, TA: Ankil Patel)"}
print "Enter Project: ";
getCleanInputFromSTDIN($project);
print "Enter Overall Purpose: ";
getCleanInputFromSTDIN($overallPurpose);
findLibs;
findFunctions;
writeCommentBlock;