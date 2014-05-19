package Market::Plugin::Manager;

# ABSTRACT: Market management plugin

use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ($self, $app) = @_;

    push @{$app->routes->namespaces}, 'Market::Plugin::Manager';
    my $manager = $app->routes->under(
      sub {
        my $self = shift;
        return $self->auth_role_fail
          unless $self->auth_has_role("manager", "is_staff");
      }
    );

    $manager->any('/manage')->to('market#index')->name('manager_index');
    $manager->any('/manage/vendors')->to('vendor#index')->name('manager_vendors');
    return;
}

1;

__END__

=head1 ROLES

=head2 manager

* is_staff - is user staff of market

=cut
