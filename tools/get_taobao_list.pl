#!/usr/bin/perl
use strict;
use warnings;
use v5.10;
use Smart::Comments;
use Mojo;
use DBI;

# 淘宝做了采集限制，直接查看店铺所有宝贝，可能会被重定向到登录页面
# 暂时直接用正则表达式提取店铺首页的所有宝贝
# 后续想对策

my $home_url = 'http://mianchoufang.taobao.com/';
say $home_url;

my %item_url;

my $ua = Mojo::UserAgent->new;
my $ua2 = Mojo::UserAgent->new;
my $tx = $ua->get($home_url);
if ( my $res = $tx->success ) {
    my @content = $res->dom->find('a')->grep( sub { $_->attr('href') =~ m|^\Qhttp://item.taobao.com/item.htm?id=\E| ? 1 : 0} )->each( sub { $item_url{$_->attr('href')}++ }); #dom解析后解码
#    say @content;
}
else {
    say $tx->error;
}

### %item_url

my @urls = keys %item_url;
my $max_conn = 2;

my $active = 0;

### 采集每个宝贝页面

### SQLite入库
my $dbh = DBI->connect('dbi:SQLite:/Users/apple/py/mysite/db.sqlite3', '', '');
die unless $dbh;

my $sth_item = $dbh->prepare('insert into itao_item (title, attr, price, tao_id, tao_desc) values (?, ?, ?, ?, ?)');
die unless $sth_item;

my $sth_img = $dbh->prepare('insert into itao_img (tao_url) values (?)');

my $sth_item_img = $dbh->prepare('insert into itao_item_img (item_id, img_id, img_type) values (?, ?, ?)');

my $callback; $callback = sub {
    --$active;
    my ($ua, $tx) = @_;
    return  if  ! $tx->success;

    say $tx->req->url;
    my ($tao_id) = $tx->req->url =~ m|\Qhttp://item.taobao.com/item.htm?id=\E(\d+)|;
    say $tao_id;

    my $title =  $tx->res->dom->at('h3')->text;
    my $attr = $tx->res->dom->find('ul.attributes-list');
    my $price = $tx->res->dom->find('#J_StrPrice em.tb-rmb-num')->text;
    say $title;
#    say $attr;
    say $price;

    # 宝贝图片，只获取到一张缩略图
    my $img = $tx->res->dom->find('#J_ImgBooth')->attr('data-src');
    say $img;

    # 获取宝贝描述url，从js代码里获取
    my ($desc_url) = $tx->res->body =~ /"apiItemDesc":"([^"]+)",/;

#    say $desc_url;

    # 复用$ua会报错
    my ($desc) = $ua2->get($desc_url)->res->text =~ /var desc='(.*)';/;
#    say $desc;

    # 获取宝贝描述详情

    # 入库
    # item
    $sth_item->execute($title, $attr, $price, $tao_id, $desc);
    my ($last_item_id) = $dbh->func('last_insert_rowid');
    ### $last_item_id

    # img
    $sth_img->execute($img);
    my ($last_img_id) = $dbh->func('last_insert_rowid');
    ### $last_img_id
    
    # item_img
    $sth_item_img->execute($last_item_id, $last_img_id, 'a');
    

};
my $callback2; $callback2 = sub {
    --$active;
    my ($ua, $tx) = @_;
    if ($tx->success) {
        say "yesss"
    }
    else {
        say "noooo";
    }
};
Mojo::IOLoop->recurring(
    0   =>  sub {
        for ( $active + 1 .. $max_conn ) {
            return ( $active or Mojo::IOLoop->stop )
                unless my $url = shift @urls;
                ++$active;
                say $url;
                $ua->get( $url => $callback );
        }
    }
);
Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

