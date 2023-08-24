Class {
	#name : #MyRSMultiBezierEdgeBuilder,
	#superclass : #RSMultiBezierEdgeBuilder,
	#category : #AnalysisMooseEGF
}

{ #category : #private }
MyRSMultiBezierEdgeBuilder >> commonAncestor: edge with: selector [

	^ nil
]

{ #category : #private }
MyRSMultiBezierEdgeBuilder >> commonShapes: edge with: selector [

	"obtaint a list of points from the elements in the view based on a selector"

	| from to shapes |
	from := edge from.
	to := edge to.
	1 halt.
	shapes := self followersOf: to with: selector.
	^ shapes
]

{ #category : #private }
MyRSMultiBezierEdgeBuilder >> followersOf: element with: selector [

	^ (selector rsValue: element model) asSet
]

{ #category : #'public - line path' }
MyRSMultiBezierEdgeBuilder >> following: selector [

	self shape svgPath: [ :line | 
		[ :builder | 
		| points commonShapes att a b |
		att := line properties.
		a := line startPoint.
		b := line endPoint.
		commonShapes := att
			                at: #commom
			                ifAbsentPut: [ 
			                self commonShapes: line with: selector ].
		points := (commonShapes collect: [ :e | e position asFloatPoint ])
			          asOrderedCollection.
			points := points reverse. 
		points
			addFirst: b;
			addLast: a.
		self applyTensionOn: points.
		builder
			absolute;
			moveTo: points first.
		2 to: points size - 2 do: [ :i | 
			| p1 p2 |
			p1 := points at: i.
			p2 := points at: i + 1.
			builder curveVia: p1 to: p1 + p2 / 2 ].
		builder curveVia: (points at: points size - 1) to: points last ] ]
]
