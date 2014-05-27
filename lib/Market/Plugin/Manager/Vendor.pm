package Market::Plugin::Manager::Vendor;

# ABSTRACT: market manager vendor controller

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(hmac_sha1_sum);
use Skryf::Util;
use Hash::Merge::Simple qw(merge);
use DDP;

sub index {
  my $self = shift;
  $self->stash(vendorlist => $self->db->namespace('vendors')->find->all);
  $self->render('/manage/vendor/index');
}

sub modify {
    my $self    = shift;
    my $slug    = $self->param('slug');
    my $vendor = $self->db->namespace('vendors')->find_one({slug => $slug});
    if ($self->req->method eq "POST") {
        my $params = $self->req->params->to_hash;
        if ($params->{password} eq $params->{confirmpassword}) {
            $self->app->log->debug("Processing new password");
            $params->{password} =
              hmac_sha1_sum($self->app->secrets->[0], $params->{password});
        }

        # update vendor settings
        if (!keys %{$vendor}) {
            $params->{slug} = Skryf::Util->slugify($params->{vendorname});
        }
        $vendor = merge($vendor, $params);
        $self->db->namespace('vendors')->save($vendor);

        $self->flash(success => "Vendor modified.");
        $self->redirect_to('manager_vendors_modify', { slug => $vendor->{slug} });
    }
    else {
        $self->stash(vendor => $vendor);
        $self->render('/manage/vendor/modify');
    }
}

sub delete {
  my $self = shift;
  my $slug = $self->param('slug');
  $self->db->namespace('vendors')->remove({slug => $slug});
  $self->flash(success => sprintf("Vendor: %s deleted", $slug));
  $self->redirect_to($self->url_for('manager_vendors'));
}

1;
