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
              unless $self->auth_has_role("manager", "is_staff")
              || $self->auth_has_role("admin", "is_owner");
        }
    );

    $manager->any('/manage')->to('market#index')->name('manager_index');
    $manager->any('/manage/settings')->to('market#settings')->name('manager_site_settings');
    $manager->any('/manage/staff/modify')->to('market#modify_staff')->name('manager_staff_modify');
    $manager->any('/manage/vendors')->to('vendor#index')->name('manager_vendors');
    $manager->any('/manage/vendors/modify/:slug')->to('vendor#modify')->name('manager_vendors_modify');
    return;
}

1;

__END__

=head1 ROLES

=head2 manager

* is_staff - is user staff of market

=cut
