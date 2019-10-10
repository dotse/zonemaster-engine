package Zonemaster::Engine::Test::Nameserver;

use version; our $VERSION = version->declare("v1.0.24");

use strict;
use warnings;

use 5.014002;

use Zonemaster::Engine;

use List::MoreUtils qw[uniq none];
use Locale::TextDomain qw[Zonemaster-Engine];
use Readonly;
use Zonemaster::Engine::Constants qw[:ip];
use Zonemaster::Engine::Test::Address;
use Zonemaster::Engine::Util;

Readonly my @NONEXISTENT_NAMES => qw{
  xn--nameservertest.iis.se
  xn--nameservertest.icann.org
  xn--nameservertest.ripe.net
};

###
### Entry Points
###

sub all {
    my ( $class, $zone ) = @_;
    my @results;

    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver01} ) ) {
        push @results, $class->nameserver01( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver02} ) ) {
        push @results, $class->nameserver02( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver03} ) ) {
        push @results, $class->nameserver03( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver04} ) ) {
        push @results, $class->nameserver04( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver05} ) ) {
        push @results, $class->nameserver05( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver06} ) ) {
        push @results, $class->nameserver06( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver07} ) ) {
        push @results, $class->nameserver07( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver08} ) ) {
        push @results, $class->nameserver08( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver09} ) ) {
        push @results, $class->nameserver09( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver10} ) ) {
        push @results, $class->nameserver10( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver11} ) ) {
        push @results, $class->nameserver11( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver12} ) ) {
        push @results, $class->nameserver12( $zone );
    }
    if ( Zonemaster::Engine::Util::should_run_test( q{nameserver13} ) ) {
        push @results, $class->nameserver13( $zone );
    }

    return @results;
} ## end sub all

###
### Metadata Exposure
###

sub metadata {
    my ( $class ) = @_;

    return {
        nameserver01 => [
            qw(
              IS_A_RECURSOR
              NO_RECURSOR
              NO_RESPONSE
              )
        ],
        nameserver02 => [
            qw(
              BREAKS_ON_EDNS
              EDNS_RESPONSE_WITHOUT_EDNS
              EDNS_VERSION_ERROR
              EDNS0_SUPPORT
              NO_EDNS_SUPPORT
              NO_RESPONSE
              NS_ERROR
              )
        ],
        nameserver03 => [
            qw(
              AXFR_FAILURE
              AXFR_AVAILABLE
              )
        ],
        nameserver04 => [
            qw(
              DIFFERENT_SOURCE_IP
              SAME_SOURCE_IP
              )
        ],
        nameserver05 => [
            qw(
              AAAA_BAD_RDATA
              AAAA_QUERY_DROPPED
              AAAA_UNEXPECTED_RCODE
              AAAA_WELL_PROCESSED
              A_UNEXPECTED_RCODE
              NO_RESPONSE
              IPV4_DISABLED
              IPV6_DISABLED
              )
        ],
        nameserver06 => [
            qw(
              CAN_NOT_BE_RESOLVED
              CAN_BE_RESOLVED
              NO_RESOLUTION
              )
        ],
        nameserver07 => [
            qw(
              UPWARD_REFERRAL_IRRELEVANT
              UPWARD_REFERRAL
              NO_UPWARD_REFERRAL
              )
        ],
        nameserver08 => [
            qw(
              QNAME_CASE_INSENSITIVE
              QNAME_CASE_SENSITIVE
              )
        ],
        nameserver09 => [
            qw(
              CASE_QUERY_SAME_ANSWER
              CASE_QUERY_DIFFERENT_ANSWER
              CASE_QUERY_SAME_RC
              CASE_QUERY_DIFFERENT_RC
              CASE_QUERY_NO_ANSWER
              CASE_QUERIES_RESULTS_OK
              CASE_QUERIES_RESULTS_DIFFER
              )
        ],
        nameserver10 => [
            qw(
              NO_RESPONSE
              NO_EDNS_SUPPORT
              UNSUPPORTED_EDNS_VER
              NS_ERROR
              )
        ],
        nameserver11 => [
            qw(
              NO_RESPONSE
              NO_EDNS_SUPPORT
              UNKNOWN_OPTION_CODE
              NS_ERROR
              )
        ],
        nameserver12 => [
            qw(
              NO_RESPONSE
              NO_EDNS_SUPPORT
              Z_FLAGS_NOTCLEAR
              NS_ERROR
              )
        ],
        nameserver13 => [
            qw(
              NO_RESPONSE
              NO_EDNS_SUPPORT
              NS_ERROR
              MISSING_OPT_IN_TRUNCATED
              )
        ],
    };
} ## end sub metadata

