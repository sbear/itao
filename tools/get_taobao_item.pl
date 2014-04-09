#!/usr/bin/perl
use strict;
use warnings;
use Smart::Comments;
use Mojo::UserAgent;
use v5.10;

my $item_url = shift || 'http://item.taobao.com/item.htm?spm=a1z10.1.w4004-6344314304.3.s8aX0L&id=38195194094';
say  $item_url;

my $ua = Mojo::UserAgent->new;
my $callback; $callback = sub {
    my ($ua, $tx) = @_;
    return if ! $tx->success;

    my $title =  $tx->res->dom->find('h3')->text;
    my $attr = $tx->res->dom->find('ul.attributes-list');
    my $price = $tx->res->dom->find('#J_StrPrice em.tb-rmb-num')->text;
    say $title;
    say $attr;
    say $price;

    # 宝贝图片，只获取到一张缩略图
    my $img = $tx->res->dom->find('#J_ImgBooth')->attr('data-src');
    say $img;

    # 获取宝贝描述url，从js代码里获取
    my ($desc_url) = $tx->res->body =~ /"apiItemDesc":"([^"]+)",/;

    say $desc_url;

    my ($desc) = $ua->get($desc_url)->res->text =~ /var desc='(.*)';/;
    say $desc;

    # 获取宝贝描述详情

};

$ua->get($item_url => {} => $callback);
Mojo::IOLoop->start ;



