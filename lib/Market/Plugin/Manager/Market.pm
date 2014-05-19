package Market::Plugin::Manager::Market;

# ABSTRACT: market manager controller

use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;
  $self->render('/manage/market/index');
}

1;