Readonly my %TAG_DESCRIPTIONS => (
    AAAA_BAD_RDATA => sub {
        __x    # AAAA_BAD_RDATA
            'Nameserver {ns}/{address} answered AAAA query with an unexpected RDATA length ({length} instead of 16)', @_;
    },
    AAAA_QUERY_DROPPED => sub {
        __x    # AAAA_QUERY_DROPPED
          'Nameserver {ns}/{address} dropped AAAA query.', @_;
    },
    AAAA_UNEXPECTED_RCODE => sub {
        __x    # AAAA_UNEXPECTED_RCODE
          'Nameserver {ns}/{address} answered AAAA query with an unexpected rcode ({rcode}).', @_;
    },
    AAAA_WELL_PROCESSED => sub {
        __x    # AAAA_WELL_PROCESSED
          'The following nameservers answer AAAA queries without problems : {names}.', @_;
    },
    A_UNEXPECTED_RCODE => sub {
        __x    # A_UNEXPECTED_RCODE
          'Nameserver {ns}/{address} answered A query with an unexpected rcode ({rcode}).', @_;
    },
    AXFR_AVAILABLE => sub {
        __x    # AXFR_AVAILABLE
          'Nameserver {ns}/{address} allow zone transfer using AXFR.', @_;
    },
    AXFR_FAILURE => sub {
        __x    # AXFR_FAILURE
          'AXFR not available on nameserver {ns}/{address}.', @_;
    },
    BREAKS_ON_EDNS => sub {
        __x    # BREAKS_ON_EDNS
          'No response from {ns}/{address} when EDNS is used in query asking for {dname}.', @_;
    },
    CAN_BE_RESOLVED => sub {
        __x    # CAN_BE_RESOLVED
          'All nameservers succeeded to resolve to an IP address.', @_;
    },
    CAN_NOT_BE_RESOLVED => sub {
        __x    # CAN_NOT_BE_RESOLVED
          'The following nameservers failed to resolve to an IP address : {names}.', @_;
    },
    CASE_QUERIES_RESULTS_DIFFER => sub {
        __x    # CASE_QUERIES_RESULTS_DIFFER
          'When asked for {type} records on "{query}" with different cases, all servers do not reply consistently.', @_;
    },
    CASE_QUERIES_RESULTS_OK => sub {
        __x    # CASE_QUERIES_RESULTS_OK
          'When asked for {type} records on "{query}" with different cases, all servers reply consistently.', @_;
    },
    CASE_QUERY_DIFFERENT_ANSWER => sub {
        __x    # CASE_QUERY_DIFFERENT_ANSWER
          'When asked for {type} records on "{query1}" and "{query2}", '
          . 'nameserver {ns}/{address} returns different answers.',
          @_;
    },
    CASE_QUERY_DIFFERENT_RC => sub {
        __x    # CASE_QUERY_DIFFERENT_RC
          'When asked for {type} records on "{query1}" and "{query2}", '
          . 'nameserver {ns}/{address} returns different RCODE ("{rcode1}" vs "{rcode2}").',
          @_;
    },
    CASE_QUERY_NO_ANSWER => sub {
        __x    # CASE_QUERY_NO_ANSWER
          'When asked for {type} records on "{query}", nameserver {ns}/{address} returns nothing.', @_;
    },
    CASE_QUERY_SAME_ANSWER => sub {
        __x    # CASE_QUERY_SAME_ANSWER
          'When asked for {type} records on "{query1}" and "{query2}", nameserver {ns}/{address} returns same answers.',
          @_;
    },
    CASE_QUERY_SAME_RC => sub {
        __x    # CASE_QUERY_SAME_RC
          'When asked for {type} records on "{query1}" and "{query2}", '
          . 'nameserver {ns}/{address} returns same RCODE "{rcode}".',
          @_;
    },
    DIFFERENT_SOURCE_IP => sub {
        __x    # DIFFERENT_SOURCE_IP
          'Nameserver {ns}/{address} replies on a SOA query with a different source address ({source}).', @_;
    },
    EDNS_RESPONSE_WITHOUT_EDNS => sub {
        __x    # EDNS_RESPONSE_WITHOUT_EDNS
          'Response without EDNS from {ns}/{address} on query with EDNS0 asking for {dname}.', @_;
    },
    EDNS_VERSION_ERROR => sub {
        __x    # EDNS_VERSION_ERROR
          'Incorrect version of EDNS (expected 0) in response from {ns}/{address} '
          . 'on query with EDNS (version 0) asking for {dname}.',
          @_;
    },
    EDNS0_SUPPORT => sub {
        __x    # EDNS0_SUPPORT
          'The following nameservers support EDNS0 : {names}.', @_;
    },
    IPV4_DISABLED => sub {
        __x    # IPV4_DISABLED
          'IPv4 is disabled, not sending "{rrtype}" query to {ns}/{address}.', @_;
    },
    IPV6_DISABLED => sub {
        __x    # IPV6_DISABLED
          'IPv6 is disabled, not sending "{rrtype}" query to {ns}/{address}.', @_;
    },
    IS_A_RECURSOR => sub {
        __x    # IS_A_RECURSOR
          'Nameserver {ns}/{address} is a recursor.', @_;
    },
    MISSING_OPT_IN_TRUNCATED => sub {
        __x    # MISSING_OPT_IN_TRUNCATED
          'Nameserver {ns}/{address} replies on an EDNS query with a truncated response without EDNS.', @_;
    },
    NO_EDNS_SUPPORT => sub {
        __x    # NO_EDNS_SUPPORT
          'Nameserver {ns}/{address} does not support EDNS0 (replies with FORMERR).', @_;
    },
    NO_RECURSOR => sub {
        __x    # NO_RECURSOR
          'Nameserver {ns}/{address} is not a recursor.', @_;
    },
    NO_RESOLUTION => sub {
        __x    # NO_RESOLUTION
          'No nameservers succeeded to resolve to an IP address.', @_;
    },
    NO_RESPONSE => sub {
        __x    # NO_RESPONSE
          'No response from {ns}/{address} asking for {dname}.', @_;
    },
    NO_UPWARD_REFERRAL => sub {
        __x    # NO_UPWARD_REFERRAL
          'None of the following nameservers returns an upward referral : {names}.', @_;
    },
    NS_ERROR => sub {
        __x    # NS_ERROR
          'Erroneous response from nameserver {ns}/{address}.', @_;
    },
    QNAME_CASE_INSENSITIVE => sub {
        __x    # QNAME_CASE_INSENSITIVE
          'Nameserver {ns}/{address} does not preserve original case of queried names.', @_;
    },
    QNAME_CASE_SENSITIVE => sub {
        __x    # QNAME_CASE_SENSITIVE
          'Nameserver {ns}/{address} preserves original case of queried names.', @_;
    },
    SAME_SOURCE_IP => sub {
        __x    # SAME_SOURCE_IP
          'All nameservers reply with same IP used to query them.', @_;
    },
    UNKNOWN_OPTION_CODE => sub {
        __x    # UNKNOWN_OPTION_CODE
          'Nameserver {ns}/{address} responds with an unknown ENDS OPTION-CODE.', @_;
    },
    UNSUPPORTED_EDNS_VER => sub {
        __x    # UNSUPPORTED_EDNS_VER
          'Nameserver {ns}/{address} accepts an unsupported EDNS version.', @_;
    },
    UPWARD_REFERRAL => sub {
        __x    # UPWARD_REFERRAL
          'Nameserver {ns}/{address} returns an upward referral.', @_;
    },
    UPWARD_REFERRAL_IRRELEVANT => sub {
        __x    # UPWARD_REFERRAL_IRRELEVANT
          'Upward referral tests skipped for root zone.', @_;
    },
    Z_FLAGS_NOTCLEAR => sub {
        __x    # Z_FLAGS_NOTCLEAR
          'Nameserver {ns}/{address} has one or more unknown EDNS Z flag bits set.', @_;
    },
);

