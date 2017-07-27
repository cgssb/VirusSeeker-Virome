#!/usr/bin/perl -w
use strict;
my $usage='
perl script <sample dir>
<sample dir> = full path of the folder holding files for this sample
               without last "/"
';
die $usage unless scalar @ARGV == 1;
my ( $dir ) = @ARGV;

if ($dir =~/(.+)\/$/) {
        $dir = $1;
}
my $sample_name = (split(/\//,$dir))[-1];
#print $sample_name,"\n";

my $finished = &check_split_output($dir);
#print $finished; 
exit ($finished);

##############################################################
sub check_split_output {
	my ( $dir ) = @_;
	my @file_not_finished_parsed = ();
	my @file_not_finished_blast = ();
	my $all_file_finished = 1;

	my $BLAST_dir = $dir."/".$sample_name."_BLASTX_NR";
	opendir(DH, $BLAST_dir) or return 10;
	foreach my $file (readdir DH) {
		if ($file =~ /\.fasta$/ ) { 
			my $file_name = $file;
			$file_name =~ s/fasta$/blastx\.parsed/;
			my $parsedFile = $BLAST_dir."/".$file_name;
#			print "file name is $parsedFile\n";
			if (-e $parsedFile ) {# have parsed file, check for completeness
				my $temp = `grep \"Summary\" $parsedFile `;
				if (!($temp =~ /Summary/)) {
					$all_file_finished = 0;
					push @file_not_finished_parsed, $file;
				}
			}
			else { # parsed file does not exist
				$all_file_finished = 0;
				push @file_not_finished_parsed, $file;
			}

			# get blast output file not finished
			$file_name = $file;
			$file_name =~ s/fasta$/blastx\.out/;
			my $BlastOutFile = $BLAST_dir."/".$file_name;
#			print "file name is $BlastOutFile\n";
			if (-e $BlastOutFile ) {# have out put file, check for completeness
				my $temp = `grep \"Matrix:\" $BlastOutFile `;
				if (!($temp =~ /Matrix:/)) {
					push @file_not_finished_blast, $file;
				}
			}
			else { # blast output file does not exist
				push @file_not_finished_blast, $file;
			}

		}
	}
	close DH; 


	if($all_file_finished) { 
		print "all files finished.\n";
		return 0; 
	} 
	else {  
 		my @sorted = sort (@file_not_finished_blast);
		print "following files did not finish blast : \n";
		foreach my $file ( @sorted) {
			print "$file\n";
		}
		print"\n";
 
 		@sorted = sort (@file_not_finished_parsed);
		print "following files parsed file is not correct : \n";
		foreach my $file ( @sorted) {
			print "$file\n";
		}
	  	return 10; 
	}
}
