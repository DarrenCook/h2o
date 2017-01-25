<?php
/**
* Csv file manipulation.
*
* The desired set of columns is approximately that of the most recent seasons, but
* with these changes:
*    Referee column removed.
*    The match data is reformatted from dd/mm/yy to yyyy/mm/dd.
*    Removed GBH/GBD/GBA (last used in 2012-2013)
*    Removed PSH/PSD/PSA (introduced in 2012-2013)
*    Removed SBH/SBD/SBA   (last used in 2011-2012)
*    Removed BSH/BSD/BSA (last used in 2012-2013)
*
*
* Two commandline parameters:
*   input directory
*   output directory
*
* The input directory is the base directory, from where we process
* each csv file under the 1993-1994/, 2013-2014, etc. directories.
*
* It outputs a re-organized csv file, in the output directory (but without
* subdirectories). (This is then easy to cat those files together in whatever
* groupings you want for train/valid/test data sets; remember to include header.csv .)
*
* E.g. if you have put the csv files in a sub-directory called "out/", and you want to use
*  2014-2015 as test data, 2013-2014 as validation data, and all earlier years as training
* data, you would do this (from commandline):
     cat football/header.csv football/2014-2015*.csv >../datasets/football.test.csv
     cat football/header.csv football/2013-2014*.csv >../datasets/football.valid.csv
     cat football/header.csv football/19*.csv football/200*.csv football/2010-2011*.csv football/2011-2012*.csv football/2012-2013*.csv >../datasets/football.train.csv
*
*
* @todo $argv not used yet, hard-coded the values.
* @todo Add license (MIT), author, etc. before uploading anywhere.
*
* @todo See the column breakdown - we are throwing away most betting odds.
*    However the current selection has good coverage from 2005-2006 season onwards.
*/

$GLOBALS['verbose'] = false;

$desiredColumns = array(
  "Div", "Date", "HomeTeam", "AwayTeam", "FTHG", "FTAG", "FTR", "HTHG", "HTAG", 
  "HTR", "HS", "AS", "HST", "AST", "HF", "AF", "HC",  "AC", "HY", "AY", "HR", "AR",
  "B365H", "B365D", "B365A", "BWH",  "BWD", "BWA", "IWH", "IWD", "IWA",
  "LBH",  "LBD", "LBA", "WHH", "WHD", "WHA", "SJH", "SJD", "SJA", "VCH", "VCD", "VCA",
  "Bb1X2", "BbMxH", "BbAvH", "BbMxD",  "BbAvD", "BbMxA", "BbAvA",
  "BbOU", "BbMx>2.5", "BbAv>2.5", "BbMx<2.5", "BbAv<2.5",
  "BbAH", "BbAHh", "BbMxAHH", "BbAvAHH", "BbMxAHA", "BbAvAHA"
  );


$inputPath = "/usr/local/src/FootballData/football-data.co.uk/england/";  //TODO: get from $argv
$outputPath = "football/";  //TODO: get from $argv

$files = glob($inputPath."[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]/*.csv");

$overwrite=true;

foreach($files as $fname){
  if(!preg_match('=(\d{4}-\d{4})[/](.+?).csv$=', $fname, $parts))throw new Exception("Bad fname: $fname");
  $lines = file($fname);
  $d = process($lines);
  writeFile($outputPath, $parts[1], $parts[2], $d, $overwrite);
  }

file_put_contents($outputPath."/header.csv", implode(",",$desiredColumns)."\n" );

//-----------------------------------


/**
*/
function process($lines){
global $desiredColumns;

if(!is_array($lines)){
    echo "Bad input: ";print_r($lines);
    return "";
    }

$keys = str_getcsv( array_shift($lines) );
$keys = array_flip($keys);

$d = array();
foreach($lines as $row){
    $row = trim($row);
    if($row=='')continue;   //Skip blank lines
    $vals = str_getcsv( $row );
    if($vals[0]=='')continue;   //Skip rows with all commas, no data.
    $row = array();
    foreach($desiredColumns as $k){
        if(array_key_exists($k, $keys)){
            $v = $vals[ $keys[$k] ];
            if($k == "Date" && $v!=''){
                $date = date_create_from_format('d/m/y', $v);
                if(!$date)$date = date_create_from_format('d/m/Y', $v);
                if(!$date)print_r($vals);
                $row[$k] = $date->format("Y/m/d");
                }
            else $row[$k] = $v;
            }
        else $row[$k] = "";
        }
    $d[] = implode(",",$row);   //TODO: assumes no csv escaping needed
    }
return $d;
}


/**
*/
function writeFile($outputPath, $year, $division, $rows, $overwrite){
$fname = $outputPath . "/". $year.".". $division. ".csv";
if(file_exists($fname)){
    if(!$overwrite)return;
    if($GLOBALS['verbose'])echo "Replacing (".count($rows)." rows) $fname\n";
    }
else{
    if($GLOBALS['verbose'])echo "About to write ".count($rows)." rows to $fname\n";
    }
$fp = fopen($fname, "w");
foreach($rows as $row)fwrite($fp,$row."\n");
fclose($fp);
}