sub tag_descriptions {
    return \%TAG_DESCRIPTIONS;
}

sub version {
    return "$Zonemaster::Engine::Test::Nameserver::VERSION";
}

sub nameserver01 {
    my ( $class, $zone ) = @_;
    my @results;

    my @nss;
    {
        my %nss = map { $_->string => $_ }
          @{ Zonemaster::Engine::TestMethods->method4( $zone ) },
          @{ Zonemaster::Engine::TestMethods->method5( $zone ) };
        @nss = values %nss;
    }

    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_6 } @nss;
    }
    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_4 } @nss;
    }

    for my $ns ( @nss ) {
        my %ns_args = (
            ns      => $ns->name->string,
            address => $ns->address->short,
        );

        my $response_count = 0;
        my $nxdomain_count = 0;
        my $is_no_recursor = 1;
        my $has_seen_ra    = 0;
        for my $nonexistent_name ( @NONEXISTENT_NAMES ) {

            my $p = $ns->query( $nonexistent_name, q{A}, { blacklisting_disabled => 1 } );
            if ( !$p ) {
                my %name_args = (
                    dname => $nonexistent_name,
                    %ns_args,
                );
                push @results, info( NO_RESPONSE => \%name_args );
                $is_no_recursor = 0;
            }
            else {
                $response_count++;

                if ( $p->ra ) {
                    $has_seen_ra = 1;
                }

                if ( $p->rcode eq q{NXDOMAIN} ) {
                    $nxdomain_count++;
                }
            }
        } ## end for my $nonexistent_name...

        if ( $has_seen_ra || ( $response_count > 0 && $nxdomain_count == $response_count ) ) {
            push @results, info( IS_A_RECURSOR => \%ns_args );
            $is_no_recursor = 0;
        }

        if ( $is_no_recursor ) {
            push @results, info( NO_RECURSOR => \%ns_args );
        }
    } ## end for my $ns ( @nss )

    return @results;

} ## end sub nameserver01

