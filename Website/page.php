<?php

$docs[0] = ""; // dummy

$docs[1]["title"] = "Information";
$docs[1]["pagetitle"] = "Meanwhile, an UT2004 mod";
$docs[1]["filename"] = "page1.html";

$docs[2]["title"] = "Media";
$docs[2]["pagetitle"] = "Pictures are being broadcasted about this epic battle.";
$docs[2]["filename"] = "page2.html";

$docs[3]["title"] = "Downloads";
$docs[3]["pagetitle"] = "The world of \"meanwhile\" comes closer to earth.";
$docs[3]["filename"] = "page3.html";

$docs[4]["title"] = "Links";
$docs[4]["pagetitle"] = "there other are adventures in the world of \"meanwhile\".";
$docs[4]["filename"] = "page4.html";

$page_nr = intval(preg_replace("#^/(.*)#", "\\1", $_SERVER["PATH_INFO"]));
if ($page_nr < 1) $page_nr = 1;
if ($page_nr > count($docs)) $page_nr = 1;

$page_title = ($docs[$page_nr]["pagetitle"] != "")?$docs[$page_nr]["pagetitle"]:$docs[$page_nr]["title"];
$page_file = $docs[$page_nr]["filename"];

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Meanwhile #1: ready for the bloodrites - page #<?= $page_nr ?></title>
	<link rel="stylesheet" type="text/css" href="/default.css" />
</head>
<body>

<table width="750" align="center">
<colgroup>
	<col width="156" />
	<col width="4" />
	<col width="1" />
	<col width="*" />
	<col width="21" />
</colgroup>
<tr>
	<td></td>
	<td></td>
	<td><img src="/images/title_4.png" alt="" /></td>
	<td></td>
	<td></td>
</tr>
<tr>
	<td><img src="/images/title_1.png" alt="" /></td>
	<td><img src="/images/title_3.png" alt="" /></td>
	<td class="headerb"><img src="/images/title_5.png" alt="" /></td>
	<td class="headerb"><table class="header">
	<colgroup>
		<col width="4" />
		<col width="*" />
		<col width="4" />
	</colgroup>
	<tr>
		<td><img src="/images/header_1.png" alt="" /></td>
		<td class="header"><?= $page_title ?></td>
		<td><img src="/images/header_2.png" alt="" /></td>
	</tr>
	</table></td>
	<td><img src="/images/content_2.png" alt="" /></td>
</tr>
<tr>
	<td rowspan="2"><table>
	<tr><td><img src="/images/title_2.png" alt="" /></td></tr>
	<tr><td class="menu">
	<?php

for ($i = 1; $i < count($docs); $i++)
{
	echo "<a href=\"/page.php/".$i."\" class=\"menu\">".$docs[$i]["title"]."</a><br />\n";
}

	?>
	</td></tr>
	<tr><td><img src="/images/menu_bottom.png" alt="" /></td></tr>
	<tr><td><img src="/images/menu_foot.png" alt="" /></td></tr>
	<tr><td class="logo"><a href="http://ut2004.elmuerte.com"><img src="/images/logo.png" alt="Michiel 'El Muerte' Hendriks" /></a></td></tr>
	</table></td>
	<td class="cleft"><img src="/images/content_1.png" alt="" height="500" width="4" /></td>
	<td colspan="2" class="content" height="100%">
	<?php
	if (file_exists($page_file)) readfile($page_file);
	?>
	</td>
	<td class="cright"><img src="/images/content_6.png" alt="" /></td>
</tr>
<tr>
	<td><img src="/images/content_3.png" alt="" /></td>
	<td colspan="2" class="cbottom"><img src="/images/content_4.png" alt="" /></td>
	<td><img src="/images/content_5.png" alt="" /></td>
</tr>
</table>

</body>
</html>