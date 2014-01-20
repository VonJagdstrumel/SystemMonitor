<?php
// Configuration constants
define('DBHOST', 'localhost');
define('DBUSER', 'monitor');
define('DBPASSWD', '');
define('DBNAME', 'monitor');

include_once 'SystemMonitor.php';

$dbh = new PDO('mysql:dbname=' . DBNAME . ';host=' . DBHOST, DBUSER, DBPASSWD);
$sm = new SystemMonitor($dbh);
?>
<!DOCTYPE html>
<html>
	<head>
		<title>System Monitor</title>
		<meta charset="utf-8">
		<meta http-equiv="refresh" content="300">
		<link href="css/bootstrap.min.css" rel="stylesheet">
		<style>
			p { font-weight: bold; text-align: center }
			.well { margin-top: 20px }
			.well div { margin: auto }
		</style>
	</head>
	<body>
		<div class="container">
			<div class="well">
				<p>Load Average (in AU)</p>
				<div style="width:800px;height:200px" id="loadavg"></div>
				<hr>
				<p>CPU Usage (in %)</p>
				<div style="width:800px;height:200px" id="cpuusage"></div>
				<hr>
				<p>System Stats (in AU)</p>
				<div style="width:800px;height:200px" id="systemstats"></div>
				<hr>
				<p>Response Time (in ms)</p>
				<div style="width:800px;height:200px" id="responsetime"></div>
				<hr>
				<p>Memory Usage (in %)</p>
				<div style="width:800px;height:200px" id="memoryusage"></div>
				<hr>
				<p>Disk Usage (in %)</p>
				<div style="width:800px;height:200px" id="diskusage"></div>
			</div>
		</div>

		<script language="javascript" type="text/javascript" src="js/jquery.min.js"></script>
		<script language="javascript" type="text/javascript" src="js/jquery.flot.min.js"></script>
		<script type="text/javascript">
			$(function() {
				var vXaxis = {
					ticks: <?php echo json_encode($sm->getSpecificDataSet('clock')); ?>
				};
				var vGrid = {
					backgroundColor: {colors: ['#fff', '#eee']},
					borderWidth: {top: 1, right: 1, bottom: 2, left: 2}
				};

				var config = {
					xaxis: vXaxis,
					grid: vGrid
				};
				var configPercent = {
					xaxis: vXaxis,
					yaxis: {max: 100},
					grid: vGrid
				};

				$.plot('#loadavg', [
					{label: '1 min', data: <?php echo json_encode($sm->getSpecificDataSet('loadAvgOne')); ?>},
					{label: '5 min', data: <?php echo json_encode($sm->getSpecificDataSet('loadAvgFive')); ?>},
					{label: '15 min', data: <?php echo json_encode($sm->getSpecificDataSet('loadAvgFifteen')); ?>}
				], config);

				$.plot('#cpuusage', [
					{label: 'Core 1', data: <?php echo json_encode($sm->getSpecificDataSet('cpuData[0]->usage')); ?>},
					{label: 'Core 2', data: <?php echo json_encode($sm->getSpecificDataSet('cpuData[1]->usage')); ?>},
					{label: 'Overall', data: <?php echo json_encode($sm->getSpecificDataSet('overallCpuUsage')); ?>}
				], configPercent);

				$.plot('#systemstats', [
					{label: 'Proc.', data: <?php echo json_encode($sm->getSpecificDataSet('processes')); ?>},
					{label: 'Conn.', data: <?php echo json_encode($sm->getSpecificDataSet('connections')); ?>},
					{label: 'Hosts', data: <?php echo json_encode($sm->getSpecificDataSet('hosts')); ?>},
					{label: 'Users', data: <?php echo json_encode($sm->getSpecificDataSet('users')); ?>}
				], config);

				$.plot('#responsetime', [
					{label: '8.8.8.8', data: <?php echo json_encode($sm->getSpecificDataSet('pingData[1]->time')); ?>},
					{label: '4.2.2.1', data: <?php echo json_encode($sm->getSpecificDataSet('pingData[2]->time')); ?>},
					{label: '208.67.222.222', data: <?php echo json_encode($sm->getSpecificDataSet('pingData[3]->time')); ?>}
				], config);

				$.plot('#memoryusage', [
					{label: 'Total', data: <?php echo json_encode($sm->getSpecificDataSet('memTotalUsage')); ?>},
					{label: 'Buffers', data: <?php echo json_encode($sm->getSpecificDataSet('memBuffersUsage')); ?>},
					{label: 'Cached', data: <?php echo json_encode($sm->getSpecificDataSet('memCachedUsage')); ?>},
					{label: 'System', data: <?php echo json_encode($sm->getSpecificDataSet('memSystemUsage')); ?>}
				], configPercent);

				$.plot('#diskusage', [
					{label: '/', data: <?php echo json_encode($sm->getSpecificDataSet('fsData[1]->usage')); ?>},
					{label: '/run/shm', data: <?php echo json_encode($sm->getSpecificDataSet('fsData[2]->usage')); ?>},
					{label: '/run', data: <?php echo json_encode($sm->getSpecificDataSet('fsData[3]->usage')); ?>}
				], configPercent);
			});
		</script>
	</body>
</html>