sub nameserver02 {
    my ( $class, $zone ) = @_;
    my @results;
    my %nsnames_and_ip;

    foreach
      my $local_ns ( @{ Zonemaster::Engine::TestMethods->method4( $zone ) }, @{ Zonemaster::Engine::TestMethods->method5( $zone ) } )
    {
        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) and $local_ns->address->version == $IP_VERSION_6 );

        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) and $local_ns->address->version == $IP_VERSION_4 );

        next if $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short };

        my $p = $local_ns->query( $zone->name, q{SOA}, { edns_size => 512 } );
        if ( $p ) {
            if ( $p->rcode eq q{FORMERR} and not $p->has_edns) {
                push @results,
                  info(
                    NO_EDNS_SUPPORT => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                    }
                  );
            }
            elsif ( $p->rcode eq q{NOERROR} and not $p->edns_rcode and $p->get_records( q{SOA}, q{answer} ) and $p->edns_version == 0 ) {
                $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short }++;
                next;
            }
            elsif ( $p->rcode eq q{NOERROR} and not $p->has_edns ) {
                push @results,
                  info(
                    EDNS_RESPONSE_WITHOUT_EDNS => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                        dname   => $zone->name,
                    }
                  );
            }
            elsif ( $p->rcode eq q{NOERROR} and $p->has_edns and $p->edns_version != 0 ) {
                push @results,
                  info(
                    EDNS_VERSION_ERROR => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                        dname   => $zone->name,
                    }
                  );
            }
            else {
                push @results,
                  info(
                    NS_ERROR => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                    }
                  );
            }
        }
        else {
            my $p2 = $local_ns->query( $zone->name, q{SOA} );
            if ( $p2 ) {
                push @results,
                  info(
                    BREAKS_ON_EDNS => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                        dname   => $zone->name,
                    }
                  );
            }
            else {
                push @results,
                  info(
                    NO_RESPONSE => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                        dname   => $zone->name,
                    }
                  );
            }
        }

        $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short }++;
    } ## end foreach my $local_ns ( @{ Zonemaster::Engine::TestMethods...})

    if ( scalar keys %nsnames_and_ip and not scalar @results ) {
        push @results,
          info(
            EDNS0_SUPPORT => {
                names => join( q{,}, keys %nsnames_and_ip ),
            }
          );
    }

    return @results;
} ## end sub nameserver02

sub nameserver03 {
    my ( $class, $zone ) = @_;
    my @results;
    my %nsnames_and_ip;

    foreach
      my $local_ns ( @{ Zonemaster::Engine::TestMethods->method4( $zone ) }, @{ Zonemaster::Engine::TestMethods->method5( $zone ) } )
    {

        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) and $local_ns->address->version == $IP_VERSION_6 );

        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) and $local_ns->address->version == $IP_VERSION_4 );

        next if $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short };

        my $first_rr;
        eval {
            $local_ns->axfr( $zone->name, sub { ( $first_rr ) = @_; return 0; } );
            1;
        } or do {
            push @results,
              info(
                AXFR_FAILURE => {
                    ns      => $local_ns->name->string,
                    address => $local_ns->address->short,
                }
              );
        };

        if ( $first_rr and $first_rr->type eq q{SOA} ) {
            push @results,
              info(
                AXFR_AVAILABLE => {
                    ns      => $local_ns->name->string,
                    address => $local_ns->address->short,
                }
              );
        }

        $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short }++;
    } ## end foreach my $local_ns ( @{ Zonemaster::Engine::TestMethods...})

    return @results;
} ## end sub nameserver03

sub nameserver04 {
    my ( $class, $zone ) = @_;
    my @results;
    my %nsnames_and_ip;

    foreach
      my $local_ns ( @{ Zonemaster::Engine::TestMethods->method4( $zone ) }, @{ Zonemaster::Engine::TestMethods->method5( $zone ) } )
    {

        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) and $local_ns->address->version == $IP_VERSION_6 );

        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) and $local_ns->address->version == $IP_VERSION_4 );

        next if $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short };

        my $p = $local_ns->query( $zone->name, q{SOA} );
        if ( $p ) {
            if ( $p->answerfrom and ( $local_ns->address->short ne Zonemaster::Engine::Net::IP->new( $p->answerfrom )->short ) ) {
                push @results,
                  info(
                    DIFFERENT_SOURCE_IP => {
                        ns      => $local_ns->name->string,
                        address => $local_ns->address->short,
                        source  => $p->answerfrom,
                    }
                  );
            }
        }
        $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short }++;
    } ## end foreach my $local_ns ( @{ Zonemaster::Engine::TestMethods...})

    if ( scalar keys %nsnames_and_ip and not scalar @results ) {
        push @results,
          info(
            SAME_SOURCE_IP => {
                names => join( q{,}, keys %nsnames_and_ip ),
            }
          );
    }

    return @results;
} ## end sub nameserver04

