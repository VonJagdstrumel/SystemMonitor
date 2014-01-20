<?php

/**
 *
 */
class SystemMonitor {

	private $statements;

	/**
	 *
	 * @param PDO $dbh
	 */
	public function __construct(PDO &$dbh) {
		$this->statements['filesystem'] = $dbh->prepare('SELECT * FROM filesystem ORDER BY id;');
		$this->statements['pinghost'] = $dbh->prepare('SELECT * FROM pinghost ORDER BY id;');
		$this->statements['data'] = $dbh->prepare('SELECT * FROM data ORDER BY id;');
		$this->statements['cpuData'] = $dbh->prepare('SELECT * FROM cpudata WHERE idData=?;');
		$this->statements['fsData'] = $dbh->prepare('SELECT * FROM fsdata WHERE idData=?;');
		$this->statements['pingData'] = $dbh->prepare('SELECT * FROM pingdata WHERE idData=?;');
	}

	/**
	 *
	 * @return array
	 */
	public function getDataSetConfig() {
		$data['filesystems'] = $this->fetchAllIndexed($this->statements['filesystem'], 'id');
		$data['pinghosts'] = $this->fetchAllIndexed($this->statements['pinghost'], 'id');

		return $data;
	}

	/**
	 *
	 * @return array
	 */
	public function getFullDataSet() {
		$data = array();

		$this->statements['data']->execute();
		while ($dataRow = $this->statements['data']->fetch(PDO::FETCH_OBJ)) {
			$this->statements['cpuData']->execute(array($dataRow->id));
			$this->statements['fsData']->execute(array($dataRow->id));
			$this->statements['pingData']->execute(array($dataRow->id));

			$dataRow->cpuData = $this->fetchAllIndexed($this->statements['cpuData'], 'idCpu');
			$dataRow->fsData = $this->fetchAllIndexed($this->statements['fsData'], 'idFs');
			$dataRow->pingData = $this->fetchAllIndexed($this->statements['pingData'], 'idHost');

			$data[] = $dataRow;
		}

		return $data;
	}

	/**
	 *
	 * @param string $path
	 * @return array
	 */
	public function getSpecificDataSet($path = null) {
		$data = array();

		foreach ($this->getFullDataSet() as $key => $value) {
			$value = @eval('return $value->' . $path . ';');

			if ($path == 'clock') {
				$value = date('H:i', $value);

				if (preg_match('/([0-9]{2}):00/', $value, $matches)) {
					$data[] = array($key, ($matches[1] % 2 == 0) ? $value : '');
				}
			} else {
				$data[] = array($key, $value);
			}
		}

		return $data;
	}

	/**
	 *
	 * @param PDOStatement $statement
	 * @param mixed $indexColumn
	 * @return array
	 */
	private function fetchAllIndexed(PDOStatement &$statement, $indexColumn) {
		$data = array();

		while ($row = $statement->fetch(PDO::FETCH_OBJ)) {
			$index = $row->{$indexColumn};
			unset($row->{$indexColumn});
			$data[$index] = $row;
		}

		return $data;
	}

}
