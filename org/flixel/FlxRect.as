package org.flixel {
	/**
	 * Stores a rectangle.
	 */
	public class FlxRect extends FlxPoint {
		/**
		 * @default 0
		 */
		public var width : Number;
		/**
		 * @default 0
		 */
		public var height : Number;

		/**
		 * Instantiate a new rectangle.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 * @param	Width	Desired width of the rectangle.
		 * @param	Height	Desired height of the rectangle.
		 */
		public function FlxRect(X : Number = 0, Y : Number = 0, Width : Number = 0, Height : Number = 0) {
			super(X, Y);
			width = Width;
			height = Height;
		}

		/**
		 * The X coordinate of the left side of the rectangle.  Read-only.
		 */
		public function get left() : Number {
			return x;
		}

		public function set left(value : Number) : void {
			x = value;
		}

		/**
		 * The X coordinate of the right side of the rectangle.  Read-only.
		 */
		public function get right() : Number {
			return x + width;
		}

		public function set right(value : Number) : void {
			x = value - width;
		}

		/**
		 * The Y coordinate of the top of the rectangle.  Read-only.
		 */
		public function get top() : Number {
			return y;
		}

		public function set top(value : Number) : void {
			y = value;
		}

		/**
		 * The Y coordinate of the bottom of the rectangle.  Read-only.
		 */
		public function get bottom() : Number {
			return y + height;
		}

		public function set bottom(value : Number) : void {
			y = value - height;
		}

		public function get cx() : Number {
			return x + width / 2;
		}

		public function set cx(value : Number) : void {
			x = value - width / 2;
		}

		public function get cy() : Number {
			return y + height / 2;
		}

		public function set cy(value : Number) : void {
			y = value - height / 2;
		}
	}
}