sub nameserver05 {
    my ( $class, $zone ) = @_;
    my @results;
    my %nsnames_and_ip;
    my $aaaa_issue = 0;
    my @aaaa_ok;

    foreach my $ns ( @{ Zonemaster::Engine::TestMethods->method4and5( $zone ) } ) {

        next if $nsnames_and_ip{ $ns->name->string . q{/} . $ns->address->short };

        if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) and $ns->address->version == $IP_VERSION_6 ) {
            push @results,
              info(
                IPV6_DISABLED => {
                    ns      => $ns->name->string,
                    address => $ns->address->short,
                    rrtype  => q{A},
                }
              );
            next;
        }

        if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) and $ns->address->version == $IP_VERSION_4 ) {
            push @results,
              info(
                IPV4_DISABLED => {
                    ns      => $ns->name->string,
                    address => $ns->address->short,
                    rrtype  => q{A},
                }
              );
            next;
        }

        $nsnames_and_ip{ $ns->name->string . q{/} . $ns->address->short }++;

        my $p = $ns->query( $zone->name, q{A}, { usevc => 0 } );

        if ( not $p ) {
            push @results,
              info(
                NO_RESPONSE => {
                    ns      => $ns->name,
                    address => $ns->address->short,
                    dname   => $zone->name,
                }
              );
        }
        elsif ( $p->rcode ne q{NOERROR} ) {
            push @results,
              info(
                A_UNEXPECTED_RCODE => {
                    ns      => $ns->name,
                    address => $ns->address->short,
                    rcode   => $p->rcode,
                }
              );
        }
        else {
            $p = $ns->query( $zone->name, q{AAAA}, { usevc => 0 } );

            if ( not $p ) {
                push @results,
                  info(
                    AAAA_QUERY_DROPPED => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
                $aaaa_issue++;
            }
            elsif ( $p->rcode ne q{NOERROR} ) {
                push @results,
                  info(
                    AAAA_UNEXPECTED_RCODE => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                        rcode   => $p->rcode,
                    }
                  );
                $aaaa_issue++;
            }
            else {
                foreach my $rr ( $p->get_records( q{AAAA}, q{answer} ) ) {
                    if ( length($rr->rdf(0)) != 16 ) {
                        push @results,
                          info(
                            AAAA_BAD_RDATA => {
                                ns      => $ns->name,
                                address => $ns->address->short,
                                length  => length($rr->rdf(0)),
                            }
                          );
                        $aaaa_issue++;
                    }
                    else {
                        push @aaaa_ok, $rr->address;    
                    }
                }
            }
        }
    }

    if ( scalar @aaaa_ok and not $aaaa_issue ) {
        push @results,
          info(
            AAAA_WELL_PROCESSED => {
                names => join( q{,}, keys %nsnames_and_ip ),
            }
          );
    }

    return @results;
} ## end sub nameserver05

sub nameserver06 {
    my ( $class, $zone ) = @_;
    my @results;
    my @all_nsnames = uniq map { lc( $_->string ) } @{ Zonemaster::Engine::TestMethods->method2( $zone ) },
      @{ Zonemaster::Engine::TestMethods->method3( $zone ) };
    my @all_nsnames_with_ip = uniq map { lc( $_->name->string ) } @{ Zonemaster::Engine::TestMethods->method4( $zone ) },
      @{ Zonemaster::Engine::TestMethods->method5( $zone ) };
    my @all_nsnames_without_ip;
    my %diff;

    @diff{@all_nsnames} = undef;
    delete @diff{@all_nsnames_with_ip};

    @all_nsnames_without_ip = keys %diff;
    if ( scalar @all_nsnames_without_ip and scalar @all_nsnames_with_ip ) {
        push @results,
          info(
            CAN_NOT_BE_RESOLVED => {
                names => join( q{,}, @all_nsnames_without_ip ),
            }
          );
    }
    elsif ( not scalar @all_nsnames_with_ip ) {
        push @results,
          info(
            NO_RESOLUTION => {
                names => join( q{,}, @all_nsnames_without_ip ),
            }
          );
    }
    else {
        push @results, info( CAN_BE_RESOLVED => {} );
    }

    return @results;
} ## end sub nameserver06

