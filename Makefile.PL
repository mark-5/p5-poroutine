use strict;
use warnings;

use ExtUtils::MakeMaker;
use Module::CPANfile;

my $cpanfile = Module::CPANfile->load('cpanfile');
WriteMakefile(
    NAME         => 'PoRoutine',
    VERSION_FROM => 'lib/PoRoutine.pm',
    META_MERGE   => {
        'meta-spec' => { version => 2 },
        'prereqs'   => $cpanfile->prereq_specs,
    },
);

sub MY::postamble {
    return <<'__END__';
readme: README.md

README.md: lib/PoRoutine.pm
	pod2markdown $< $@

release: readme manifest distdir

__END__
}
