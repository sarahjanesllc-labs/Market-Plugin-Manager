package Market::Plugin::Manager;

# ABSTRACT: Market management plugin

use Mojo::Base 'Mojolicious::Plugin';

use Market::Plugin::Manager::Model;

sub register {
    my ($self, $app) = @_;

    $app->helper(
        manager_model => sub {
            my $self = shift;
            return Market::Plugin::Manager::Model->new(
                dbname => $self->config->{dbname});
        }
    );

    $app->helper(
        manager_find_one => sub {
            my $self     = shift;
            my $username = shift;
            return $self->manager_model->get($username) || undef;
        }
    );

    $app->helper(
        manager_is_admin => sub {
            my $self = shift;
            my $user = shift;
            return 0 unless $user->{is_manager};
        }
    );

    push @{$app->routes->namespaces}, 'Market::Plugin::Manager';
}

1;