sub nameserver07 {
    my ( $class, $zone ) = @_;
    my @results;
    my %nsnames_and_ip;
    my %nsnames;

    if ( $zone->name eq q{.} ) {
        push @results, info( UPWARD_REFERRAL_IRRELEVANT => {} );
    }
    else {
        foreach my $local_ns ( @{ Zonemaster::Engine::TestMethods->method4( $zone ) },
            @{ Zonemaster::Engine::TestMethods->method5( $zone ) } )
        {
            next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) and $local_ns->address->version == $IP_VERSION_6 );

            next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) and $local_ns->address->version == $IP_VERSION_4 );

            next if $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short };

            my $p = $local_ns->query( q{.}, q{NS}, { blacklisting_disabled => 1 } );
            if ( $p ) {
                my @ns = $p->get_records( q{NS}, q{authority} );

                if ( @ns ) {
                    push @results,
                      info(
                        UPWARD_REFERRAL => {
                            ns      => $local_ns->name->string,
                            address => $local_ns->address->short,
                        }
                      );
                }
            }
            $nsnames{ $local_ns->name }++;
            $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short }++;
        } ## end foreach my $local_ns ( @{ Zonemaster::Engine::TestMethods...})

        if ( scalar keys %nsnames_and_ip and not scalar @results ) {
            push @results,
              info(
                NO_UPWARD_REFERRAL => {
                    names => join( q{,}, sort keys %nsnames ),
                }
              );
        }
    } ## end else [ if ( $zone->name eq q{.})]

    return @results;
} ## end sub nameserver07

sub nameserver08 {
    my ( $class, $zone ) = @_;
    my @results;
    my %nsnames_and_ip;
    my $original_name = q{www.} . $zone->name->string;
    my $randomized_uc_name;

    $original_name =~ s/[.]+\z//smgx;

    do {
        $randomized_uc_name = scramble_case $original_name;
    } while ( $randomized_uc_name eq $original_name );

    foreach
      my $local_ns ( @{ Zonemaster::Engine::TestMethods->method4( $zone ) }, @{ Zonemaster::Engine::TestMethods->method5( $zone ) } )
    {
        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) and $local_ns->address->version == $IP_VERSION_6 );

        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) and $local_ns->address->version == $IP_VERSION_4 );

        next if $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short };

        my $p = $local_ns->query( $randomized_uc_name, q{SOA} );

        if ( $p and my ( $qrr ) = $p->question() ) {
            my $qrr_name = $qrr->name();
            $qrr_name =~ s/\.\z//smgx;
            if ( $qrr_name eq $randomized_uc_name ) {
                push @results,
                  info(
                    QNAME_CASE_SENSITIVE => {
                        ns      => $local_ns->name->string,
                        address => $local_ns->address->short,
                        dname   => $randomized_uc_name,
                    }
                  );
            }
            else {
                push @results,
                  info(
                    QNAME_CASE_INSENSITIVE => {
                        ns      => $local_ns->name->string,
                        address => $local_ns->address->short,
                        dname   => $randomized_uc_name,
                    }
                  );
            }
        } ## end if ( $p and my ( $qrr ...))
        $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short }++;
    } ## end foreach my $local_ns ( @{ Zonemaster::Engine::TestMethods...})

    return @results;
} ## end sub nameserver08

sub nameserver09 {
    my ( $class, $zone ) = @_;
    my @results;
    my %nsnames_and_ip;
    my $original_name = q{www.} . $zone->name->string;
    my $record_type   = q{SOA};
    my $randomized_uc_name1;
    my $randomized_uc_name2;
    my $all_results_match = 1;

    $original_name =~ s/[.]+\z//smgx;

    do {
        $randomized_uc_name1 = scramble_case $original_name;
    } while ( $randomized_uc_name1 eq $original_name );

    do {
        $randomized_uc_name2 = scramble_case $original_name;
    } while ( $randomized_uc_name2 eq $original_name or $randomized_uc_name2 eq $randomized_uc_name1 );

    foreach
      my $local_ns ( @{ Zonemaster::Engine::TestMethods->method4( $zone ) }, @{ Zonemaster::Engine::TestMethods->method5( $zone ) } )
    {
        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) and $local_ns->address->version == $IP_VERSION_6 );

        next if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) and $local_ns->address->version == $IP_VERSION_4 );

        next if $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short };

        my $p1 = $local_ns->query( $randomized_uc_name1, $record_type );
        my $p2 = $local_ns->query( $randomized_uc_name2, $record_type );

        my $answer1_string = q{};
        my $answer2_string = q{};
        my $json = JSON::PP->new->canonical->pretty;
        if ( $p1 and scalar $p1->answer ) {

            my @answer1 = map { lc $_->string } sort $p1->answer;
            $answer1_string = $json->encode( \@answer1 );

            if ( $p2 and scalar $p2->answer ) {

                my @answer2 = map { lc $_->string } sort $p2->answer;
                $answer2_string = $json->encode( \@answer2 );
            }

            if ( $answer1_string eq $answer2_string ) {
                push @results,
                  info(
                    CASE_QUERY_SAME_ANSWER => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                        type    => $record_type,
                        query1  => $randomized_uc_name1,
                        query2  => $randomized_uc_name2,
                    }
                  );
            }
            else {
                $all_results_match = 0;
                push @results,
                  info(
                    CASE_QUERY_DIFFERENT_ANSWER => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                        type    => $record_type,
                        query1  => $randomized_uc_name1,
                        query2  => $randomized_uc_name2,
                    }
                  );
            }

        } ## end if ( $p1 and scalar $p1...)
        elsif ( $p1 and $p2 ) {

            if ( $p1->rcode eq $p2->rcode ) {
                push @results,
                  info(
                    CASE_QUERY_SAME_RC => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                        type    => $record_type,
                        query1  => $randomized_uc_name1,
                        query2  => $randomized_uc_name2,
                        rcode   => $p1->rcode,
                    }
                  );
            }
            else {
                $all_results_match = 0;
                push @results,
                  info(
                    CASE_QUERY_DIFFERENT_RC => {
                        ns      => $local_ns->name,
                        address => $local_ns->address->short,
                        type    => $record_type,
                        query1  => $randomized_uc_name1,
                        query2  => $randomized_uc_name2,
                        rcode1  => $p1->rcode,
                        rcode2  => $p2->rcode,
                    }
                  );
            }

        } ## end elsif ( $p1 and $p2 )
        elsif ( $p1 or $p2 ) {
            $all_results_match = 0;
            push @results,
              info(
                CASE_QUERY_NO_ANSWER => {
                    ns      => $local_ns->name,
                    address => $local_ns->address->short,
                    type    => $record_type,
                    query   => $p1 ? $randomized_uc_name1 : $randomized_uc_name2,
                }
              );
        }

        $nsnames_and_ip{ $local_ns->name->string . q{/} . $local_ns->address->short }++;
    } ## end foreach my $local_ns ( @{ Zonemaster::Engine::TestMethods...})

    if ( $all_results_match ) {
        push @results,
          info(
            CASE_QUERIES_RESULTS_OK => {
                type  => $record_type,
                query => $original_name,
            }
          );
    }
    else {
        push @results,
          info(
            CASE_QUERIES_RESULTS_DIFFER => {
                type  => $record_type,
                query => $original_name,
            }
          );
    }

    return @results;
} ## end sub nameserver09

