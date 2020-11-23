use LWP;
use HTTP::Request::Common;
#~ use strict;
use Encode;
use utf8;
use HTML::TreeBuilder 5 -weak;

my $parser = HTML::TreeBuilder->new;
my $url = 'http://lostfilm-hd720.ru';
#~ my $url2 = '/1901-serial-avanpost-2-sezon-lostfilm-smotret-onlajn-besplatno-hd-720.html';



my $agent = LWP::UserAgent->new(
    ssl_opts => { verify_hostname => 0 },
    protocols_allowed => ['http'],
);
my $request = POST($url);

my $response = $agent->request($request);
$response->is_success or die "$url: ",$response->message,"$!\n";
my $content1 = decode('utf8',$response->content);
$parser->parse($content1);
  binmode(STDOUT,':encoding(utf8)');
#~ binmode(STDOUT,':encoding(cp866)');

open my $F, ">1.html" or die print $!;

print $F "<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset='utf-8'>
<title>Календарь</title>
 <style>
   table { 
	clear : both;
	width : 90%;
    margin-left : 10px;
    margin-right : 10px;
    border-spacing: 0; /* Расстояние между ячейками */
   }
   tr {
	align: center;
	}
   tr:nth-child(2n) {
    background: #f0f0f0; /* Цвет фона */
   } 
   tr:nth-child(1) {
    background: #666; /* Цвет фона */
    color: #fff; /* Цвет текста */
   }
   img {
    float : left;
    margin-left: 10px;
    margin-right: 30px;
    margin-bottom: 30px;
	}
	div {
	float : left;
	width: 60%;
	overflow-wrap : anywhere;
	}
	span {
	font-weight: bold;
	}
	
  </style>
</head>
<body>
";





my @clr_berrors=$parser->find_by_attribute('class', 'clr berrors');
my @lastupdate=$parser->find_by_attribute('class', 'lastupdate');


foreach my $i (0..$#clr_berrors){
	print $F "<h1 align='center'>",$lastupdate[$i]->as_text,"</h1>\n";
foreach my $member ($clr_berrors[$i]->content_list){
	next if not defined $member or ref($member) ne 'HTML::Element';
	my $new_item = $member->look_down('class'=>'news-item');
	my $indexi = $new_item->look_down('class'=>'indexi');
	my $a = $indexi->look_down('_tag','a')->as_HTML;
	$a =~ /<a.*href="([\s\S]+?)".*>/;
    my $href = $1;
	#~ my $indexb = $new_item->look_down('class'=>'indexb');
	&Image_url($href,$indexi->as_text);
	#~ print $F "<img src='",$url,,"'>\n";
	#~ print $F "<a href=",$url.$href,"><h2>",$indexi->as_text,"</h2></a>\n";
	#~ &Date_url($href);

};

print $F "\n";
};
print $F "
</body>
</html>
";
close $F;
#~ exec 'firefox', '1.html';




sub Image_url{
my ($href1,$film) =@_;

my $parserdate = HTML::TreeBuilder->new;
my $agentdate = LWP::UserAgent->new(
    ssl_opts => { verify_hostname => 0 },
    protocols_allowed => ['http'],
);
my $requestdate = POST($url.$href1);

my $responsedate = $agentdate->request($requestdate);
$responsedate->is_success or die "$href1: ",$responsedate->message,"$!\n";
my $content1date = decode('utf8',$responsedate->content);
$parserdate->parse($content1date);
my $poster=$parserdate->look_down('class', 'poster');
my $img=$poster->look_down('_tag'=>'img');

my $img1=$img->as_HTML;
$img1=~/<img.*src="([\s\S]+?)".*>/;
print $F "<img src='",$url.$1,"'>\n";
print $F "<div>\n";
print $F "<a href=",$url.$href1,"><h2>",$film,"</h2></a>\n";
my $m_info=$parserdate->look_down('class',"m-info");
foreach my $info_item ($m_info->content_list){
next if not defined $info_item or ref($info_item) ne 'HTML::Element';
my $info_items=$info_item->look_down('class',"info-item clearfix");
my $info_label= $info_items->look_down('class',"info-label");
my $info_desc= $info_items->look_down('class','info-desc');
if (defined ($info_label) and defined ($info_desc)) { 
print $F "<p> <span> ",$info_label->as_text,"</span> ",$info_desc->as_text,"</p>\n";}
} 

print $F "</div>\n";




my $table_dates=$parserdate->look_down('_tag', 'table');
my @table1=();
foreach my $tr ($table_dates->content_list){
	next if not defined $tr or ref($tr) ne 'HTML::Element';
	my @info=();
	foreach my $td ($tr->content_list){
		next if not defined $td or ref($td) ne 'HTML::Element';
		next if ($td->as_HTML=~"released");
		push @info, $td->as_text;
	};
	push @table1, \@info;
}

print $F "<table><tr>\n";

foreach my $j (0..$#table1){
$table1[$#table1-$j][0]=~/(\d) сезон (\d) серия/;
print $F "<td>".$2." серия </td>";

}
print $F "</tr>";
foreach my $i (1..3){
print $F "<tr>\n";
foreach my $j (0..$#table1){
print $F "<td>".$table1[$#table1-$j][$i]."</td>";}

print $F "</tr>\n";
};	
print $F "</table>\n";
print $F "<br>";

};
