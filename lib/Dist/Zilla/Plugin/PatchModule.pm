package Dist::Zilla::Plugin::PatchModule;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
use namespace::autoclean;

with (
    'Dist::Zilla::Role::BeforeBuild',
    'Dist::Zilla::Role::AfterBuild',
);

sub before_build {
    my $self  = shift;
    my $name  = $self->zilla->name;

    unless ($name =~ /\A(\w+(?:-\w+)*)-Patch-(\w+)\z/) {
        $self->log_fatal(["Distribution name must be <TARGET_MODULE>-Patch-<DESCRIPTION>"]);
    }
}

sub after_build {
    my ($self) = @_;
    my $name  = $self->zilla->name;

    my $prereqs_hash = $self->zilla->prereqs->as_string_hash;
    my $rr_prereqs = $prereqs_hash->{runtime}{requires} // {};

    unless (defined $rr_prereqs->{'Module::Patch'}) {
        $self->log_fatal(["No prereqs to Module::Patch has been specified"]);
    }
    unless (version->parse($rr_prereqs->{'Module::Patch'}) >= version->parse("0.12")) {
        $self->log_fatal(["Prereq Module::Patch must be specified >= 0.12"]);
    }
    my ($target_mod, $desc) = $name =~ /\A(\w+(?:-\w+)*)-Patch-(\w+)\z/;
    $target_mod =~ s/-/::/g;
    unless (defined $rr_prereqs->{$target_mod}) {
        $self->log_fatal(["No prereq to target module %s has been specified", $target_mod]);
    }
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Plugin to use when building patch modules

=for Pod::Coverage .+

=head1 SYNOPSIS

In F<dist.ini>:

 [PatchModule]


=head1 DESCRIPTION

This plugin is to be used when building patch modules (modules that use
L<Module::Patch> to bundle a set of monkey patches, for example
L<File::Which::Patch::Hide> or L<LWP::UserAgent::Patch::FilterMirror>). It
currently does the following:

=over

=item * Check that distribution name is <TARGET_MODULE>-Patch-<DESCRIPTION>

=item * Check that a dependency to Module::Patch (at least 0.12) has been specified

=item * Check that a dependency to target module has been specified

=back


=head1 SEE ALSO

L<Module::Patch>

L<Pod::Weaver::Plugin::PatchModule>
