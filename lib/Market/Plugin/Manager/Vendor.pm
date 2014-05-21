package Market::Plugin::Manager::Vendor;

# ABSTRACT: market manager vendor controller

use Mojo::Base 'Mojolicious::Controller';
use Skryf::Util;
use Hash::Merge;

sub index {
  my $self = shift;
  $self->stash(vendorlist => $self->db->namespace('vendors')->find->all);
  $self->render('/manage/vendor/index');
}

sub modify {
  my $self = shift;
  my $slug = $self->param('slug');
  my $vendor = $self->db->namespace('vendors')->find_one({slug => $slug});
  $self->stash(vendor => $vendor);
  if ($self->req->method eq "POST") {
    my $params = $self->req->params->to_hash;
    $params->{slug} = Skryf::Util->slugify($params->{vendorname});
    my $merge = Hash::Merge->new('RIGHT_PRECEDENT');
    $self->db->namespace('vendors')->save($merge->merge($vendor, $params));
    $self->flash(success => "Vendor modified.");
    $self->redirect_to('manager_vendors');
  } else {
    $self->render('/manage/vendor/modify');
  }
}

1;
