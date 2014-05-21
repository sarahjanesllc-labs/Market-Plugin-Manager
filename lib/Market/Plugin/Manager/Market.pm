package Market::Plugin::Manager::Market;

# ABSTRACT: market manager controller

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(hmac_sha1_sum);
use Hash::Merge;
use DateTime;

sub index {
  my $self = shift;
  $self->render('/manage/market/index');
}

sub settings {
    my $self          = shift;
    my $market_cfg    = $self->db->namespace('market_cfg')->find_one;
    my $staff_members = $self->db->namespace('users')
      ->find({roles => {manager => {is_staff => 1}}})->all;
    $self->stash(staff_members => $staff_members);
    $self->stash(market_cfg    => $market_cfg);
    if ($self->req->method eq "POST") {
        my $merge = Hash::Merge->new('RIGHT_PRECEDENT');
        $self->app->log->debug("posting market: " . $market_cfg->{_id});
        my $params = $self->req->params->to_hash;
        $self->db->namespace('market_cfg')
          ->save($merge->merge($market_cfg, $params));
        $self->flash(success => "Market settings are updated.");
        $self->redirect_to($self->url_for('manager_site_settings'));
    }
    else {
        $self->render('/manage/market/settings');
    }
}

# TODO: add websocket
sub modify_staff {
    my $self     = shift;
    my $username = $self->param('username');
    my $user =
      $self->db->namespace('users')->find_one({username => $username});
    $self->stash(user => $user);
    my $params = $self->req->params->to_hash;
    $params->{created} = DateTime->now;
    if ($user) {
        $self->flash(warning => "Someone exists with this username");
        $self->redirect_to($self->url_for('manager_site_settings'));
    }
    else {
        $params->{password} =
          hmac_sha1_sum($self->app->secrets->[0], $params->{password});
        $params->{roles}->{manager}->{is_staff} = 1;
        $self->db->namespace('users')->insert($params);
    }
    $self->flash(success => $params->{username} . " added as a staff member.");
    $self->redirect_to($self->url_for('manager_site_settings'));
}

1;