sub nameserver10 {
    my ( $class, $zone ) = @_;
    my @results;

    my @nss;
    {
        my %nss = map { $_->string => $_ }
          @{ Zonemaster::Engine::TestMethods->method4( $zone ) },
          @{ Zonemaster::Engine::TestMethods->method5( $zone ) };
        @nss = values %nss;
    }

    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_6 } @nss;
    }
    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_4 } @nss;
    }

    for my $ns ( @nss ) {
        my $p = $ns->query( $zone->name, q{SOA}, { edns_details => { version => 1 } } );
        if ( $p ) {
            if ( $p->rcode eq q{FORMERR} and not $p->edns_rcode ) {
                push @results,
                  info(
                    NO_EDNS_SUPPORT => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
            elsif ( $p->rcode eq q{NOERROR} and not $p->edns_rcode ) {
                push @results,
                  info(
                    UNSUPPORTED_EDNS_VER => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
            elsif ( ($p->rcode eq q{NOERROR} and $p->edns_rcode == 1) and $p->edns_version == 0 and not scalar $p->answer) {
                next;
            }
            else {
                push @results,
                  info(
                    NS_ERROR => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
        }
        else {
            push @results,
              info(
                NO_RESPONSE => {
                    ns      => $ns->name,
                    address => $ns->address->short,
                    dname   => $zone->name,
                }
              );
        }
    }

    return @results;
} ## end sub nameserver10

sub nameserver11 {
    my ( $class, $zone ) = @_;
    my @results;

    my @nss;
    {
        my %nss = map { $_->string => $_ }
          @{ Zonemaster::Engine::TestMethods->method4( $zone ) },
          @{ Zonemaster::Engine::TestMethods->method5( $zone ) };
        @nss = values %nss;
    }

    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_6 } @nss;
    }
    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_4 } @nss;
    }

    # Choose an unassigned EDNS0 Option Codes
    # values 15-26945 are Unassigned. Let's say we use 137 ???
    my $opt_code = 137;
    my $opt_data = q{};
    my $opt_length = length($opt_data);
    my $rdata = $opt_code*65536 + $opt_length;

    for my $ns ( @nss ) {
        my $p = $ns->query( $zone->name, q{SOA}, { edns_details => { data => $rdata } } );
        if ( $p ) {
            if ( $p->rcode eq q{FORMERR} and not $p->edns_rcode ) {
                push @results,
                  info(
                    NO_EDNS_SUPPORT => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
            elsif ( defined $p->edns_data ) {
                push @results,
                  info(
                    UNKNOWN_OPTION_CODE => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
            elsif ( $p->rcode eq q{NOERROR} and not $p->edns_rcode and $p->edns_version == 0 and not defined $p->edns_data and $p->get_records( q{SOA}, q{answer} ) ) {
                next;
            }
            else {
                push @results,
                  info(
                    NS_ERROR => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
        }
        else {
            push @results,
              info(
                NO_RESPONSE => {
                    ns      => $ns->name,
                    address => $ns->address->short,
                    dname   => $zone->name,
                }
              );
        }

    }

    return @results;
} ## end sub nameserver11

sub nameserver12 {
    my ( $class, $zone ) = @_;
    my @results;

    my @nss;
    {
        my %nss = map { $_->string => $_ }
          @{ Zonemaster::Engine::TestMethods->method4( $zone ) },
          @{ Zonemaster::Engine::TestMethods->method5( $zone ) };
        @nss = values %nss;
    }

    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_6 } @nss;
    }
    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_4 } @nss;
    }

    for my $ns ( @nss ) {
        my $p = $ns->query( $zone->name, q{SOA}, { edns_details => { z => 3 } } );
        if ( $p ) {
            if ( $p->rcode eq q{FORMERR} and not $p->edns_rcode ) {
                push @results,
                  info(
                    NO_EDNS_SUPPORT => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
            elsif ( $p->edns_z ) {
                push @results,
                  info(
                    Z_FLAGS_NOTCLEAR => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
            elsif ( $p->rcode eq q{NOERROR} and not $p->edns_rcode and $p->edns_version == 0 and $p->edns_z == 0 and $p->get_records( q{SOA}, q{answer} ) ) {
                next;
            }
            else {
                push @results,
                  info(
                    NS_ERROR => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
        }
        else {
            push @results,
              info(
                NO_RESPONSE => {
                    ns      => $ns->name,
                    address => $ns->address->short,
                    dname   => $zone->name,
                }
              );
        }
    }

    return @results;
} ## end sub nameserver12

sub nameserver13 {
    my ( $class, $zone ) = @_;
    my @results;

    my @nss;
    {
        my %nss = map { $_->string => $_ }
          @{ Zonemaster::Engine::TestMethods->method4( $zone ) },
          @{ Zonemaster::Engine::TestMethods->method5( $zone ) };
        @nss = values %nss;
    }

    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv6}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_6 } @nss;
    }
    if ( not Zonemaster::Engine::Profile->effective->get(q{net.ipv4}) ) {
        @nss = grep { $_->address->version != $IP_VERSION_4 } @nss;
    }

    for my $ns ( @nss ) {
        my $p = $ns->query( $zone->name, q{SOA}, { usevc => 0, fallback => 0, edns_details => { do => 1, udp_size => 512  } } );
        if ( $p ) {
            if ( $p->rcode eq q{FORMERR} and not $p->edns_rcode ) {
                push @results,
                  info(
                    NO_EDNS_SUPPORT => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
            elsif ( $p->tc and not $p->has_edns ) {
                push @results,
                  info(
                    MISSING_OPT_IN_TRUNCATED => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
            elsif ( $p->rcode eq q{NOERROR} and not $p->edns_rcode and $p->edns_version == 0 ) {
                next;
            }
            else {
                push @results,
                  info(
                    NS_ERROR => {
                        ns      => $ns->name,
                        address => $ns->address->short,
                    }
                  );
            }
        }
        else {
            push @results,
              info(
                NO_RESPONSE => {
                    ns      => $ns->name,
                    address => $ns->address->short,
                    dname   => $zone->name,
                }
              );
        }
    }

    return @results;
} ## end sub nameserver13

1;

=head1 NAME

Zonemaster::Engine::Test::Nameserver - module implementing tests of the properties of a name server

=head1 SYNOPSIS

    my @results = Zonemaster::Engine::Test::Nameserver->all($zone);

=head1 METHODS

=over

=item all($zone)

Runs the default set of tests and returns a list of log entries made by the tests

=item tag_descriptions()

Returns a refernce to a hash with translation functions. Used by the builtin translation system.

=item metadata()

Returns a reference to a hash, the keys of which are the names of all test methods in the module, and the corresponding values are references to
lists with all the tags that the method can use in log entries.

=item version()

Returns a version string for the module.

=back

=head1 TESTS

=over

=item nameserver01($zone)

Verify that nameserver is not recursive.

=item nameserver02($zone)

Verify EDNS0 support.

=item nameserver03($zone)

Verify that zone transfer (AXFR) is not available.

=item nameserver04($zone)

Verify that replies from nameserver comes from the expected IP address.

=item nameserver05($zone)

Verify behaviour against AAAA queries.

=item nameserver06($zone)

Verify that each nameserver can be resolved to an IP address.

=item nameserver07($zone)

Check whether authoritative name servers return an upward referral.

=item nameserver08($zone)

Check whether authoritative name servers responses match the case of every letter in QNAME.

=item nameserver09($zone)

Check whether authoritative name servers return same results for equivalent names with different cases in the request.

=item nameserver10($zone)

WIP

=item nameserver11($zone)

WIP

=item nameserver12($zone)

WIP

=item nameserver13($zone)

WIP

=back

=cut
