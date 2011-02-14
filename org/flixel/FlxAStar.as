package org.flixel {
	import flash.geom.Point;

	/**
	 * @author fedorjutte
	 */
	public class FlxAStar {
		private var _map : FlxTilemap;
		private var _pathfindingNodes : Vector.<FlxPathfindingNode>;
		private const COST_ORTHOGONAL : int = 10;
		private const COST_DIAGONAL : int = 14;

		public function loadFlxTilemap(map : FlxTilemap) : void {
			_map = map;
			_pathfindingNodes = new Vector.<FlxPathfindingNode>();
			for (var j : int = 0; j < _map.totalTiles; j++) {
				_pathfindingNodes.push(new FlxPathfindingNode(j % _map.widthInTiles, int(j / _map.widthInTiles)));
			}
		}

		private var _open : Vector.<FlxPathfindingNode> ;
		private var _closed : Vector.<FlxPathfindingNode>;
		private var _start : FlxPathfindingNode;

		public function findPath(startPoint : Point, endPoint : Point, allowDiagonal : Boolean = true) : Array {
			if (startPoint.x < 0)
				startPoint.x = 0;
			if (startPoint.x > _map.widthInTiles - 1)
				startPoint.x = _map.widthInTiles - 1;
			if (startPoint.y < 0)
				startPoint.y = 0;
			if (startPoint.y > _map.heightInTiles - 1)
				startPoint.y = _map.heightInTiles - 1;

			if (endPoint.x < 0)
				endPoint.x = 0;
			if (endPoint.x > _map.widthInTiles - 1)
				endPoint.x = _map.widthInTiles - 1;
			if (endPoint.y < 0)
				endPoint.y = 0;
			if (endPoint.y > _map.heightInTiles - 1)
				endPoint.y = _map.heightInTiles - 1;

			var start : FlxPathfindingNode = getNodeAt(startPoint.x, startPoint.y);
			var end : FlxPathfindingNode = getNodeAt(endPoint.x, endPoint.y);

			if (_start != start) {
				_open = new Vector.<FlxPathfindingNode>();
				_closed = new Vector.<FlxPathfindingNode>();
				_start = start;
				_open.push(start);
				start.g = 0;
				start.parent = null;
			}

			if (_closed.indexOf(end) > -1) {
				return rebuildPath(end);
			}

			for each (var node:FlxPathfindingNode in _open) {
				node.h = calcDistance(node, end);
				node.f = node.g + node.h;
			}

			while (_open.length > 0) {
				var f : int = int.MAX_VALUE;
				var currentNode : FlxPathfindingNode;
				// choose the node with the lesser cost f
				for (var i : int = 0; i < _open.length; i++) {
					if (_open[i].f < f) {
						currentNode = _open[i];
						f = currentNode.f;
					}
				}

				// we arrived at the end node, so we finish
				if (currentNode == end) {
					return rebuildPath(currentNode);
				}

				// we visited this node, so we can remove it from open and add it to closed
				_open.splice(_open.indexOf(currentNode), 1);
				_closed.push(currentNode);

				// do stuff with the neighbors of the current node
				for each (var n:FlxPathfindingNode in getNeighbors(currentNode, allowDiagonal)) {
					// skip nodes that has already been visited
					if (_closed.indexOf(n) > -1) {
						continue;
					}
					var g : int = currentNode.g + n.cost;
					if (_open.indexOf(n) == -1) {
						_open.push(n);
						n.parent = currentNode;
						n.g = g;
						// path travelled so far
						n.h = calcDistance(n, end);
						// estimated path to goal
						n.f = n.g + n.h;
					} else if (g < n.g) {
						n.parent = currentNode;
						n.g = g;
						n.h = calcDistance(n, end);
						n.f = n.g + n.h;
					}
				}
			}
			// no path can be found
			var min : int = int.MAX_VALUE;
			var nearestNode : FlxPathfindingNode;
			// find the reachable node that is nearer to the goal
			for each (var c:FlxPathfindingNode in _closed) {
				var dist : Number = calcDistance(c, end);
				if (dist < min) {
					min = dist;
					nearestNode = c;
				}
			}

			return rebuildPath(nearestNode);
			// returns the path to the node nearest to the goal
		}

		private function getNodeAt(x : int, y : int) : FlxPathfindingNode {
			return _pathfindingNodes[x + y * _map.widthInTiles];
		}

		private function isWalkable(node : FlxPathfindingNode) : Boolean {
			if (!node) {
				return false;
			}
			return _map.getTileByIndex(node.y * _map.widthInTiles + node.x) < _map.collideIndex;
		}

		// returns an array from a linked list of nodes
		private function rebuildPath(end : FlxPathfindingNode) : Array {
			var path : Array = new Array();
			if (end == null) {
				return path;
			}
			var n : FlxPathfindingNode = end;
			while (n.parent != null) {
				path.push(new Point(n.x, n.y));
				n = n.parent;
			}
			return path.reverse();
		}

		private function getNeighbors(node : FlxPathfindingNode, allowDiagonal : Boolean) : Array {
			var x : int = node.x;
			var y : int = node.y;
			var currentNode : FlxPathfindingNode;
			var neighbors : Array = new Array(8);
			if (x > 0) {
				currentNode = getNodeAt(x - 1, y);
				if (isWalkable(currentNode)) {
					currentNode.cost = COST_ORTHOGONAL;
					neighbors.push(currentNode);
				}
			}
			if (x < _map.widthInTiles - 1) {
				currentNode = getNodeAt(x + 1, y);
				if (isWalkable(currentNode)) {
					currentNode.cost = COST_ORTHOGONAL;
					neighbors.push(currentNode);
				}
			}
			if (y > 0) {
				currentNode = getNodeAt(x, y - 1);
				if (isWalkable(currentNode)) {
					currentNode.cost = COST_ORTHOGONAL;
					neighbors.push(currentNode);
				}
			}
			if (y < _map.heightInTiles - 1) {
				currentNode = getNodeAt(x, y + 1);
				if (isWalkable(currentNode)) {
					currentNode.cost = COST_ORTHOGONAL;
					neighbors.push(currentNode);
				}
			}
			if (allowDiagonal) {
				if (x > 0 && y > 0) {
					currentNode = getNodeAt(x - 1, y - 1);
					if (isWalkable(currentNode) && isWalkable(getNodeAt(x - 1, y)) && isWalkable(getNodeAt(x, y - 1))) {
						currentNode.cost = COST_DIAGONAL;
						neighbors.push(currentNode);
					}
				}
				if (x < _map.widthInTiles - 1 && y > 0) {
					currentNode = getNodeAt(x + 1, y - 1);
					if (isWalkable(currentNode) && isWalkable(getNodeAt(x + 1, y)) && isWalkable(getNodeAt(x, y - 1))) {
						currentNode.cost = COST_DIAGONAL;
						neighbors.push(currentNode);
					}
				}
				if (x > 0 && y < _map.heightInTiles - 1) {
					currentNode = getNodeAt(x - 1, y + 1);
					if (isWalkable(currentNode) && isWalkable(getNodeAt(x - 1, y)) && isWalkable(getNodeAt(x, y + 1))) {
						currentNode.cost = COST_DIAGONAL;
						neighbors.push(currentNode);
					}
				}
				if (x < _map.widthInTiles - 1 && y < _map.heightInTiles - 1) {
					currentNode = getNodeAt(x + 1, y + 1);
					if (isWalkable(currentNode) && isWalkable(getNodeAt(x + 1, y)) && isWalkable(getNodeAt(x, y + 1))) {
						currentNode.cost = COST_DIAGONAL;
						neighbors.push(currentNode);
					}
				}
			}
			return neighbors;
		}

		private function calcDistance(start : FlxPathfindingNode, end : FlxPathfindingNode) : int {
			if (start.x > end.x) {
				if (start.y > end.y) {
					return (start.x - end.x) + (start.y - end.y);
				} else {
					return (start.x - end.x) + (end.y - start.y);
				}
			} else {
				if (start.y > end.y) {
					return (end.x - start.x) + (start.y - end.y);
				} else {
					return (end.x - start.x) + (end.y - start.y);
				}
			}
		}
	}
}
class FlxPathfindingNode {
	public var x : int;
	public var y : int;
	public var g : int = 0;
	public var h : int = 0;
	public var f : int = 0;
	public var cost : int;
	public var parent : FlxPathfindingNode = null;
	public var end : FlxPathfindingNode = null;

	function FlxPathfindingNode(x : int, y : int) {
		this.x = x;
		this.y = y;
	}
}
