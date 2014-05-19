package Market::Plugin::Manager::Vendor;

# ABSTRACT: market manager vendor controller

use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;
  $self->render('/manage/vendor/index');
}

1;
