#!/usr/bin/perl

sub uniq2 {
    my %seen = ();
    my @r = ();
    foreach my $a (@_) {
        unless ($seen{$a}) {
            push @r, $a;
            $seen{$a} = 1;
        }
    }
    return @r;
}
  
use strict;
use warnings;

    my @allPersons;
    my @allUniquePersons;
    my @DonePerson;
    my $number_of_Persons=0;
    my $line ;
    my $index;
    my $numb;
    my $done=0 ;
    my $init_unique ;
    my $Person ;
    my $Person_is_done ;
    my $Still_more ;


# Set the Person unique id from the command line.

    print 'Number of arguments:', $#ARGV, "\n";
    if ($#ARGV != 0) {
           print "\n",'There must be one and only one command line argument (Root Person) to this script !!!', "\n";
           die ; 
    }
    my $RootPerson = $ARGV[0];
    $allPersons[$number_of_Persons] = $RootPerson; $number_of_Persons++ ;
    print "\n",'Extracting Root Person:', $RootPerson ,"\n";

# Extract from the Rodovid URL 

    my $status = system("wget http://en.rodovid.org/wk/Person:$RootPerson");
    $DonePerson[$done] = $RootPerson; $done++ ;

# Open the file 
    open FILE , "Person:$RootPerson" or die $! ;

# Read one line at the time and extract all new Person id numbers encountered 
    while ( $line = <FILE>) { 
	 
#         print $line ;
          my @strings = split("Person:",$line);
          for ($index = 1 ; $index < $#strings ; $index++) {
              my $str = $strings[$index];
#              print $str;
              my @numbers = split('\D',$str);
#             print @numbers[0], "\n";
              $allPersons[$number_of_Persons] = $numbers[0]; 
              $number_of_Persons++ ;
          }

    }
close FILE;
print 'Number of Persons including duplicates:',$#allPersons+1,"\n";

# Repeat operation with all pages corresponding to newly acquired numbers.


@allUniquePersons = uniq2(@allPersons);
print 'Number of unique Persons:',$#allUniquePersons+1,"\n";
@allUniquePersons = sort(@allUniquePersons);
$init_unique = $#allUniquePersons ;
$Still_more = 1; $numb=0;

while ($Still_more) {
   
#    if ($allUniquePersons[$number]  == $RootPerson) continue ;

# Extract from the Rodovid URL if this person has not yet been done
    $init_unique = $#allUniquePersons ;
    $Person = $allUniquePersons[$numb] ; $numb++ ;
    $Person_is_done = 0;
    for ($index=0; $index < $done ; $index++) {
        if($Person == $DonePerson[$index]) {
             $Person_is_done = 1 ;
        }
    }
    if($Person_is_done && $numb < $#allUniquePersons+1 ) {
           print "Person $Person already done","\n";
           next ;   
    } 

    if($Person_is_done && $numb == $#allUniquePersons+1 ) {
           $Still_more = 0 ;  
    } 

    my $stat = system("wget http://en.rodovid.org/wk/Person:$Person");
    $DonePerson[$done] = $Person ; $done++ ;
    print "\n",'Extracting Person number:', $allUniquePersons[$numb] ,"\n";

# Open the file 
    open FILE , "Person:$Person" or die $! ;

# Read one line at the time and extract all new Person id numbers encountered 
    while ( $line = <FILE>) { 
	 
#         print $line ;
          my @strings = split("Person:",$line);
          for ($index = 1 ; $index < $#strings ; $index++) {
              my $str = $strings[$index];
#              print $str;
              my @numbers = split('\D',$str);
              print $numbers[0], "\n";
              $allPersons[$number_of_Persons] = $numbers[0]; 
              $number_of_Persons++ ;
          }

    }
close FILE;
@allUniquePersons = uniq2(@allPersons);
@allUniquePersons = sort(@allUniquePersons);
print 'Number of unique Persons:',$#allUniquePersons+1,"\n";
$numb=0; 


open ( PERSONSFILE, '> UniquePersons');
for ($index=0; $index < $#allUniquePersons+1 ; $index++) {
      print PERSONSFILE $allUniquePersons[$index],"\n" ;      
      }
close PERSONSFILE ;
}
