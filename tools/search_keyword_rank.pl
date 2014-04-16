#!/usr/bin/perl
use strict;
use warnings;
use v5.10;
#use Smart::Comments;
use Mojo;
#use Encode;
use Mojo::Util qw/encode decode/;

my $keyword = shift || '绵绸连衣裙';
my $max_page = shift || 10;
my $seller = 'hiads';

my $tao_s = "http://s.taobao.com/search?q=$keyword";
my $url_s = Mojo::URL->new(decode('utf8', $tao_s)); # url中非ascii字符，需要编码成utf8,跟网页使用的字符编码没有关系
#say $url_s;

# 抓取关键字查询页面，取到分页列表url
# update:
# 搜索页面的分页是用offset 40生成页面url
# http://s.taobao.com/search?q=%C3%E0%B3%F1%C1%AC%D2%C2%C8%B9&tab=all&promote=0&bcoffset=-4&s=360#J_relative
# 第一页offset＝0， 第10页offset＝9*40
my @nav_urls;

# 默认查找页面
for my $page (0 .. $max_page-1) {
    my $offset = $page*40;
    push @nav_urls, Mojo::URL->new(decode('utf8', "$tao_s&tab=all&promote=0&bcoffset=-4&s=$offset#J_relative"));
}

my $ua = Mojo::UserAgent->new;

### @nav_urls

my $max_conn = 5;
my $active = 0;

my $callback; $callback = sub {
    --$active;
    my ($ua, $tx) = @_;
    return if ! $tx->success;

#    say $tx->req->url;

#    $tx->res->dom->find('span.J_WangWang')->each( sub {
    $tx->res->dom->find('span.J_WangWang')->grep( sub { $_->attr('data-nick') eq 'hiads' ? 1 : 0 } )->each( sub {
    #$tx->res->dom->find('span.J_WangWang')->each( sub {
            say $tx->req->url} );
};



Mojo::IOLoop->recurring(
    0   => sub {
        for ( $active + 1 .. $max_conn ) {
            return ( $active or Mojo::IOLoop->stop )
                unless my $url = shift @nav_urls;
            ++$active;
            #say $url;
            $ua->get( $url => $callback );
        }
    }
);

Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

