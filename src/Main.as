package 
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Comparing two types of curve
	 * @author Shaun Evans
	 */
	public class Main extends MovieClip 
	{
		//Curve Rectangles ( will (somewhat) contain the curves )
		var s_curve_rect : Rectangle = new Rectangle(0, 0, 400, 400);
		var b_curve_rect : Rectangle = new Rectangle(400, 0, 400, 400);
		//Curve point lists:
		var s_curve_points : Array = new Array();
		var b_curve_points : Array = new Array();
		//Number of interpolation points to draw
		var numInterpolationPoints : int = 50;
		
		//Drawing colors:
		var handleColor : uint = 0xFF0000;
		var controlPolyColor : uint = 0x00FF00;
		var sCurveColor : uint = 0x0000FF;
		var bCurveColor : uint = 0x0000FF;
		
		//TrashCan:
		public var trashCan : MovieClip;
		public var interpolationTxt : TextField;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			interpolationTxt.multiline = false;
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// Mouse listeners:
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown_Stage);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove_Stage);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp_Stage);
			//Redraw listeners:
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			//Initial Points:
			addPoint( new Point( 100, 300 ) );
			addPoint( new Point( 200, 100 ) );
			addPoint( new Point( 300, 300 ) );
		}
		
		//Mouse Functions
		private var dragging : Boolean = false;
		private var draggingPointIndex : int;
		private function onMouseDown_Stage(e:MouseEvent):void 
		{
			//Ignore anything except the stage:
			if ( e.target != stage ) {
				return;
			}
			
			//Make points:
			var curvePoint : Point = getCurvePointUnder(e.stageX, e.stageY);
			if ( curvePoint == null ) {
				dragging = true;
				addPoint(new Point(e.stageX, e.stageY));
				draggingPointIndex = s_curve_points.length-1;
			} else {
				dragging = true;
				draggingPointIndex = getIndexOfPoint(curvePoint);
				if ( draggingPointIndex == -1 ) { 
					dragging = false;
				}
			}
		}
		private function getIndexOfPoint(curvePoint:Point):int
		{
			for (var i:int = 0; i < s_curve_points.length; i++) 
			{
				if ( s_curve_points[i].equals(curvePoint) ) {
					return i;
				}
			}
			for (var j:int = 0; j < b_curve_points.length; j++) 
			{
				if ( b_curve_points[j].equals(curvePoint) ) {
					return j;
				}
			}
			return -1;
		}
		private function getCurvePointUnder(stageX:Number, stageY:Number):Point
		{
			var testRect : Rectangle = new Rectangle(0, 0, 0, 0);
			var point : Point;
			for each (point in s_curve_points) 
			{
				testRect.x = point.x - handleWidth / 2;
				testRect.y = point.y - handleWidth / 2;
				testRect.width = handleWidth;
				testRect.height = handleWidth;
				if ( testRect.contains(stageX, stageY) ) {
					return point;
				}
			}
			for each (point in b_curve_points) 
			{
				testRect.x = point.x - handleWidth / 2;
				testRect.y = point.y - handleWidth / 2;
				testRect.width = handleWidth;
				testRect.height = handleWidth;
				if ( testRect.contains(stageX, stageY) ) {
					return point;
				}
			}
			return null;
		}
		
		private function addPoint(point:Point):void 
		{
			if ( s_curve_rect.containsPoint(point) ) {
				s_curve_points.push(point);
				b_curve_points.push( new Point(point.x + s_curve_rect.width, point.y) );
			}
			if ( b_curve_rect.containsPoint(point) ) {
				b_curve_points.push(point);
				s_curve_points.push( new Point(point.x - b_curve_rect.width, point.y) );
			}
		}
		
		//Mouse Moving
		private function onMouseMove_Stage(e:MouseEvent):void 
		{
			if ( dragging ) {
				if ( s_curve_rect.contains( e.stageX, e.stageY ) ) {
					s_curve_points[draggingPointIndex].x = e.stageX;
					s_curve_points[draggingPointIndex].y = e.stageY;
					b_curve_points[draggingPointIndex].x = e.stageX + b_curve_rect.x;
					b_curve_points[draggingPointIndex].y = e.stageY + b_curve_rect.y;
				} else 
				if ( b_curve_rect.contains( e.stageX, e.stageY ) ) {
					b_curve_points[draggingPointIndex].x = e.stageX;
					b_curve_points[draggingPointIndex].y = e.stageY;
					s_curve_points[draggingPointIndex].x = e.stageX - b_curve_rect.x;
					s_curve_points[draggingPointIndex].y = e.stageY - b_curve_rect.y;
				} 
			}
		}
		private function onMouseUp_Stage(e:MouseEvent):void 
		{
			if ( dragging ) {
				dragging = false;
				if ( trashCan.hitTestPoint(e.stageX, e.stageY) ) {
					deletePoint(draggingPointIndex);
				}
			}
		}
		
		//Delete a point
		private function deletePoint(draggingPointIndex:int):void 
		{
			s_curve_points.splice(draggingPointIndex, 1);
			b_curve_points.splice(draggingPointIndex, 1);
		}
		
		
		
		
		
		
		
		/**
		 * Redraw the curves every frame:
		 * @param	e
		 */
		private function onEnterFrame(e:Event):void 
		{
			numInterpolationPoints = int(interpolationTxt.text);
			if ( numInterpolationPoints > 500 ) {
				numInterpolationPoints = 500;
			}
			interpolationTxt.text = numInterpolationPoints+"";
			
			graphics.clear();
			drawHandles(s_curve_points);
			drawSCurve(s_curve_points, numInterpolationPoints);
			drawHandles(b_curve_points);
			drawBCurve(b_curve_points, numInterpolationPoints);
		}
		
		var handleWidth : Number = 10;
		/**
		 * Draw the "handles" of a set of points
		 * @param	curve_points
		 */
		private function drawHandles(curve_points:Array):void 
		{
			graphics.lineStyle(1, handleColor);
			for each (var point:Point in curve_points) 
			{
				graphics.drawRect(point.x - handleWidth / 2, point.y - handleWidth / 2, handleWidth, handleWidth);
			}
		}
		
		/**
		 * Drawing an S Curve is taking the midpoint of each line segment, removing the line segments, and adding those to the array
		 * @param	s_curve_points
		 * @param	numInterpolationPoints
		 */
		private function drawSCurve(s_curve_points:Array, numInterpolationPoints:int):void 
		{
			drawLineAlongPoints(s_curve_points, controlPolyColor);
			var SCurvePoints : Array = getSCurvePoints(s_curve_points, numInterpolationPoints);
			drawLineAlongPoints(SCurvePoints, sCurveColor);
		}
		
		/**
		 * The points generated by an s curve are:
			 * The starting point
			 * The midpoints of the line segments composing the line
			 * The ending point
		 * @param	s_curve_points
		 * @param	numInterpolationPoints
		 * @return
		 */
		private function getSCurvePoints(s_curve_points:Array, numInterpolationPoints:int):Array
		{
			if ( s_curve_points.length == 0 ) { return new Array(); }
			var newPoints : Array = new Array();
			var prevPoint : Point = s_curve_points[0];
			var midPoint : Point;
			var currentPoint : Point;
			//Include the first point:
			newPoints.push( prevPoint );
			for (var i:int = 1; i < s_curve_points.length; i++) 
			{
				currentPoint = s_curve_points[i];
				midPoint = Point.interpolate(prevPoint, currentPoint, 0.5);
				newPoints.push(midPoint);
				prevPoint = currentPoint;
			}
			//Include the last point:
			newPoints.push(s_curve_points[s_curve_points.length - 1]);
			if ( numInterpolationPoints == 0 ) {
				return newPoints;
			}
			return getSCurvePoints(newPoints, numInterpolationPoints - 1);
		}
		
		
		/**
		 * Draw a bezier curve
		 * @param	b_curve_points
		 * @param	numInterpolationPoints
		 */
		private function drawBCurve(b_curve_points:Array, numInterpolationPoints:int):void 
		{
			drawLineAlongPoints(b_curve_points, controlPolyColor);
			var BCurvePoints : Array = getBCurvePoints(b_curve_points, numInterpolationPoints);
			drawLineAlongPoints(BCurvePoints, bCurveColor);
		}
		
		/**
		 * Return the points making up a bezier curve
		 * This is accomplished by 
		 * @param	b_curve_points
		 * @param	numInterpolationPoints
		 * @return
		 */
		private function getBCurvePoints(b_curve_points:Array, numInterpolationPoints:int):Array 
		{
			if ( b_curve_points.length < 3 ) { return new Array(); }
			var newPoints : Array = new Array();
			var point : Point;
			//Push start point:
			newPoints.push(b_curve_points[0]);
			if ( b_curve_points.length+1 > numInterpolationPoints ) {
				numInterpolationPoints = b_curve_points.length + 1; //Rejigger the number of points
			}
			
			for (var i:int = 1; i < numInterpolationPoints; i++) 
			{
				var bezierFraction : Number = 1 - i / numInterpolationPoints;
				point = getBezierPointAt(b_curve_points, bezierFraction);
				newPoints.push(point);
			}
			//Push end point:
			newPoints.push(b_curve_points[b_curve_points.length-1]);
			return newPoints;
		}
		/**
		 * Get one point on the bezier curve
		 * @param	b_curve_points - the control polygon
		 * @param	bezierFraction
		 * @return
		 */
		private function getBezierPointAt(b_curve_points:Array, bezierFraction : Number):Point
		{
			var midPoints : Array = new Array();
			var midPoint : Point;
			if ( b_curve_points.length == 2 ) {
				midPoint = Point.interpolate( b_curve_points[0], b_curve_points[1], bezierFraction );
				return midPoint;
			}
			//Calculate the new control midpoints:
			var currentPoint : Point;
			var prevPoint : Point = b_curve_points[0];
			for (var i:int = 1; i < b_curve_points.length; i++) 
			{
				currentPoint = b_curve_points[i];
				midPoint = Point.interpolate(prevPoint, currentPoint, bezierFraction);
				midPoints.push(midPoint);
				prevPoint = currentPoint;
			}
			//drawLineAlongPoints(midPoints, bCurveColor * (1 / bezierFraction));
			return getBezierPointAt(midPoints, bezierFraction);
		}
		
		
		
		/**
		 * Draw a generic line along a series of points
		 * @param	points
		 * @param	lineColor
		 */
		private function drawLineAlongPoints(points:Array, lineColor:uint):void 
		{
			graphics.lineStyle(1, lineColor);
			if ( points.length == 0 ) { return; }
			graphics.moveTo(points[0].x, points[0].y);
			for (var i:int = i; i < points.length; i++) 
			{
				graphics.lineTo(points[i].x, points[i].y);
			}
		}
	}
	
}